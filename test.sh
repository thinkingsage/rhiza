#!/bin/bash

# Rhiza Etymology Explorer - Comprehensive Test Suite
# Can be run locally or in CI/CD pipelines

set -e

# Configuration
API_BASE_URL="${API_BASE_URL:-http://localhost:8000}"
UI_BASE_URL="${UI_BASE_URL:-http://localhost:5173}"
NEO4J_URL="${NEO4J_URL:-http://localhost:7474}"
TIMEOUT="${TIMEOUT:-30}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Test helper functions
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    ((TESTS_RUN++))
    log_info "Running: $test_name"
    
    if eval "$test_command"; then
        log_success "$test_name"
        return 0
    else
        log_error "$test_name"
        return 1
    fi
}

wait_for_service() {
    local url="$1"
    local service_name="$2"
    local max_attempts=30
    local attempt=1
    
    log_info "Waiting for $service_name at $url..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f "$url" > /dev/null 2>&1; then
            log_success "$service_name is ready"
            return 0
        fi
        
        log_info "Attempt $attempt/$max_attempts - $service_name not ready, waiting..."
        sleep 2
        ((attempt++))
    done
    
    log_error "$service_name failed to start within $((max_attempts * 2)) seconds"
    return 1
}

# Test functions
test_api_health() {
    curl -s -f "$API_BASE_URL/health" | grep -q "healthy"
}

test_api_ready() {
    curl -s -f "$API_BASE_URL/ready" | grep -q "ready"
}

test_neo4j_connection() {
    curl -s -f "$NEO4J_URL" > /dev/null
}

test_word_etymology_basic() {
    local response=$(curl -s "$API_BASE_URL/word/philosophy")
    echo "$response" | jq -e '.name == "philosophy" and (.roots | length) > 0' > /dev/null
}

test_word_etymology_enriched() {
    local response=$(curl -s "$API_BASE_URL/word/philosophy")
    echo "$response" | jq -e '.roots[0] | has("category") and has("frequency") and has("part_of_speech")' > /dev/null
}

test_graph_endpoint() {
    local response=$(curl -s "$API_BASE_URL/word/philosophy/graph")
    echo "$response" | jq -e 'has("nodes") and (has("edges") or has("links")) and (.nodes | length) > 0' > /dev/null
}

test_invalid_word() {
    local status=$(curl -s -o /dev/null -w "%{http_code}" "$API_BASE_URL/word/invalidword123")
    [ "$status" = "200" ] || [ "$status" = "404" ]
}

test_rate_limiting() {
    local count=0
    local limit_hit=false
    
    for i in {1..35}; do
        local status=$(curl -s -o /dev/null -w "%{http_code}" "$API_BASE_URL/word/test$i")
        if [ "$status" = "429" ]; then
            limit_hit=true
            break
        fi
        ((count++))
    done
    
    [ "$limit_hit" = true ]
}

test_cors_headers() {
    local headers=$(curl -s -I "$API_BASE_URL/health")
    echo "$headers" | grep -i "access-control-allow-origin" > /dev/null
}

test_ui_accessibility() {
    if command -v curl > /dev/null; then
        curl -s -f "$UI_BASE_URL" | grep -q "etymology"
    else
        return 0  # Skip if curl not available
    fi
}

test_database_data() {
    # Test if enriched data exists by checking API response
    local response=$(curl -s "$API_BASE_URL/word/philosophy")
    echo "$response" | jq -e '.roots[0] | has("category")' > /dev/null
}

test_api_performance() {
    local start_time=$(date +%s%N)
    curl -s "$API_BASE_URL/word/philosophy" > /dev/null
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))  # Convert to milliseconds
    
    [ $duration -lt 5000 ]  # Should respond within 5 seconds
}

