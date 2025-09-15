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

echo "🚀 Audivox Supabase Setup"
echo "========================="

# Check if .env file exists
if [ ! -f .env ]; then
    print_error ".env file not found. Please run './scripts/setup.sh' first."
    exit 1
fi

# Load environment variables
source .env

print_info "Checking Supabase configuration..."

# Check if Supabase variables are set
if [ -z "$SUPABASE_URL" ] || [ "$SUPABASE_URL" = "https://your-project.supabase.co" ]; then
    print_warning "SUPABASE_URL not configured in .env file"
    echo "Please update .env with your Supabase project URL:"
    echo "SUPABASE_URL=https://your-project-id.supabase.co"
    exit 1
fi

if [ -z "$SUPABASE_ANON_KEY" ] || [ "$SUPABASE_ANON_KEY" = "your-anon-key-here" ]; then
    print_warning "SUPABASE_ANON_KEY not configured in .env file"
    echo "Please update .env with your Supabase anon key"
    exit 1
fi

if [ -z "$SUPABASE_SERVICE_ROLE_KEY" ] || [ "$SUPABASE_SERVICE_ROLE_KEY" = "your-service-role-key-here" ]; then
    print_warning "SUPABASE_SERVICE_ROLE_KEY not configured in .env file"
    echo "Please update .env with your Supabase service role key"
    exit 1
fi

print_success "Supabase configuration found in .env"

# Install Supabase CLI if not present
if ! command -v supabase &> /dev/null; then
    print_info "Installing Supabase CLI..."
    
    # Detect OS and install accordingly
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        curl -fsSL https://github.com/supabase/cli/releases/latest/download/supabase_linux_amd64.tar.gz | tar -xz
        sudo mv supabase /usr/local/bin/
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install supabase/tap/supabase
    else
        print_error "Unsupported OS. Please install Supabase CLI manually."
        exit 1
    fi
    
    print_success "Supabase CLI installed"
else
    print_success "Supabase CLI already installed"
fi

# Check Supabase CLI version
SUPABASE_VERSION=$(supabase --version | head -n1)
print_info "Supabase CLI version: $SUPABASE_VERSION"

# Test connection to Supabase
print_info "Testing connection to Supabase..."

# Create a simple test script
cat > test-supabase.js << 'EOF'
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error('❌ Supabase configuration missing');
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function testConnection() {
    try {
        // Test basic connection
        const { data, error } = await supabase.from('files').select('count').limit(1);
        
        if (error) {
            console.error('❌ Supabase connection failed:', error.message);
            process.exit(1);
        }
        
        console.log('✅ Supabase connection successful');
        
        // Test storage bucket
        const { data: buckets, error: bucketError } = await supabase.storage.listBuckets();
        
        if (bucketError) {
            console.error('❌ Storage access failed:', bucketError.message);
            process.exit(1);
        }
        
        const audivoxBucket = buckets.find(bucket => bucket.name === 'audivox-files');
        
        if (!audivoxBucket) {
            console.log('⚠️  Storage bucket "audivox-files" not found');
            console.log('   Available buckets:', buckets.map(b => b.name).join(', '));
        } else {
            console.log('✅ Storage bucket "audivox-files" found');
        }
        
    } catch (err) {
        console.error('❌ Connection test failed:', err.message);
        process.exit(1);
    }
}

testConnection();
EOF

# Install required dependencies for test
print_info "Installing test dependencies..."
npm install @supabase/supabase-js dotenv

# Run the test
print_info "Running Supabase connection test..."
node test-supabase.js

# Clean up test file
rm test-supabase.js

print_success "Supabase setup completed successfully!"
print_info "Next steps:"
echo "  1. Run migrations: npm run db:migrate"
echo "  2. Test storage: npm run test:supabase"
echo "  3. Start development: npm run dev"

print_info "Supabase URLs:"
echo "  • Dashboard: https://supabase.com/dashboard"
echo "  • API URL: $SUPABASE_URL"
echo "  • Storage: $SUPABASE_URL/storage/v1"
