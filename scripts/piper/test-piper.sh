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

echo "🎙️  Testing Piper TTS"
echo "===================="

# Check if piper is installed
if ! command -v piper &> /dev/null; then
    print_error "Piper TTS is not installed. Run: npm run piper:install"
    exit 1
fi

print_success "Piper TTS is installed"
piper --version

# Create output directory
mkdir -p audio-output

# Check if models exist
if [ ! -d "models" ]; then
    print_warning "Models directory not found. Run: npm run piper:download"
    exit 1
fi

# Test Portuguese
if [ -f "models/pt_BR-hfc_pt-medium.onnx" ]; then
    print_info "Testing Portuguese..."
    echo "Olá mundo! Este é um teste do Piper TTS em português." | \
    piper --model models/pt_BR-hfc_pt-medium.onnx --output_file audio-output/test-pt.wav
    
    if [ -f "audio-output/test-pt.wav" ]; then
        print_success "Portuguese test completed: audio-output/test-pt.wav"
    else
        print_error "Portuguese test failed"
    fi
else
    print_warning "Portuguese model not found"
fi

# Test Spanish
if [ -f "models/es_ES-carlfm-medium.onnx" ]; then
    print_info "Testing Spanish..."
    echo "Hola mundo! Este es una prueba de Piper TTS en español." | \
    piper --model models/es_ES-carlfm-medium.onnx --output_file audio-output/test-es.wav
    
    if [ -f "audio-output/test-es.wav" ]; then
        print_success "Spanish test completed: audio-output/test-es.wav"
    else
        print_error "Spanish test failed"
    fi
else
    print_warning "Spanish model not found"
fi

# Test English
if [ -f "models/en_US-ryan-medium.onnx" ]; then
    print_info "Testing English..."
    echo "Hello world! This is a test of Piper TTS in English." | \
    piper --model models/en_US-ryan-medium.onnx --output_file audio-output/test-en.wav
    
    if [ -f "audio-output/test-en.wav" ]; then
        print_success "English test completed: audio-output/test-en.wav"
    else
        print_error "English test failed"
    fi
else
    print_warning "English model not found"
fi

print_info "Test results:"
ls -la audio-output/

print_success "All tests completed!"
print_info "Listen to the generated files in audio-output/ directory"
