require('dotenv').config();

const express = require('express');
const cors = require('cors');
const config = require('./config');
const { rateLimiter } = require('./middleware/rateLimiter');
const { securityHeaders, requestId } = require('./middleware/security');
const { attachChatGateway, gatewayStats } = require('./realtime/chatSocket');

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
const dryerRoutes = require('./routes/dryerRoutes');
const aiGatewayRoutes = require('./ai/gateway');

app.use('/api/gateway', apiGatewayRoutes);
app.use('/api/schemes', schemeRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/weather', weatherRoutes);
app.use('/api/dryer', dryerRoutes);
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
    });
});

// 404 + error funnel
app.use((req, res) => res.status(404).json({ error: 'Not found', requestId: req.requestId }));
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
    console.error(`[error] ${req.requestId}:`, err.message);
    res.status(500).json({ error: 'Internal error', requestId: req.requestId });
});

const server = app.listen(config.port, () => {
    console.log(`Backend Gateway running on port ${config.port}`);
});

attachChatGateway(server);

// Graceful shutdown: stop accepting, drain, close.
function shutdown(signal) {
    console.log(`[shutdown] ${signal} received — draining…`);
    server.close(() => {
        console.log('[shutdown] server closed');
        process.exit(0);
    });
    setTimeout(() => process.exit(0), 10000).unref();
}
process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));