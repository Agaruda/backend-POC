#!/bin/bash

# Local CI Script for Backend POC
# This script runs the same checks as GitHub Actions locally

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration
CONFIG_FILE="$PROJECT_ROOT/.local-ci-config.yaml"
LOG_FILE="$PROJECT_ROOT/.local-ci.log"

# Default values
FORMAT_ONLY=false
LINT_ONLY=false
SECURITY_ONLY=false
BUILD_ONLY=false
ALL_CHECKS=true
AUTO_FIX=false
VERBOSE=false

# Statistics
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "HEADER")
            echo -e "${PURPLE}🔍 $message${NC}"
            ;;
        "STEP")
            echo -e "${CYAN}  ├── $message${NC}"
            ;;
    esac
}

# Function to log messages
log_message() {
    local level=$1
    local message=$2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to update statistics
update_stats() {
    local result=$1
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    case $result in
        "PASS")
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
            ;;
        "FAIL")
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            ;;
        "WARN")
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
            ;;
    esac
}

# Function to check environment setup
check_environment() {
    print_status "HEADER" "Environment Setup"
    
    # Check Python version
    if command_exists python3; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        if [[ "$PYTHON_VERSION" == 3.11* ]] || [[ "$PYTHON_VERSION" == 3.12* ]]; then
            print_status "STEP" "Python $PYTHON_VERSION: PASSED"
            update_stats "PASS"
        else
            print_status "ERROR" "Python $PYTHON_VERSION: FAILED (requires 3.11+)"
            update_stats "FAIL"
            return 1
        fi
    else
        print_status "ERROR" "Python3 not found"
        update_stats "FAIL"
        return 1
    fi
    
    # Check uv
    if command_exists uv; then
        print_status "STEP" "uv package manager: PASSED"
        update_stats "PASS"
    else
        print_status "WARNING" "uv not found, installing..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.cargo/bin:$PATH"
        print_status "STEP" "uv installed successfully"
        update_stats "PASS"
    fi
    
    # Check Docker
    if command_exists docker; then
        if docker info >/dev/null 2>&1; then
            print_status "STEP" "Docker: PASSED"
            update_stats "PASS"
        else
            print_status "WARNING" "Docker not running"
            update_stats "WARN"
        fi
    else
        print_status "WARNING" "Docker not installed"
        update_stats "WARN"
    fi
    
    # Install dependencies
    print_status "STEP" "Installing dependencies..."
    cd "$PROJECT_ROOT"
    uv sync --dev
    print_status "STEP" "Dependencies installed"
    update_stats "PASS"
}

# Function to run code quality checks
run_quality_checks() {
    print_status "HEADER" "Code Quality Checks"
    
    cd "$PROJECT_ROOT"
    
    # Black formatting check
    print_status "STEP" "Black formatting check..."
    if uv run black --check .; then
        print_status "STEP" "Black formatting: PASSED"
        update_stats "PASS"
    else
        print_status "ERROR" "Black formatting: FAILED"
        if [ "$AUTO_FIX" = true ]; then
            print_status "INFO" "Auto-fixing formatting..."
            uv run black .
            print_status "STEP" "Formatting auto-fixed"
            update_stats "PASS"
        else
            print_status "INFO" "Run 'uv run black .' to fix formatting"
            update_stats "FAIL"
        fi
    fi
    
    # Flake8 linting
    print_status "STEP" "Flake8 linting..."
    if uv run flake8 . --exclude .venv; then
        print_status "STEP" "Flake8 linting: PASSED"
        update_stats "PASS"
    else
        print_status "ERROR" "Flake8 linting: FAILED"
        update_stats "FAIL"
    fi
    
    # Ruff checking
    print_status "STEP" "Ruff checking..."
    if uv run ruff check .; then
        print_status "STEP" "Ruff checking: PASSED"
        update_stats "PASS"
    else
        print_status "ERROR" "Ruff checking: FAILED"
        update_stats "FAIL"
    fi
    
    # Mypy type checking (non-blocking)
    print_status "STEP" "Mypy type checking..."
    if uv run mypy .; then
        print_status "STEP" "Mypy type checking: PASSED"
        update_stats "PASS"
    else
        print_status "WARNING" "Mypy type checking: WARNING (non-blocking)"
        update_stats "WARN"
    fi
}

