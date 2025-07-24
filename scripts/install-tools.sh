#!/bin/bash

# Install Development Tools Script
# This script installs all necessary tools for local development and CI

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    esac
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install on macOS
install_macos() {
    print_status "INFO" "Installing tools on macOS..."
    
    # Check if Homebrew is installed
    if ! command_exists brew; then
        print_status "INFO" "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install Python 3.11+
    if ! command_exists python3.11; then
        print_status "INFO" "Installing Python 3.11..."
        brew install python@3.11
    fi
    
    # Install Docker
    if ! command_exists docker; then
        print_status "INFO" "Installing Docker..."
        brew install --cask docker
        print_status "WARNING" "Please start Docker Desktop manually"
    fi
    
    # Install hadolint
    if ! command_exists hadolint; then
        print_status "INFO" "Installing hadolint..."
        brew install hadolint
    fi
    
    # Install semgrep
    if ! command_exists semgrep; then
        print_status "INFO" "Installing semgrep..."
        brew install semgrep
    fi
    
    # Install trivy
    if ! command_exists trivy; then
        print_status "INFO" "Installing trivy..."
        brew install trivy
    fi
}

# Function to install on Linux
install_linux() {
    print_status "INFO" "Installing tools on Linux..."
    
    # Detect package manager
    if command_exists apt; then
        PKG_MANAGER="apt"
        UPDATE_CMD="sudo apt update"
        INSTALL_CMD="sudo apt install -y"
    elif command_exists yum; then
        PKG_MANAGER="yum"
        UPDATE_CMD="sudo yum update -y"
        INSTALL_CMD="sudo yum install -y"
    elif command_exists dnf; then
        PKG_MANAGER="dnf"
        UPDATE_CMD="sudo dnf update -y"
        INSTALL_CMD="sudo dnf install -y"
    else
        print_status "ERROR" "Unsupported package manager"
        exit 1
    fi
    
    # Update package list
    print_status "INFO" "Updating package list..."
    eval "$UPDATE_CMD"
    
    # Install Python 3.11+
    if ! command_exists python3.11; then
        print_status "INFO" "Installing Python 3.11..."
        eval "$INSTALL_CMD python3.11 python3.11-pip"
    fi
    
    # Install Docker
    if ! command_exists docker; then
        print_status "INFO" "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
        print_status "WARNING" "Please log out and back in for Docker group changes to take effect"
    fi
    
    # Install hadolint
    if ! command_exists hadolint; then
        print_status "INFO" "Installing hadolint..."
        wget -O /tmp/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64
        sudo chmod +x /tmp/hadolint
        sudo mv /tmp/hadolint /usr/local/bin/hadolint
    fi
    
    # Install semgrep
    if ! command_exists semgrep; then
        print_status "INFO" "Installing semgrep..."
        python3 -m pip install semgrep
    fi
    
    # Install trivy
    if ! command_exists trivy; then
        print_status "INFO" "Installing trivy..."
        wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
        echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
        sudo apt update
        sudo apt install -y trivy
    fi
}

# Function to install uv
install_uv() {
    if ! command_exists uv; then
        print_status "INFO" "Installing uv package manager..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.cargo/bin:$PATH"
        print_status "SUCCESS" "uv installed successfully"
    else
        print_status "SUCCESS" "uv already installed"
    fi
}

# Function to verify installations
verify_installations() {
    print_status "INFO" "Verifying installations..."
    
    local all_installed=true
    
    # Check Python
    if command_exists python3.11; then
        print_status "SUCCESS" "Python 3.11: $(python3.11 --version)"
    else
        print_status "ERROR" "Python 3.11 not found"
        all_installed=false
    fi
    
    # Check uv
    if command_exists uv; then
        print_status "SUCCESS" "uv: $(uv --version)"
    else
        print_status "ERROR" "uv not found"
        all_installed=false
    fi
    
    # Check Docker
    if command_exists docker; then
        print_status "SUCCESS" "Docker: $(docker --version)"
    else
        print_status "ERROR" "Docker not found"
        all_installed=false
    fi
    
    # Check hadolint
    if command_exists hadolint; then
        print_status "SUCCESS" "hadolint: $(hadolint --version | head -n1)"
    else
        print_status "WARNING" "hadolint not found"
    fi
    
    # Check semgrep
    if command_exists semgrep; then
        print_status "SUCCESS" "semgrep: $(semgrep --version | head -n1)"
    else
        print_status "WARNING" "semgrep not found"
    fi
    
    # Check trivy
    if command_exists trivy; then
        print_status "SUCCESS" "trivy: $(trivy --version | head -n1)"
    else
        print_status "WARNING" "trivy not found"
    fi
    
    if [ "$all_installed" = true ]; then
        print_status "SUCCESS" "All required tools installed successfully!"
    else
        print_status "ERROR" "Some required tools are missing"
        exit 1
    fi
}

# Main execution
main() {
    echo -e "${BLUE}🔧 Installing Development Tools...${NC}"
    echo
    
    # Detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        install_macos
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        install_linux
    else
        print_status "ERROR" "Unsupported operating system: $OSTYPE"
        exit 1
    fi
    
    # Install uv (cross-platform)
    install_uv
    
    # Verify installations
    verify_installations
    
    echo
    print_status "SUCCESS" "Installation completed! You can now run the local CI script."
    echo "Run: ./scripts/local-ci.sh --help for usage information"
}

# Run main function
main "$@" 