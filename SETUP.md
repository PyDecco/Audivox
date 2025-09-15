# 🚀 Audivox - Setup do Ambiente de Desenvolvimento

## 📋 Pré-requisitos

### 1. Docker e Docker Compose
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose

# Ou instalar Docker Desktop
# https://www.docker.com/products/docker-desktop
```

### 2. Verificar Instalação
```bash
docker --version
docker-compose --version
```

## 🛠️ Setup Automático

### 1. Executar Script de Setup
```bash
./scripts/setup.sh
```

Este script irá:
- ✅ Verificar se Docker está instalado
- ✅ Criar arquivo `.env` se não existir
- ✅ Iniciar todos os serviços
- ✅ Verificar saúde dos serviços
- ✅ Mostrar URLs dos serviços

### 2. Verificar Saúde dos Serviços
```bash
./scripts/health-check.sh
```

## 🐳 Serviços Incluídos

### 📊 Observabilidade
- **Prometheus**: http://localhost:9090 (Métricas)
- **Grafana**: http://localhost:3001 (Dashboards - admin/admin123)
- **Loki**: http://localhost:3100 (Logs)

### 🗄️ Dados
- **PostgreSQL**: localhost:5432 (audivox/audivox123)
- **Redis**: localhost:6379 (Cache)

## 🔧 Comandos Úteis

### Gerenciar Serviços
```bash
# Iniciar serviços
docker-compose up -d

# Parar serviços
docker-compose down

# Ver logs
docker-compose logs -f

# Reiniciar serviços
docker-compose restart

# Ver status
docker-compose ps
```

### Banco de Dados (Prisma)
```bash
# Gerar cliente Prisma
npm run db:generate

# Criar/atualizar tabelas
npm run db:push

# Criar migração
npm run db:migrate

# Abrir Prisma Studio
npm run db:studio

# Popular banco com dados de exemplo
npm run db:seed

# Conectar ao PostgreSQL (se necessário)
docker-compose exec postgres psql -U audivox -d audivox

# Ver tabelas
docker-compose exec postgres psql -U audivox -d audivox -c "\dt"

# Backup do banco
docker-compose exec postgres pg_dump -U audivox audivox > backup.sql
```

### Redis
```bash
# Conectar ao Redis
docker-compose exec redis redis-cli

# Ver informações
docker-compose exec redis redis-cli info
```

## 🏥 Health Checks

### Verificar Serviços Individuais
```bash
# PostgreSQL
docker-compose exec postgres pg_isready -U audivox -d audivox

# Redis
docker-compose exec redis redis-cli ping

# Prometheus
curl http://localhost:9090/-/healthy

# Grafana
curl http://localhost:3001/api/health

# Loki
curl http://localhost:3100/ready
```

## 🐛 Troubleshooting

### Problemas Comuns

#### 1. Porta já em uso
```bash
# Verificar portas em uso
sudo netstat -tulpn | grep :5432
sudo netstat -tulpn | grep :9090

# Parar serviços conflitantes
sudo systemctl stop postgresql
```

#### 2. Permissões Docker
```bash
# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
# Logout e login novamente
```

#### 3. Volumes Docker
```bash
# Limpar volumes (CUIDADO: apaga dados)
docker-compose down -v
docker volume prune
```

#### 4. Logs de Erro
```bash
# Ver logs detalhados
docker-compose logs postgres
docker-compose logs redis
docker-compose logs prometheus
```

## 📁 Estrutura Criada

```
audivox/
├── docker-compose.yml          # Orquestração de serviços
├── .env                        # Variáveis de ambiente
├── env.example                 # Exemplo de configuração
├── config/
│   ├── prometheus.yml          # Configuração Prometheus
│   ├── loki-config.yml         # Configuração Loki
│   └── grafana/
│       └── provisioning/      # Configuração Grafana
├── scripts/
│   ├── setup.sh               # Script de setup
│   ├── health-check.sh         # Script de health check
│   └── init-db.sql            # Inicialização do banco
└── SETUP.md                   # Este arquivo
```

## ✅ Próximos Passos

Após o setup do ambiente:

1. **Instalar dependências**: `npm install`
2. **Configurar banco**: `npm run db:push` e `npm run db:seed`
3. **INFRA-002**: Configurar Supabase
4. **INFRA-003**: Setup do Piper TTS
5. **BACK-001**: Criar projeto NestJS
6. **FRONT-001**: Criar projeto Next.js

## 🆘 Suporte

Se encontrar problemas:
1. Execute `./scripts/health-check.sh`
2. Verifique os logs: `docker-compose logs -f`
3. Consulte a documentação técnica em `docs/technical/`
