#!/bin/bash

# Audivox Development Environment Setup Script
set -e

echo "🚀 Setting up Audivox development environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
check_docker() {
    print_status "Checking Docker installation..."
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_success "Docker and Docker Compose are installed"
}

# Check if .env file exists
check_env() {
    print_status "Checking environment configuration..."
    if [ ! -f .env ]; then
        print_warning ".env file not found. Creating from .env.example..."
        if [ -f .env.example ]; then
            cp .env.example .env
            print_success ".env file created from .env.example"
        else
            print_error ".env.example file not found. Please create it first."
            exit 1
        fi
    else
        print_success ".env file exists"
    fi
}

# Start services
start_services() {
    print_status "Starting development services..."
    docker-compose up -d
    
    print_status "Waiting for services to be ready..."
    sleep 10
    
    # Check service health
    check_service_health
}

# Check service health
check_service_health() {
    print_status "Checking service health..."
    
    # Check PostgreSQL
    if docker-compose exec postgres pg_isready -U audivox -d audivox; then
        print_success "PostgreSQL is ready"
    else
        print_error "PostgreSQL is not ready"
        return 1
    fi
    
    # Check Redis
    if docker-compose exec redis redis-cli ping | grep -q PONG; then
        print_success "Redis is ready"
    else
        print_error "Redis is not ready"
        return 1
    fi
    
    # Check Prometheus
    if curl -s http://localhost:9090/-/healthy > /dev/null; then
        print_success "Prometheus is ready"
    else
        print_error "Prometheus is not ready"
        return 1
    fi
    
    # Check Grafana
    if curl -s http://localhost:3001/api/health > /dev/null; then
        print_success "Grafana is ready"
    else
        print_error "Grafana is not ready"
        return 1
    fi
}

# Show service URLs
show_urls() {
    echo ""
    print_success "🎉 Development environment is ready!"
    echo ""
    echo "📊 Service URLs:"
    echo "  • Prometheus: http://localhost:9090"
    echo "  • Grafana: http://localhost:3001 (admin/admin123)"
    echo "  • PostgreSQL: localhost:5432 (audivox/audivox123)"
    echo "  • Redis: localhost:6379"
    echo "  • Loki: http://localhost:3100"
    echo ""
    echo "🔧 Useful commands:"
    echo "  • View logs: docker-compose logs -f"
    echo "  • Stop services: docker-compose down"
    echo "  • Restart services: docker-compose restart"
    echo "  • Check status: docker-compose ps"
    echo ""
}

# Main execution
main() {
    check_docker
    check_env
    start_services
    show_urls
}

# Run main function
main "$@"
