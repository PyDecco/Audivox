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

# Usage: ./speak.sh "text" "language" "output_file"
# Languages: pt, es, en

TEXT="$1"
LANGUAGE="$2"
OUTPUT_FILE="$3"

if [ -z "$TEXT" ] || [ -z "$LANGUAGE" ] || [ -z "$OUTPUT_FILE" ]; then
    echo "Usage: $0 \"text\" \"language\" \"output_file\""
    echo "Languages: pt, es, en"
    echo ""
    echo "Examples:"
    echo "  $0 \"Hello world\" \"en\" \"hello.wav\""
    echo "  $0 \"Olá mundo\" \"pt\" \"ola.wav\""
    echo "  $0 \"Hola mundo\" \"es\" \"hola.wav\""
    exit 1
fi

# Check if piper is installed
if ! command -v piper &> /dev/null; then
    print_error "Piper TTS is not installed. Run: npm run piper:install"
    exit 1
fi

# Create output directory
mkdir -p audio-output

# Select model based on language
case $LANGUAGE in
    "pt")
        MODEL="models/pt_BR-hfc_pt-medium.onnx"
        ;;
    "es")
        MODEL="models/es_ES-carlfm-medium.onnx"
        ;;
    "en")
        MODEL="models/en_US-ryan-medium.onnx"
        ;;
    *)
        print_error "Invalid language. Use: pt, es, en"
        exit 1
        ;;
esac

# Check if model exists
if [ ! -f "$MODEL" ]; then
    print_error "Model not found: $MODEL"
    print_info "Download models first: npm run piper:download"
    exit 1
fi

print_info "Generating speech..."
print_info "Text: $TEXT"
print_info "Language: $LANGUAGE"
print_info "Model: $MODEL"
print_info "Output: audio-output/$OUTPUT_FILE"

# Generate speech
echo "$TEXT" | piper --model "$MODEL" --output_file "audio-output/$OUTPUT_FILE"

if [ -f "audio-output/$OUTPUT_FILE" ]; then
    print_success "Audio generated successfully: audio-output/$OUTPUT_FILE"
    
    # Show file info
    FILE_SIZE=$(ls -lh "audio-output/$OUTPUT_FILE" | awk '{print $5}')
    print_info "File size: $FILE_SIZE"
else
    print_error "Failed to generate audio"
    exit 1
fi