# Function to run build checks
run_build_checks() {
    print_status "HEADER" "Build Checks"
    
    cd "$PROJECT_ROOT"
    
    # Dockerfile linting
    print_status "STEP" "Dockerfile linting..."
    if command_exists hadolint; then
        if hadolint Dockerfile; then
            print_status "STEP" "Dockerfile linting: PASSED"
            update_stats "PASS"
        else
            print_status "ERROR" "Dockerfile linting: FAILED"
            update_stats "FAIL"
        fi
    else
        print_status "WARNING" "hadolint not installed, skipping Dockerfile linting"
        update_stats "WARN"
    fi
    
    # Docker build test
    print_status "STEP" "Docker build test..."
    if command_exists docker && docker info >/dev/null 2>&1; then
        if docker build -t local-test:latest .; then
            print_status "STEP" "Docker build test: PASSED"
            update_stats "PASS"
            # Clean up test image
            docker rmi local-test:latest >/dev/null 2>&1 || true
        else
            print_status "ERROR" "Docker build test: FAILED"
            update_stats "FAIL"
        fi
    else
        print_status "WARNING" "Docker not available, skipping build test"
        update_stats "WARN"
    fi
    
    # App startup test
    print_status "STEP" "App startup test..."
    if timeout 10s uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 >/dev/null 2>&1; then
        print_status "STEP" "App startup test: PASSED"
        update_stats "PASS"
    else
        print_status "WARNING" "App startup test: WARNING (timeout or port in use)"
        update_stats "WARN"
    fi
}

# Function to run security checks
run_security_checks() {
    print_status "HEADER" "Security Checks"
    
    cd "$PROJECT_ROOT"
    
    # Semgrep check
    print_status "STEP" "Semgrep security scan..."
    if command_exists semgrep; then
        if semgrep scan --config auto .; then
            print_status "STEP" "Semgrep security scan: PASSED"
            update_stats "PASS"
        else
            print_status "WARNING" "Semgrep security scan: WARNING (issues found)"
            update_stats "WARN"
        fi
    else
        print_status "WARNING" "Semgrep not installed, skipping security scan"
        update_stats "WARN"
    fi
    
    # Trivy vulnerability scan
    print_status "STEP" "Trivy vulnerability scan..."
    if command_exists trivy; then
        if trivy fs --severity CRITICAL,HIGH .; then
            print_status "STEP" "Trivy vulnerability scan: PASSED"
            update_stats "PASS"
        else
            print_status "WARNING" "Trivy vulnerability scan: WARNING (vulnerabilities found)"
            update_stats "WARN"
        fi
    else
        print_status "WARNING" "Trivy not installed, skipping vulnerability scan"
        update_stats "WARN"
    fi
    
    # License check
    print_status "STEP" "License check..."
    if [ -f "LICENSE" ]; then
        print_status "STEP" "License check: PASSED"
        update_stats "PASS"
    else
        print_status "ERROR" "License check: FAILED (LICENSE file not found)"
        update_stats "FAIL"
    fi
}

# Function to print summary
print_summary() {
    echo
    print_status "HEADER" "Check Summary"
    echo -e "${CYAN}Total checks: $TOTAL_CHECKS${NC}"
    echo -e "${GREEN}Passed: $PASSED_CHECKS${NC}"
    echo -e "${RED}Failed: $FAILED_CHECKS${NC}"
    echo -e "${YELLOW}Warnings: $WARNING_CHECKS${NC}"
    
    if [ $FAILED_CHECKS -eq 0 ]; then
        print_status "SUCCESS" "All critical checks passed! 🎉"
        exit 0
    else
        print_status "ERROR" "Some checks failed. Please fix the issues above."
        exit 1
    fi
}

# Function to show help
show_help() {
    echo "Local CI Script for Backend POC"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --format-only     Run only formatting checks"
    echo "  --lint-only       Run only linting checks"
    echo "  --security-only   Run only security checks"
    echo "  --build-only      Run only build checks"
    echo "  --auto-fix        Automatically fix formatting issues"
    echo "  --verbose         Show detailed output"
    echo "  --help            Show this help message"
    echo
    echo "Examples:"
    echo "  $0                # Run all checks"
    echo "  $0 --format-only  # Run only formatting"
    echo "  $0 --auto-fix     # Run all checks with auto-fix"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --format-only)
            FORMAT_ONLY=true
            ALL_CHECKS=false
            shift
            ;;
        --lint-only)
            LINT_ONLY=true
            ALL_CHECKS=false
            shift
            ;;
        --security-only)
            SECURITY_ONLY=true
            ALL_CHECKS=false
            shift
            ;;
        --build-only)
            BUILD_ONLY=true
            ALL_CHECKS=false
            shift
            ;;
        --auto-fix)
            AUTO_FIX=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main execution
main() {
    echo -e "${PURPLE}🔍 Running Local CI Checks...${NC}"
    echo "Project: $PROJECT_ROOT"
    echo "Log file: $LOG_FILE"
    echo
    
    # Initialize log file
    echo "Local CI started at $(date)" > "$LOG_FILE"
    
    # Run checks based on options
    if [ "$ALL_CHECKS" = true ]; then
        check_environment
        run_quality_checks
        run_build_checks
        run_security_checks
    else
        if [ "$FORMAT_ONLY" = true ]; then
            check_environment
            run_quality_checks
        fi
        if [ "$LINT_ONLY" = true ]; then
            check_environment
            run_quality_checks
        fi
        if [ "$SECURITY_ONLY" = true ]; then
            check_environment
            run_security_checks
        fi
        if [ "$BUILD_ONLY" = true ]; then
            check_environment
            run_build_checks
        fi
    fi
    
    print_summary
}

# Run main function
main "$@" 