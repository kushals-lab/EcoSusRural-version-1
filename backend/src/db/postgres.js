const { Pool } = require('pg');

const pool = new Pool({
    user: process.env.PGUSER || 'postgres',
    host: process.env.PGHOST || '127.0.0.1',
    database: process.env.PGDATABASE || 'ecosusrural',
    password: process.env.PGPASSWORD || 'postgres',
    port: Number(process.env.PGPORT || 5432),
    max: 20, // Max concurrent connections in pool
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 3000,
});

let isConnected = false;

// Initialize tables if needed
async function initDatabase() {
    try {
        const client = await pool.connect();
        isConnected = true;
        console.log('PostgreSQL 18 connection established successfully.');

        // Schema migrations for users, products, orders, mandi_cache, weather_cache
        await client.query(`
            CREATE TABLE IF NOT EXISTS users (
                id VARCHAR(64) PRIMARY KEY,
                phone VARCHAR(20) UNIQUE NOT NULL,
                name VARCHAR(120),
                role VARCHAR(32) DEFAULT 'farmer',
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE IF NOT EXISTS products (
                id VARCHAR(64) PRIMARY KEY,
                seller_id VARCHAR(64),
                title VARCHAR(255) NOT NULL,
                category VARCHAR(64),
                price NUMERIC(10, 2) NOT NULL,
                stock_quantity INTEGER DEFAULT 0,
                approval_status VARCHAR(32) DEFAULT 'pending',
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE IF NOT EXISTS orders (
                id VARCHAR(64) PRIMARY KEY,
                buyer_id VARCHAR(64),
                total_amount NUMERIC(10, 2) NOT NULL,
                payment_status VARCHAR(32) DEFAULT 'pending',
                fulfillment_status VARCHAR(32) DEFAULT 'placed',
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE IF NOT EXISTS mandi_cache (
                commodity VARCHAR(128),
                market VARCHAR(128),
                district VARCHAR(128),
                state VARCHAR(128),
                min_price NUMERIC(10, 2),
                max_price NUMERIC(10, 2),
                modal_price NUMERIC(10, 2),
                arrival_date VARCHAR(32),
                synced_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (commodity, market, arrival_date)
            );
        `);
        client.release();
    } catch (err) {
        isConnected = false;
        console.warn('PostgreSQL 18 pool connection warning:', err.message);
        console.warn('EcoSusRural backend will continue with resilient in-memory / cache fallback.');
    }
}

module.exports = {
    query: (text, params) => pool.query(text, params),
    pool,
    initDatabase,
    isDbConnected: () => isConnected,
};
