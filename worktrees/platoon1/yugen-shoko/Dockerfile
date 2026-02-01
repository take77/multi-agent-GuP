FROM node:24-alpine AS base

WORKDIR /app

# Install dependencies
COPY package.json package-lock.json ./
RUN npm ci

# Copy source
COPY . .

# Development
FROM base AS dev
ENV NODE_ENV=development
EXPOSE 4000
CMD ["npm", "run", "dev", "--", "-p", "4000"]

# Build
FROM base AS builder
RUN npm run build

# Production
FROM node:24-alpine AS production
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
COPY --from=builder /app/public ./public

EXPOSE 4000
CMD ["npm", "run", "start", "--", "-p", "4000"]
