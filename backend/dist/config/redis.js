"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.redis = void 0;
const ioredis_1 = __importDefault(require("ioredis"));
const redisUrl = process.env.REDIS_URL || 'redis://127.0.0.1:6379';
exports.redis = new ioredis_1.default(redisUrl, {
    maxRetriesPerRequest: 3,
    enableReadyCheck: true,
    lazyConnect: false,
    retryStrategy(times) {
        if (times > 5) {
            console.warn('[Redis] Max reconnect attempts reached (5). Waiting for manual reconnect.');
            return null;
        }
        const delay = Math.min(times * 100, 2000);
        return delay;
    },
    reconnectOnError(err) {
        const targetError = 'READONLY';
        if (err.message.includes(targetError)) {
            return true;
        }
        return false;
    },
});
exports.redis.on('connect', () => {
    console.log('[Redis] Connected successfully');
});
exports.redis.on('error', (err) => {
    console.error('[Redis] Connection error:', err.message);
});
