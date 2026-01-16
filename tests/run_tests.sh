#!/bin/bash
#
# RAMSAFE Test Runner
#
# This script sets up the testing environment and runs all RAMSAFE unit tests
# using the bats testing framework.
#
# AUTHOR: RAMSAFE Project Team
# PURPOSE: Automated testing of RAMSAFE components
# USAGE: ./run_tests.sh [OPTIONS]
#
# Options:
#   --install-bats    Install bats testing framework
#   --verbose         Run tests with verbose output
#   --help           Show this help message
#

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_usage() {
    cat << EOF
RAMSAFE Test Runner

Usage: $0 [OPTIONS]

Options:
    --install-bats    Install bats testing framework
    --verbose         Run tests with verbose output  
    --help           Show this help message

Examples:
    $0                    # Run all tests
    $0 --install-bats     # Install bats and run tests
    $0 --verbose          # Run tests with detailed output

This script runs comprehensive unit and integration tests for all RAMSAFE components.
EOF
}

install_bats() {
    log_info "Installing bats testing framework..."
    
    if command -v bats &> /dev/null; then
        log_success "Bats is already installed"
        return 0
    fi
    
    # Try package manager installation first
    if command -v apt-get &> /dev/null; then
        log_info "Installing bats via apt-get..."
        sudo apt-get update
        sudo apt-get install -y bats
    elif command -v yum &> /dev/null; then
        log_info "Installing bats via yum..."
        sudo yum install -y bats
    elif command -v brew &> /dev/null; then
        log_info "Installing bats via homebrew..."
        brew install bats-core
    else
        # Manual installation
        log_info "Installing bats manually from GitHub..."
        
        BATS_DIR="/tmp/bats-core"
        rm -rf "$BATS_DIR"
        
        git clone https://github.com/bats-core/bats-core.git "$BATS_DIR"
        cd "$BATS_DIR"
        sudo ./install.sh /usr/local
        
        rm -rf "$BATS_DIR"
    fi
    
    if command -v bats &> /dev/null; then
        log_success "Bats installed successfully"
        bats --version
    else
        log_error "Failed to install bats"
        exit 1
    fi
}

check_dependencies() {
    log_info "Checking test dependencies..."
    
    # Check for bats
    if ! command -v bats &> /dev/null; then
        log_error "Bats testing framework not found"
        log_info "Run with --install-bats to install it automatically"
        exit 1
    fi
    
    # Check for required tools for tests
    missing_deps=()
    for dep in "mktemp" "dd" "sha256sum" "stat"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_info "Please install these tools to run tests"
        exit 1
    fi
    
    log_success "All dependencies are available"
}

run_tests() {
    local verbose=$1
    
    log_info "Running RAMSAFE test suite..."
    
    # Change to project root
    cd "$PROJECT_ROOT"
    
    # Make sure scripts are executable
    chmod +x bin/*.sh
    
    local bats_options=""
    if [ "$verbose" = "true" ]; then
        bats_options="--verbose-run"
    fi
    
    local test_results=()
    local total_tests=0
    local failed_tests=0
    
    # Run utility library tests
    log_info "Running utility library tests..."
    if bats $bats_options tests/test_ramsafe_utils.bats; then
        log_success "Utility library tests passed"
        test_results+=("✅ Utility library tests: PASSED")
    else
        log_error "Utility library tests failed"
        test_results+=("❌ Utility library tests: FAILED")
        failed_tests=$((failed_tests + 1))
    fi
    total_tests=$((total_tests + 1))
    
    # Run script integration tests
    log_info "Running script integration tests..."
    if bats $bats_options tests/test_scripts.bats; then
        log_success "Script integration tests passed"
        test_results+=("✅ Script integration tests: PASSED")
    else
        log_error "Script integration tests failed"
        test_results+=("❌ Script integration tests: FAILED")
        failed_tests=$((failed_tests + 1))
    fi
    total_tests=$((total_tests + 1))
    
    # Print test summary
    echo ""
    log_info "Test Summary:"
    echo "=============="
    
    for result in "${test_results[@]}"; do
        echo "$result"
    done
    
    echo ""
    echo "Total test suites: $total_tests"
    echo "Failed test suites: $failed_tests"
    echo "Success rate: $(( (total_tests - failed_tests) * 100 / total_tests ))%"
    
    if [ $failed_tests -eq 0 ]; then
        log_success "All tests passed! ✨"
        return 0
    else
        log_error "$failed_tests test suite(s) failed"
        return 1
    fi
}

main() {
    local install_bats_flag=false
    local verbose=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --install-bats)
                install_bats_flag=true
                shift
                ;;
            --verbose)
                verbose=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Install bats if requested
    if [ "$install_bats_flag" = true ]; then
        install_bats
    fi
    
    # Check dependencies
    check_dependencies
    
    # Run tests
    if run_tests "$verbose"; then
        log_success "RAMSAFE test suite completed successfully"
        exit 0
    else
        log_error "RAMSAFE test suite completed with failures"
        exit 1
    fi
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi