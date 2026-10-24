const { MongoClient } = require('mongodb');

const uri = process.env.MONGODB_URI;
const databaseName = process.env.MONGODB_DB_NAME || 'ecosusrural';
let client;
let database;
let connecting;
let isConnected = false;

function configured() {
  return typeof uri === 'string' && uri.startsWith('mongodb');
}

async function connectMongo() {
  if (!configured()) { isConnected = false; return null; }
  if (database) return database;
  if (connecting) return connecting;
  client = new MongoClient(uri, { serverSelectionTimeoutMS: 5000, maxPoolSize: 20 });
  connecting = client.connect().then(() => {
    database = client.db(databaseName);
    isConnected = true;
    return database;
  }).catch(async (error) => {
    isConnected = false;
    database = undefined;
    try { await client?.close(); } catch (_) { /* best effort */ }
    client = undefined;
    throw error;
  }).finally(() => { connecting = undefined; });
  return connecting;
}

async function checkMongoDatabase() {
  try {
    const db = await connectMongo();
    if (!db) return false;
    await db.command({ ping: 1 });
    isConnected = true;
    return true;
  } catch (_) { isConnected = false; return false; }
}

async function getCollection(name) {
  const db = await connectMongo();
  if (!db) throw new Error('MongoDB is not configured');
  return db.collection(name);
}

async function closeMongo() {
  const activeClient = client;
  client = undefined;
  database = undefined;
  connecting = undefined;
  isConnected = false;
  if (activeClient) await activeClient.close();
}

module.exports = { checkMongoDatabase, closeMongo, connectMongo, getCollection,
  isMongoConnected: () => isConnected, isMongoConfigured: configured };
