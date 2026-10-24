// Local secrets live in .env.local (ignored); .env remains a shared fallback.
require('dotenv').config({ path: process.env.ENV_FILE || '.env.local' });
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const config = require('./config');
config.assertProductionConfig();
const { rateLimiter } = require('./middleware/rateLimiter');
const { securityHeaders, requestId } = require('./middleware/security');
const { attachChatGateway, gatewayStats } = require('./realtime/chatSocket');
const { checkDatabase, isDbConnected } = require('./db/postgres');
const { checkMongoDatabase, closeMongo, isMongoConnected, isMongoConfigured } = require('./db/mongodb');

const app = express();

// Behind nginx / cloud LB: trust X-Forwarded-* so req.ip is the real client.
app.set('trust proxy', 1);

app.disable('x-powered-by');
app.use(requestId);
app.use(securityHeaders);
app.use(express.json({ limit: '256kb' }));
app.use(cors({ origin: config.corsOrigin === '*' ? true : config.corsOrigin }));
app.use(rateLimiter({ windowMs: 60000, max: 600 }));

const apiGatewayRoutes = require('./routes/apiGateway');
const schemeRoutes = require('./routes/schemeRoutes');
const authRoutes = require('./routes/authRoutes');
const paymentRoutes = require('./routes/paymentRoutes');
const weatherRoutes = require('./routes/weatherRoutes');
const dryerRoutes = require('./routes/mongoDryerRoutes');
const aiGatewayRoutes = require('./ai/gateway');
const dryerSimulator = require('./routes/dryerSimulatorRoutes').createDryerSimulator();

app.use('/api/gateway', apiGatewayRoutes);
app.use('/api/schemes', schemeRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/weather', weatherRoutes);
app.use('/api/locations', require('./routes/locationRoutes'));
app.use('/api/account', require('./routes/accountRoutes'));
app.use('/api/msp', require('./routes/mspRoutes'));
app.use('/api/products', require('./routes/productRoutes'));
app.use('/api/dryer', dryerRoutes);
app.use('/api/dryer-simulator', dryerSimulator.api);
app.use('/dryer-simulator', dryerSimulator.site);
app.use('/api/ai', aiGatewayRoutes);
app.use('/api/mandi', require('./routes/mandiRoutes'));

app.get('/', (req, res) => {
    res.json({ status: 'Gateway Active', service: 'EcoSusRural Express Backend' });
});

// Liveness + capacity telemetry for load balancers / orchestrators.
app.get('/health', (req, res) => {
    const memory = process.memoryUsage();
    res.json({
        status: 'ok',
        service: 'EcoSusRural Express Backend',
        uptimeSeconds: Math.floor(process.uptime()),
        memory: {
            rssMb: Math.round(memory.rss / (1024 * 1024)),
            heapUsedMb: Math.round(memory.heapUsed / (1024 * 1024)),
        },
        realtime: gatewayStats(),
        database: {
            mongodb: isMongoConfigured() ? (isMongoConnected() ? 'available' : 'unavailable') : 'not_configured',
            postgresql: isDbConnected() ? 'available' : 'unavailable',
        },
        checked_at: new Date().toISOString(),
    });
});

// Fresh, read-only database probes. No error or connection secret is returned.
app.get('/ready', async (req, res) => {
    const [mongodb, postgresql] = await Promise.all([checkMongoDatabase(), checkDatabase()]);
    const available = mongodb && postgresql;
    res.status(available ? 200 : 503).json({
        status: available ? 'ready' : 'unavailable',
        database: { mongodb: mongodb ? 'available' : 'unavailable', postgresql: postgresql ? 'available' : 'unavailable' },
        checked_at: new Date().toISOString(),
    });
});

// 404 + error funnel
app.use((req, res) => res.status(404).json({ error: 'Not found', requestId: req.requestId }));
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
    console.error(`[error] ${req.requestId}:`, err.message);
    res.status(500).json({ error: 'Internal error', requestId: req.requestId });
});

const server = app.listen(config.port, config.host, () => {
    console.log(`Backend Gateway listening on ${config.host}:${config.port}`);
});

// Initial connection check is read-only; /ready can repeat it on demand.
void checkDatabase();
void checkMongoDatabase();

attachChatGateway(server);

// Graceful shutdown: stop accepting, drain, close.
function shutdown(signal) {
    dryerSimulator.close();
    console.log(`[shutdown] ${signal} received — draining…`);
    server.close(async () => {
        await closeMongo();
        console.log('[shutdown] server closed');
        process.exit(0);
    });
    setTimeout(() => process.exit(0), 10000).unref();
}
process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
