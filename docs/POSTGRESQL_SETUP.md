# POSTGRESQL 18 SETUP & ARCHITECTURAL REPORT

**Date:** 2026-10-23  
**Status:** DETECTED & CONFIGURED

---

## 1. System PostgreSQL 18 Detection
- **Service Name:** `postgresql-x64-18` (PostgreSQL Server 18)
- **Service Status:** **Running** (Process ID: 7784)
- **Installation Directory:** `C:\Program Files\PostgreSQL\18\`
- **Data Directory:** `C:\Program Files\PostgreSQL\18\data`
- **Listening TCP Port:** `5432` (verified active listening on `0.0.0.0:5432` and `[::]:5432`)

## 2. Integration Architecture
```
[Flutter Mobile/Desktop Client]
          |
       (HTTPS)
          v
[Express 5.2.1 Backend Gateway (localhost:5000)]
          |
       (pg Pool)
          v
[PostgreSQL 18 Database (localhost:5432)]
```

- **Driver:** Official `pg` connection pool with automatic recovery and connection limits (`max: 20`, `idleTimeoutMillis: 30000`).
- **Security Rule:** PostgreSQL credentials are strictly isolated within `backend/.env` and the Node.js process. The Flutter client never communicates directly over TCP 5432.
