# --- Stage 1: Build the Svelte application ---
FROM node:20-alpine AS builder

# Set the working directory
WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Copy package files and install dependencies
COPY package*.json pnpm-lock.yaml ./
RUN pnpm install

# Copy the rest of the application source code
COPY . .

# Run the build command to create a production-ready build
RUN pnpm run build

# --- Stage 2: Serve the application using Nginx ---
FROM nginx:stable-alpine

# Copy the built static files from the 'builder' stage
COPY --from=builder /app/build /usr/share/nginx/html

# Copy the custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# The default Nginx command will start the server