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

echo "📥 Downloading Piper TTS Models"
echo "==============================="

# Create models directory
mkdir -p models

# Function to download model
download_model() {
    local model_name="$1"
    local model_url="$2"
    local config_url="$3"
    
    print_info "Downloading $model_name..."
    
    # Download model file
    if wget -O "models/${model_name}.onnx" "$model_url"; then
        print_success "Downloaded ${model_name}.onnx"
    else
        print_error "Failed to download ${model_name}.onnx"
        return 1
    fi
    
    # Download config file
    if wget -O "models/${model_name}.onnx.json" "$config_url"; then
        print_success "Downloaded ${model_name}.onnx.json"
    else
        print_error "Failed to download ${model_name}.onnx.json"
        return 1
    fi
}

# Download Portuguese model
download_model "pt_BR-hfc_pt-medium" \
    "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/pt/pt_BR/hfc_pt/medium/pt_BR-hfc_pt-medium.onnx" \
    "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/pt/pt_BR/hfc_pt/medium/pt_BR-hfc_pt-medium.onnx.json"

# Download Spanish model
download_model "es_ES-carlfm-medium" \
    "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/es/es_ES/carlfm/medium/es_ES-carlfm-medium.onnx" \
    "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/es/es_ES/carlfm/medium/es_ES-carlfm-medium.onnx.json"

# Download English model
download_model "en_US-ryan-medium" \
    "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/ryan/medium/en_US-ryan-medium.onnx" \
    "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/ryan/medium/en_US-ryan-medium.onnx.json"

print_success "All models downloaded successfully!"
print_info "Models available:"
ls -la models/

print_info "Test the models:"
echo "  docker run --rm -v \"\$(pwd)/models:/app/models\" -v \"\$(pwd)/audio-output:/app/output\" audivox-piper:latest piper --model /app/models/pt_BR-hfc_pt-medium.onnx --output_file /app/output/test.wav"
