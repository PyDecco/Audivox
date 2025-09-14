#!/bin/bash

# Audivox Health Check Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check Docker services
check_docker_services() {
    print_status "Checking Docker services..."
    
    if ! docker-compose ps | grep -q "Up"; then
        print_error "Docker services are not running"
        return 1
    fi
    
    print_success "Docker services are running"
}

# Check PostgreSQL
check_postgres() {
    print_status "Checking PostgreSQL..."
    
    if docker-compose exec -T postgres pg_isready -U audivox -d audivox > /dev/null 2>&1; then
        print_success "PostgreSQL is healthy"
        
        # Check if Prisma tables exist
        if docker-compose exec -T postgres psql -U audivox -d audivox -c "\dt" | grep -q "files"; then
            print_success "Database tables are created"
        else
            print_warning "Database tables not found - run 'pnpm db:push' to create them"
        fi
    else
        print_error "PostgreSQL is not healthy"
        return 1
    fi
}

# Check Redis
check_redis() {
    print_status "Checking Redis..."
    
    if docker-compose exec -T redis redis-cli ping | grep -q PONG; then
        print_success "Redis is healthy"
    else
        print_error "Redis is not healthy"
        return 1
    fi
}

# Check Prometheus
check_prometheus() {
    print_status "Checking Prometheus..."
    
    if curl -s http://localhost:9090/-/healthy > /dev/null 2>&1; then
        print_success "Prometheus is healthy"
        
        # Check if it's scraping targets
        targets=$(curl -s http://localhost:9090/api/v1/targets | jq -r '.data.activeTargets | length' 2>/dev/null || echo "0")
        print_status "Prometheus is monitoring $targets targets"
    else
        print_error "Prometheus is not healthy"
        return 1
    fi
}

# Check Grafana
check_grafana() {
    print_status "Checking Grafana..."
    
    if curl -s http://localhost:3001/api/health > /dev/null 2>&1; then
        print_success "Grafana is healthy"
    else
        print_error "Grafana is not healthy"
        return 1
    fi
}

# Check Loki
check_loki() {
    print_status "Checking Loki..."
    
    if curl -s http://localhost:3100/ready > /dev/null 2>&1; then
        print_success "Loki is healthy"
    else
        print_error "Loki is not healthy"
        return 1
    fi
}

# Check network connectivity
check_network() {
    print_status "Checking network connectivity..."
    
    # Check if services can communicate
    if docker-compose exec -T postgres ping -c 1 redis > /dev/null 2>&1; then
        print_success "Services can communicate"
    else
        print_warning "Network connectivity issues detected"
    fi
}

# Show service status
show_status() {
    echo ""
    print_status "📊 Service Status Summary:"
    echo ""
    docker-compose ps
    echo ""
    
    print_status "🌐 Service URLs:"
    echo "  • Prometheus: http://localhost:9090"
    echo "  • Grafana: http://localhost:3001"
    echo "  • PostgreSQL: localhost:5432"
    echo "  • Redis: localhost:6379"
    echo "  • Loki: http://localhost:3100"
    echo ""
}

# Main health check
main() {
    echo "🏥 Audivox Health Check"
    echo "========================"
    echo ""
    
    local exit_code=0
    
    check_docker_services || exit_code=1
    check_postgres || exit_code=1
    check_redis || exit_code=1
    check_prometheus || exit_code=1
    check_grafana || exit_code=1
    check_loki || exit_code=1
    check_network || exit_code=1
    
    show_status
    
    if [ $exit_code -eq 0 ]; then
        print_success "🎉 All services are healthy!"
    else
        print_error "❌ Some services are not healthy"
    fi
    
    exit $exit_code
}

# Run main function
main "$@"
