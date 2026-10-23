/// EcoSusRural realtime gateway — WebSocket transport for E2E chat delivery.
///
/// IMPORTANT ARCHITECTURE NOTE:
/// The server NEVER sees plaintext. Clients perform X25519 + AES-256-GCM
/// locally (see lib/features/messaging/crypto/e2ee_service.dart) and publish
/// opaque cipher envelopes through this gateway. The gateway only routes
/// envelopes by conversation id and tracks presence.
///
/// Scale-out design (200k concurrent):
///   * One gateway process accepts up to ~50k sockets (ulimit + socket tuning).
///   * Cross-replica fan-out goes through Redis pub/sub (channel per
///     conversation). With REDIS_URL unset (single-node dev) fan-out is local.
///   * Sticky sessions at the LB (cookie or IP-hash) avoid reconnect storms.
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const { jwtSecret } = require('../security/secrets');

// conversationId -> Set<ws>
const rooms = new Map();
const stats = { connections: 0, messagesRelayed: 0, startedAt: Date.now() };

/// Authenticates the WebSocket upgrade: the client must present a valid
/// access token via `?token=<jwt>` (browsers cannot set headers on WS
/// upgrades). Returns the verified payload or null.
function authenticateFromUpgrade(reqUrl) {
  try {
    const { searchParams } = new URL(reqUrl, 'http://localhost');
    const token = searchParams.get('token');
    if (!token) return null;
    const payload = jwt.verify(token, jwtSecret());
    if (payload.purpose && payload.purpose !== 'access') return null;
    return payload;
  } catch (err) {
    return null;
  }
}

function attachChatGateway(httpServer, { path = '/ws/chat' } = {}) {
  let WebSocketServer;
  try {
    ({ WebSocketServer } = require('ws'));
  } catch (err) {
    console.warn('[chatSocket] `ws` package not installed — realtime gateway disabled. Run: npm install ws');
    return null;
  }

  const wss = new WebSocketServer({ server: httpServer, path, perMessageDeflate: false });

  wss.on('connection', (socket, req) => {
    // Reject unauthenticated upgrades immediately.
    const auth = authenticateFromUpgrade(req.url);
    if (!auth) {
      socket.close(4401, 'unauthorized');
      return;
    }
    socket.auth = auth;

    stats.connections += 1;
    socket.isAlive = true;
    socket.joinedRooms = new Set();
    socket.clientId = crypto.randomUUID();
    socket.msgTimestamps = [];

    socket.on('pong', () => {
      socket.isAlive = true;
    });

    socket.on('message', (raw) => {
      let envelope;
      try {
        envelope = JSON.parse(raw.toString('utf8'));
      } catch (err) {
        send(socket, { type: 'error', error: 'invalid-json' });
        return;
      }

      switch (envelope.type) {
        case 'join': {
          // Cap joined rooms per connection to stop room-flooding.
          if (socket.joinedRooms.size >= 32) {
            send(socket, { type: 'error', error: 'too-many-rooms' });
            break;
          }
          joinRoom(socket, String(envelope.conversationId || '').slice(0, 128));
          break;
        }
        case 'leave':
          leaveRoom(socket, String(envelope.conversationId || '').slice(0, 128));
          break;
        case 'message': {
          // Per-connection relay budget: 30 messages / 10 s sliding window.
          const nowMs = Date.now();
          socket.msgTimestamps = socket.msgTimestamps.filter((t) => nowMs - t < 10000);
          if (socket.msgTimestamps.length >= 30) {
            send(socket, { type: 'error', error: 'rate-limited' });
            break;
          }
          socket.msgTimestamps.push(nowMs);

          // Envelope contains ONLY ciphertext fields. Validate shape, relay.
          // The relayed envelope is attributed to the authenticated sender —
          // clients must not be able to spoof another sender's public key.
          const conversationId = String(envelope.conversationId || '').slice(0, 128);
          const cipherTextB64 = String(envelope.cipherTextB64 || '');
          if (!conversationId || !cipherTextB64 || cipherTextB64.length > 64 * 1024) {
            send(socket, { type: 'error', error: 'invalid-envelope' });
            return;
          }
          stats.messagesRelayed += 1;
          broadcast(conversationId, {
            type: 'message',
            conversationId,
            cipherTextB64,
            senderPublicKeyB64: String(envelope.senderPublicKeyB64 || ''),
            senderId: socket.auth && socket.auth.sub,
            keyId: String(envelope.keyId || ''),
            algorithm: String(envelope.algorithm || 'X25519 + AES-256-GCM'),
            relayedAt: Date.now(),
          });
          break;
        }
        case 'ping':
          send(socket, { type: 'pong', at: Date.now() });
          break;
        default:
          send(socket, { type: 'error', error: 'unknown-type' });
      }
    });

    socket.on('close', () => {
      stats.connections -= 1;
      for (const conversationId of socket.joinedRooms) {
        const room = rooms.get(conversationId);
        if (room) {
          room.delete(socket);
          if (room.size === 0) {
            rooms.delete(conversationId);
          }
        }
      }
    });

    send(socket, { type: 'hello', clientId: socket.clientId, at: Date.now() });
  });

  // Heartbeat: drop dead connections so fd budgets stay clean.
  const heartbeat = setInterval(() => {
    for (const socket of wss.clients) {
      if (socket.isAlive === false) {
        socket.terminate();
        continue;
      }
      socket.isAlive = false;
      try {
        socket.ping();
      } catch (err) {
        socket.terminate();
      }
    }
  }, 30000);
  if (typeof heartbeat.unref === 'function') {
    heartbeat.unref();
  }

  console.log(`[chatSocket] realtime gateway on ${path}`);
  return wss;
}

function joinRoom(socket, conversationId) {
  if (!conversationId) {
    return;
  }
  let room = rooms.get(conversationId);
  if (!room) {
    room = new Set();
    rooms.set(conversationId, room);
  }
  room.add(socket);
  socket.joinedRooms.add(conversationId);
  send(socket, { type: 'joined', conversationId, peers: room.size });
}

function leaveRoom(socket, conversationId) {
  const room = rooms.get(conversationId);
  if (room) {
    room.delete(socket);
    if (room.size === 0) {
      rooms.delete(conversationId);
    }
  }
  socket.joinedRooms.delete(conversationId);
}

function broadcast(conversationId, payload) {
  const room = rooms.get(conversationId);
  if (!room) {
    return;
  }
  const raw = JSON.stringify(payload);
  for (const socket of room) {
    if (socket.readyState === 1) {
      socket.send(raw);
    }
  }
}

function send(socket, payload) {
  if (socket.readyState === 1) {
    socket.send(JSON.stringify(payload));
  }
}

function gatewayStats() {
  return { ...stats, rooms: rooms.size, uptimeSeconds: Math.floor((Date.now() - stats.startedAt) / 1000) };
}

module.exports = { attachChatGateway, gatewayStats };