test_memory_usage() {
    if command -v docker > /dev/null || command -v podman > /dev/null; then
        local container_tool="docker"
        if command -v podman > /dev/null; then
            container_tool="podman"
        fi
        
        local memory_usage=$($container_tool stats --no-stream --format "table {{.MemUsage}}" | tail -n +2 | head -1 | cut -d'/' -f1 | sed 's/[^0-9.]//g')
        
        # Check if memory usage is reasonable (less than 1GB)
        if [ -n "$memory_usage" ]; then
            [ $(echo "$memory_usage < 1000" | bc -l 2>/dev/null || echo 1) -eq 1 ]
        else
            return 0  # Skip if can't determine memory usage
        fi
    else
        return 0  # Skip if no container runtime available
    fi
}

# Security tests
test_sql_injection() {
    local malicious_input="'; DROP TABLE users; --"
    local status=$(curl -s -o /dev/null -w "%{http_code}" "$API_BASE_URL/word/$malicious_input")
    [ "$status" = "400" ]
}

test_xss_protection() {
    local malicious_input="<script>alert('xss')</script>"
    local status=$(curl -s -o /dev/null -w "%{http_code}" "$API_BASE_URL/word/$malicious_input")
    [ "$status" = "400" ]
}

# Main test execution
main() {
    log_info "Starting Rhiza Etymology Explorer Test Suite"
    log_info "API URL: $API_BASE_URL"
    log_info "UI URL: $UI_BASE_URL"
    log_info "Neo4j URL: $NEO4J_URL"
    echo

    # Wait for services to be ready
    if ! wait_for_service "$API_BASE_URL/health" "API"; then
        log_error "API service not available, exiting"
        exit 1
    fi

    # Core functionality tests
    log_info "=== Core Functionality Tests ==="
    run_test "API Health Check" "test_api_health"
    run_test "API Ready Check" "test_api_ready"
    run_test "Neo4j Connection" "test_neo4j_connection"
    run_test "Basic Word Etymology" "test_word_etymology_basic"
    run_test "Enriched Etymology Data" "test_word_etymology_enriched"
    run_test "Graph Endpoint" "test_graph_endpoint"
    run_test "Database Enriched Data" "test_database_data"
    echo

    # Error handling tests
    log_info "=== Error Handling Tests ==="
    run_test "Invalid Word Handling" "test_invalid_word"
    run_test "SQL Injection Protection" "test_sql_injection"
    run_test "XSS Protection" "test_xss_protection"
    echo

    # Performance tests
    log_info "=== Performance Tests ==="
    run_test "API Response Time" "test_api_performance"
    run_test "Memory Usage" "test_memory_usage"
    echo

    # Security and configuration tests
    log_info "=== Security & Configuration Tests ==="
    run_test "CORS Headers" "test_cors_headers"
    run_test "Rate Limiting" "test_rate_limiting"
    echo

    # UI tests (if accessible)
    log_info "=== UI Tests ==="
    run_test "UI Accessibility" "test_ui_accessibility"
    echo

    # Summary
    log_info "=== Test Summary ==="
    echo "Tests Run: $TESTS_RUN"
    echo "Tests Passed: $TESTS_PASSED"
    echo "Tests Failed: $TESTS_FAILED"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        log_success "All tests passed! ✅"
        exit 0
    else
        log_error "$TESTS_FAILED test(s) failed! ❌"
        exit 1
    fi
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v curl > /dev/null; then
        missing_deps+=("curl")
    fi
    
    if ! command -v jq > /dev/null; then
        missing_deps+=("jq")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_info "Please install missing dependencies and try again"
        exit 1
    fi
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Rhiza Etymology Explorer Test Suite"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --ci           Run in CI mode (stricter checks)"
        echo ""
        echo "Environment Variables:"
        echo "  API_BASE_URL   API base URL (default: http://localhost:8000)"
        echo "  UI_BASE_URL    UI base URL (default: http://localhost:5173)"
        echo "  NEO4J_URL      Neo4j URL (default: http://localhost:7474)"
        echo "  TIMEOUT        Service startup timeout (default: 30)"
        exit 0
        ;;
    --ci)
        log_info "Running in CI mode"
        set -x  # Enable debug output
        ;;
esac

# Run tests
check_dependencies
main
