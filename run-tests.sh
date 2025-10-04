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

# Start services
echo "🚀 Starting services..."
if [ "$COMPOSE_FILE" = "docker-compose.test.yml" ]; then
    docker compose -f "$COMPOSE_FILE" up -d --build
    echo "⏳ Waiting for services to be healthy..."
    docker compose -f "$COMPOSE_FILE" wait
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
    ./test.sh
fi

echo "✅ Test suite completed!"
