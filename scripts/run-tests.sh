#!/bin/bash

# Local test runner for Rhiza Etymology Explorer
# Starts services and runs tests

set -e

COMPOSE_FILE="${1:-docker-compose.yml}"
TEST_MODE="${2:-local}"

echo "🧪 Starting Rhiza Test Suite"
echo "Compose file: $COMPOSE_FILE"
echo "Test mode: $TEST_MODE"

# Function to cleanup on exit
cleanup() {
    echo "🧹 Cleaning up..."
    if [ "$COMPOSE_FILE" = "docker-compose.test.yml" ]; then
        docker compose -f "$COMPOSE_FILE" down -v
    else
        echo "Leaving services running for local development"
    fi
}

trap cleanup EXIT

# Function to wait for service health
wait_for_service() {
    local url=$1
    local service_name=$2
    local max_attempts=30
    local attempt=1
    
    echo "⏳ Waiting for $service_name to be ready..."
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s "$url" > /dev/null 2>&1; then
            echo "✅ $service_name is ready"
            return 0
        fi
        echo "Attempt $attempt/$max_attempts: $service_name not ready yet..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo "❌ $service_name failed to become ready after $max_attempts attempts"
    return 1
}

# Start services
echo "🚀 Starting services..."
if [ "$COMPOSE_FILE" = "docker-compose.test.yml" ]; then
    docker compose -f "$COMPOSE_FILE" up -d --build
    
    # Wait for individual services
    wait_for_service "http://localhost:7474" "Neo4j"
    wait_for_service "http://localhost:8000/health" "API"
    wait_for_service "http://localhost:5173" "UI"
else
    # For local development, assume services are already running
    echo "📋 Using existing local services"
fi

# Load test data if needed
if [ "$TEST_MODE" = "fresh" ]; then
    echo "📊 Loading fresh test data..."
    sleep 5
    cat data/cypher/complete_enriched_seed.cypher | docker exec -i $(docker ps -q --filter name=neo4j) cypher-shell -u neo4j -p password
fi

# Run tests
echo "🔍 Running tests..."
if [ "$COMPOSE_FILE" = "docker-compose.test.yml" ]; then
    # Run tests in container
    docker compose -f "$COMPOSE_FILE" run --rm test-runner
else
    # Run tests locally
    export API_BASE_URL=http://localhost:8000
    export UI_BASE_URL=http://localhost:5173
    export NEO4J_URL=http://localhost:7474
    ./scripts/test.sh
fi

echo "✅ Test suite completed!"
