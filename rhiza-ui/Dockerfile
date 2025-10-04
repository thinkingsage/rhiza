FROM node:20-alpine AS builder

WORKDIR /app

# Install pnpm in separate layer
RUN npm install -g pnpm

# Copy only dependency files first for better caching
COPY package*.json pnpm-lock.yaml ./

# Install dependencies in separate layer for caching
RUN pnpm install

# Copy source code last to maximize cache hits
COPY . .

# Build application
RUN pnpm run build

FROM nginx:stable-alpine

# Copy built files and config
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
