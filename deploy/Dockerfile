FROM node:20-alpine AS builder

# ── Build stage: compile the TypeScript auth stack to dist/ ─────────────────
WORKDIR /app
COPY backend/package.json backend/package-lock.json* ./
# Full install here so `tsc` (devDependency) is available.
RUN npm ci
COPY backend/tsconfig.json ./
COPY backend/src ./src
RUN npm run build

# ── Runtime stage ────────────────────────────────────────────────────────────
FROM node:20-alpine

# Tuned for high-concurrency socket workloads. These ENV vars apply at runtime.
ENV NODE_ENV="production"
ENV UV_THREADPOOL_SIZE="8"

RUN apk add --no-cache tini

# Create a non-root runtime user (deployments should not run as root).
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Production-only dependencies.
COPY backend/package.json backend/package-lock.json* ./
RUN npm ci --omit=dev 2>/dev/null || npm install --omit=dev

# Ship the application source AND the compiled TypeScript (dist/routes is
# dynamically required by src/routes/authRoutes.js — without it, the OTP
# auth endpoints are silently missing).
COPY backend/src ./src
COPY --from=builder /app/dist ./dist

USER appuser

EXPOSE 5000
ENTRYPOINT ["/sbin/tini", "--"]
# Start with a sensible fd limit ceiling baked into the image; orchestrator
# or docker-compose can raise it further via ulimits at runtime.
CMD ["node", "src/server.js"]
