const { Pool } = require('pg');

const pool = new Pool({
    user: process.env.PGUSER || 'postgres',
    host: process.env.PGHOST || '127.0.0.1',
    database: process.env.PGDATABASE || 'ecosusrural',
    password: process.env.PGPASSWORD,
    port: Number(process.env.PGPORT || 5432),
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 3000,
    ssl: process.env.PGSSL === 'true' ? { rejectUnauthorized: true } : undefined,
});

let isConnected = false;

// Runtime startup and readiness never run DDL. Schema changes belong to a
// separately authorised migration using a different database role.
async function checkDatabase() {
    try {
        await pool.query('SELECT 1');
        isConnected = true;
        return true;
    } catch (_error) {
        isConnected = false;
        return false;
    }
}

module.exports = {
    query: (text, params) => pool.query(text, params),
    pool,
    checkDatabase,
    initDatabase: checkDatabase,
    isDbConnected: () => isConnected,
};
