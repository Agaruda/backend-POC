#!/bin/bash

# Quick Format Script
# This script quickly formats code using Black

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${GREEN}🎨 Formatting code with Black...${NC}"

cd "$PROJECT_ROOT"

# Check if uv is available
if command -v uv >/dev/null 2>&1; then
    echo "Using uv to run Black..."
    uv run black .
else
    echo -e "${YELLOW}uv not found, trying direct black...${NC}"
    if command -v black >/dev/null 2>&1; then
        black .
    else
        echo "Black not found. Please install it first:"
        echo "pip install black"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Code formatting completed!${NC}" 