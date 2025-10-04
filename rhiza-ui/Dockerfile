FROM node:20-alpine AS builder

WORKDIR /app

# Install pnpm in separate layer
RUN npm install -g pnpm

# Copy only dependency files first for better caching
COPY package*.json pnpm-lock.yaml ./

# Install dependencies in separate layer for caching
RUN pnpm install

# Add cache-busting argument
ARG CACHEBUST=1

# Copy source code last to maximize cache hits
COPY . .

# Build application
RUN pnpm run build

FROM nginx:stable-alpine

# Create non-root user
RUN addgroup -g 1001 -S appuser && adduser -S appuser -G appuser

# Copy built files and config
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create necessary directories and set permissions
RUN mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp /var/cache/nginx/fastcgi_temp /var/cache/nginx/uwsgi_temp /var/cache/nginx/scgi_temp && \
    chown -R appuser:appuser /usr/share/nginx/html /var/cache/nginx /var/run /var/log/nginx /etc/nginx/conf.d && \
    chmod -R 755 /usr/share/nginx/html && \
    touch /var/run/nginx.pid && \
    chown appuser:appuser /var/run/nginx.pid

# Switch to non-root user
USER appuser

EXPOSE 8080

# Run nginx in foreground as non-root
CMD ["nginx", "-g", "daemon off;"]
