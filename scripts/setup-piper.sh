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

echo "🎙️  Audivox Piper TTS Setup"
echo "============================"

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

print_success "Docker is available"

# Create directories
print_info "Creating directories..."
mkdir -p models
mkdir -p audio-output
mkdir -p scripts/piper

print_success "Directories created"

# Build Piper Docker image
print_info "Building Piper TTS Docker image..."
docker build -f Dockerfile.piper -t audivox-piper:latest .

if [ $? -eq 0 ]; then
    print_success "Piper TTS Docker image built successfully"
else
    print_error "Failed to build Piper TTS Docker image"
    exit 1
fi

# Test Piper TTS
print_info "Testing Piper TTS..."
docker run --rm -v "$(pwd)/audio-output:/app/output" audivox-piper:latest

if [ $? -eq 0 ]; then
    print_success "Piper TTS test completed successfully"
else
    print_error "Piper TTS test failed"
    exit 1
fi

# Create local Piper installation script
print_info "Creating local Piper installation script..."
cat > scripts/piper/install-local.sh << 'EOF'
#!/bin/bash

# Install Piper TTS locally (without Docker)
echo "Installing Piper TTS locally..."

# Download latest release
LATEST_RELEASE=$(curl -s https://api.github.com/repos/rhasspy/piper/releases/latest | grep "tag_name" | cut -d '"' -f 4)
echo "Latest release: $LATEST_RELEASE"

# Download and extract
wget -O piper.tar.gz "https://github.com/rhasspy/piper/releases/download/${LATEST_RELEASE}/piper_linux_amd64.tar.gz"
tar -xzf piper.tar.gz
chmod +x piper
sudo mv piper /usr/local/bin/

# Clean up
rm piper.tar.gz

echo "Piper TTS installed successfully!"
piper --version
EOF

chmod +x scripts/piper/install-local.sh

# Create test script
print_info "Creating test script..."
cat > scripts/piper/test-piper.sh << 'EOF'
#!/bin/bash

echo "🎙️  Testing Piper TTS"
echo "====================="

# Test Portuguese
echo "Testing Portuguese..."
echo "Olá mundo! Este é um teste do Piper TTS em português." | \
docker run --rm -i -v "$(pwd)/audio-output:/app/output" audivox-piper:latest \
piper --model /app/models/pt_BR-hfc_pt-medium.onnx --output_file /app/output/test-pt.wav

# Test Spanish
echo "Testing Spanish..."
echo "Hola mundo! Este es una prueba de Piper TTS en español." | \
docker run --rm -i -v "$(pwd)/audio-output:/app/output" audivox-piper:latest \
piper --model /app/models/es_ES-carlfm-medium.onnx --output_file /app/output/test-es.wav

# Test English
echo "Testing English..."
echo "Hello world! This is a test of Piper TTS in English." | \
docker run --rm -i -v "$(pwd)/audio-output:/app/output" audivox-piper:latest \
piper --model /app/models/en_US-ryan-medium.onnx --output_file /app/output/test-en.wav

echo "✅ All tests completed! Check audio-output/ directory for generated files."
EOF

chmod +x scripts/piper/test-piper.sh

# Create usage script
print_info "Creating usage script..."
cat > scripts/piper/speak.sh << 'EOF'
#!/bin/bash

# Usage: ./speak.sh "text" "language" "output_file"
# Languages: pt, es, en

TEXT="$1"
LANGUAGE="$2"
OUTPUT_FILE="$3"

if [ -z "$TEXT" ] || [ -z "$LANGUAGE" ] || [ -z "$OUTPUT_FILE" ]; then
    echo "Usage: $0 \"text\" \"language\" \"output_file\""
    echo "Languages: pt, es, en"
    exit 1
fi

case $LANGUAGE in
    "pt")
        MODEL="/app/models/pt_BR-hfc_pt-medium.onnx"
        ;;
    "es")
        MODEL="/app/models/es_ES-carlfm-medium.onnx"
        ;;
    "en")
        MODEL="/app/models/en_US-ryan-medium.onnx"
        ;;
    *)
        echo "Invalid language. Use: pt, es, en"
        exit 1
        ;;
esac

echo "$TEXT" | docker run --rm -i -v "$(pwd)/audio-output:/app/output" audivox-piper:latest \
piper --model "$MODEL" --output_file "/app/output/$OUTPUT_FILE"

echo "Audio generated: audio-output/$OUTPUT_FILE"
EOF

chmod +x scripts/piper/speak.sh

# Update package.json with Piper scripts
print_info "Updating package.json with Piper scripts..."
cat >> package.json << 'EOF'
    "piper:build": "docker build -f Dockerfile.piper -t audivox-piper:latest .",
    "piper:test": "./scripts/piper/test-piper.sh",
    "piper:speak": "./scripts/piper/speak.sh",
    "piper:install": "./scripts/piper/install-local.sh"
EOF

print_success "Piper TTS setup completed successfully!"
print_info "Available commands:"
echo "  • npm run piper:build  - Build Docker image"
echo "  • npm run piper:test   - Test all languages"
echo "  • npm run piper:speak  - Generate speech"
echo "  • npm run piper:install - Install locally"

print_info "Test the setup:"
echo "  ./scripts/piper/test-piper.sh"

print_info "Generate speech:"
echo "  ./scripts/piper/speak.sh \"Hello world\" \"en\" \"hello.wav\""
