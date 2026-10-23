# POSTGRESQL 18 DATABASE SCHEMA: EcoSusRural

**Target Database:** `ecosusrural`  
**Engine:** PostgreSQL 18.x

---

## 1. Schema DDL Definitions

```sql
-- 1. Users Table (Multi-role support)
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(64) PRIMARY KEY,
    phone VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(120),
    role VARCHAR(32) DEFAULT 'farmer',
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Products Table
CREATE TABLE IF NOT EXISTS products (
    id VARCHAR(64) PRIMARY KEY,
    seller_id VARCHAR(64) REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    category VARCHAR(64),
    price NUMERIC(10, 2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    approval_status VARCHAR(32) DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Orders Table
CREATE TABLE IF NOT EXISTS orders (
    id VARCHAR(64) PRIMARY KEY,
    buyer_id VARCHAR(64) REFERENCES users(id),
    total_amount NUMERIC(10, 2) NOT NULL,
    payment_status VARCHAR(32) DEFAULT 'pending', -- 'pending', 'paid', 'failed'
    fulfillment_status VARCHAR(32) DEFAULT 'placed', -- 'placed', 'dispatched', 'delivered'
    payment_provider_id VARCHAR(128),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Mandi Price Cache Table
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

-- 5. Weather Cache Table
CREATE TABLE IF NOT EXISTS weather_cache (
    latitude NUMERIC(6, 4),
    longitude NUMERIC(7, 4),
    forecast_json JSONB NOT NULL,
    fetched_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (latitude, longitude)
);
```
