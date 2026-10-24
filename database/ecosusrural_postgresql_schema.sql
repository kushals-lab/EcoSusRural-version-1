-- PostgreSQL 18 Relational Database Schema for EcoSusRural
-- Target Database: ecosusrural
-- Engine: PostgreSQL 18.x

-- 1. Users Table (Multi-role support: farmer, buyer, seller, admin)
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(64) PRIMARY KEY,
    phone VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(120),
    role VARCHAR(32) DEFAULT 'farmer',
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMPTZ
);

-- 2. Products Table (Marketplace listings & seller catalog)
CREATE TABLE IF NOT EXISTS products (
    id VARCHAR(64) PRIMARY KEY,
    seller_id VARCHAR(64) REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    category VARCHAR(64),
    price NUMERIC(10, 2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    approval_status VARCHAR(32) DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMPTZ
);

-- 3. Orders Table (Commerce, checkout & fulfillment tracking)
CREATE TABLE IF NOT EXISTS orders (
    id VARCHAR(64) PRIMARY KEY,
    buyer_id VARCHAR(64) REFERENCES users(id),
    total_amount NUMERIC(10, 2) NOT NULL,
    payment_status VARCHAR(32) DEFAULT 'pending', -- 'pending', 'paid', 'failed'
    fulfillment_status VARCHAR(32) DEFAULT 'placed', -- 'placed', 'dispatched', 'delivered'
    payment_provider_id VARCHAR(128),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 4. Mandi Price Cache Table (Ministry of Agriculture data.gov.in cache)
CREATE TABLE IF NOT EXISTS mandi_cache (
    commodity VARCHAR(128),
    market VARCHAR(128),
    district VARCHAR(128),
    state VARCHAR(128),
    min_price NUMERIC(10, 2),
    max_price NUMERIC(10, 2),
    modal_price NUMERIC(10, 2),
    arrival_date VARCHAR(32),
    source_reported_at TIMESTAMPTZ,
    last_synced_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (commodity, market, arrival_date)
);

-- 5. Weather Cache Table (Open-Meteo 7-day meteorological forecasts)
CREATE TABLE IF NOT EXISTS weather_cache (
    latitude NUMERIC(6, 4),
    longitude NUMERIC(7, 4),
    forecast_json JSONB NOT NULL,
    source_reported_at TIMESTAMPTZ,
    last_fetched_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (latitude, longitude)
);

-- Database-authoritative update timestamps; clients never supply these.
CREATE OR REPLACE FUNCTION ecosusrural_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS users_set_updated_at ON users;
CREATE TRIGGER users_set_updated_at BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION ecosusrural_set_updated_at();
DROP TRIGGER IF EXISTS products_set_updated_at ON products;
CREATE TRIGGER products_set_updated_at BEFORE UPDATE ON products
FOR EACH ROW EXECUTE FUNCTION ecosusrural_set_updated_at();
DROP TRIGGER IF EXISTS orders_set_updated_at ON orders;
CREATE TRIGGER orders_set_updated_at BEFORE UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION ecosusrural_set_updated_at();
DROP TRIGGER IF EXISTS mandi_cache_set_updated_at ON mandi_cache;
CREATE TRIGGER mandi_cache_set_updated_at BEFORE UPDATE ON mandi_cache
FOR EACH ROW EXECUTE FUNCTION ecosusrural_set_updated_at();
