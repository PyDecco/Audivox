#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

echo "🎙️  Installing Piper TTS Locally"
echo "================================="

# Check if piper is already installed
if command -v piper &> /dev/null; then
    print_warning "Piper TTS is already installed"
    piper --version
    exit 0
fi

# Download latest release
print_info "Downloading Piper TTS..."
LATEST_RELEASE="2023.11.14-2"
DOWNLOAD_URL="https://github.com/rhasspy/piper/releases/download/${LATEST_RELEASE}/piper_linux_x86_64.tar.gz"

wget -O piper.tar.gz "$DOWNLOAD_URL"

if [ $? -eq 0 ]; then
    print_success "Download completed"
else
    print_error "Download failed"
    exit 1
fi

# Extract and install
print_info "Extracting and installing..."
tar -xzf piper.tar.gz
sudo cp piper/piper /usr/local/bin/
sudo chmod +x /usr/local/bin/piper

# Clean up
rm -rf piper.tar.gz piper

# Verify installation
if command -v piper &> /dev/null; then
    print_success "Piper TTS installed successfully!"
    piper --version
else
    print_error "Installation failed"
    exit 1
fi

print_info "Next steps:"
echo "  1. Download models: npm run piper:download"
echo "  2. Test installation: npm run piper:test"
