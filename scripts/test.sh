#!/bin/bash

# Comprehensive test suite for Rhiza Etymology Explorer
# Tests API endpoints, UI functionality, and data integrity

set -e

# Configuration
API_BASE_URL="${API_BASE_URL:-http://localhost:8000}"
UI_BASE_URL="${UI_BASE_URL:-http://localhost:5173}"
NEO4J_URL="${NEO4J_URL:-http://localhost:7474}"
CI_MODE="${1:-}"
TIMEOUT="${TIMEOUT:-10}"
MAX_RETRIES="${MAX_RETRIES:-3}"

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
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Test execution wrapper
run_test() {
    local test_name="$1"
    local test_command="$2"

    TESTS_RUN=$((TESTS_RUN + 1))
    log_info "Running: $test_name"

    if eval "$test_command"; then
        log_success "$test_name"
        return 0
    else
        log_error "$test_name"
        return 1
    fi
}

# Retry wrapper for network requests
retry_command() {
    local command="$1"
    local retries=0

    while [ $retries -lt $MAX_RETRIES ]; do
        if eval "$command"; then
            return 0
        fi
        retries=$((retries + 1))
        if [ $retries -lt $MAX_RETRIES ]; then
            log_warning "Attempt $retries failed, retrying..."
            sleep 2
        fi
    done
    return 1
}

# Health check tests
test_api_health() {
    retry_command "curl -f -s --max-time $TIMEOUT '$API_BASE_URL/health' > /dev/null"
}

test_api_ready() {
    retry_command "curl -f -s --max-time $TIMEOUT '$API_BASE_URL/ready' > /dev/null"
}

test_ui_accessible() {
    retry_command "curl -f -s --max-time $TIMEOUT '$UI_BASE_URL' > /dev/null"
}

test_neo4j_accessible() {
    retry_command "curl -f -s --max-time $TIMEOUT '$NEO4J_URL' > /dev/null"
}

# API functionality tests
test_word_search() {
    local response=$(curl -s --max-time $TIMEOUT "$API_BASE_URL/word/philosophy")
    echo "$response" | jq -e '.name == "philosophy"' > /dev/null
}

test_graph_endpoint() {
    local response=$(curl -s --max-time $TIMEOUT "$API_BASE_URL/word/philosophy/graph")
    echo "$response" | jq -e '.nodes | length > 0' > /dev/null
}

test_invalid_word() {
    local status=$(curl -s --max-time $TIMEOUT -o /dev/null -w "%{http_code}" "$API_BASE_URL/word/nonexistentword123")
    [ "$status" = "400" ]
}

# Data integrity tests
test_database_connection() {
    local response=$(curl -s --max-time $TIMEOUT "$API_BASE_URL/ready")
    echo "$response" | jq -e '.dependencies.neo4j == "healthy"' > /dev/null
}

test_sample_data_exists() {
    local response=$(curl -s "$API_BASE_URL/word/philosophy")
    echo "$response" | jq -e '.roots | length > 0' > /dev/null
}

# Performance tests
test_response_time() {
    local start_time=$(date +%s%N)
    curl -s "$API_BASE_URL/word/philosophy" > /dev/null
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 )) # Convert to milliseconds

    if [ "$duration" -lt 5000 ]; then # Less than 5 seconds
        return 0
    else
        log_warning "Response time: ${duration}ms (slower than expected)"
        return 1
    fi
}

# Security tests
test_cors_headers() {
    local headers=$(curl -s --max-time $TIMEOUT -X OPTIONS -H "Origin: http://localhost:3000" -I "$API_BASE_URL/health")
    echo "$headers" | grep -i "access-control-allow-origin\|access-control-allow-methods" > /dev/null
}

test_security_headers() {
    local headers=$(curl -s --max-time $TIMEOUT -I "$API_BASE_URL/health")
    echo "$headers" | grep -i "x-content-type-options\|x-frame-options\|content-type" > /dev/null
}

# Main test execution
main() {
    echo "🧪 Rhiza Etymology Explorer Test Suite"
    echo "======================================"
    echo "API URL: $API_BASE_URL"
    echo "UI URL: $UI_BASE_URL"
    echo "Neo4j URL: $NEO4J_URL"
    echo ""

    # Health checks
    log_info "🏥 Health Checks"
    run_test "API Health Check" "test_api_health"
    run_test "API Ready Check" "test_api_ready"
    run_test "UI Accessibility" "test_ui_accessible"
    run_test "Neo4j Accessibility" "test_neo4j_accessible"
    echo ""

    # API functionality
    log_info "🔧 API Functionality"
    run_test "Word Search" "test_word_search"
    run_test "Graph Endpoint" "test_graph_endpoint"
    run_test "Invalid Word Handling" "test_invalid_word"
    echo ""

    # Data integrity
    log_info "📊 Data Integrity"
    run_test "Database Connection" "test_database_connection"
    run_test "Sample Data Exists" "test_sample_data_exists"
    echo ""

    # Performance
    log_info "⚡ Performance"
    run_test "Response Time" "test_response_time"
    echo ""

    # Security
    log_info "🔒 Security"
    run_test "CORS Headers" "test_cors_headers"
    run_test "Security Headers" "test_security_headers"
    echo ""

    # Summary
    echo "📋 Test Summary"
    echo "==============="
    echo "Tests Run: $TESTS_RUN"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"

    if [ $TESTS_FAILED -eq 0 ]; then
        log_success "All tests passed! 🎉"
        exit 0
    else
        log_error "$TESTS_FAILED test(s) failed"
        exit 1
    fi
}

# Check dependencies
if ! command -v curl &> /dev/null; then
    log_error "curl is required but not installed"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    log_error "jq is required but not installed"
    exit 1
fi

# Run tests
main
