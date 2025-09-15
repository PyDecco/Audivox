# 🧪 Checklist de Teste do Ambiente de Desenvolvimento

## ✅ Pré-requisitos
- [ ] Docker instalado (`docker --version`)
- [ ] Docker Compose instalado (`docker compose version`)
- [ ] Node.js instalado (`node --version`)
- [ ] npm instalado (`npm --version`)

## 🐳 Teste 1: Serviços Docker
```bash
# Iniciar serviços
sudo docker compose up -d

# Verificar status
sudo docker compose ps

# Verificar logs se necessário
sudo docker compose logs
```

**Resultado esperado:** Todos os serviços com status "Up" e "healthy"

## 🗄️ Teste 2: PostgreSQL
```bash
# Conectar ao banco
sudo docker compose exec postgres psql -U audivox -d audivox

# Dentro do psql, executar:
\dt
SELECT version();
\q
```

**Resultado esperado:** Conexão bem-sucedida, sem tabelas ainda

## 🔴 Teste 3: Redis
```bash
# Conectar ao Redis
sudo docker compose exec redis redis-cli

# Dentro do redis-cli, executar:
PING
INFO
QUIT
```

**Resultado esperado:** Resposta "PONG" e informações do Redis

## 📊 Teste 4: Prometheus
```bash
# Verificar se está respondendo
curl http://localhost:9090/-/healthy

# Verificar métricas
curl http://localhost:9090/metrics
```

**Resultado esperado:** Status 200 e métricas em formato Prometheus

## 📈 Teste 5: Grafana
```bash
# Verificar se está respondendo
curl http://localhost:3001/api/health

# Acessar no navegador
# http://localhost:3001
# Login: admin / admin
```

**Resultado esperado:** Status 200 e interface Grafana carregando

## 📝 Teste 6: Loki
```bash
# Verificar se está respondendo
curl http://localhost:3100/ready

# Verificar métricas
curl http://localhost:3100/metrics
```

**Resultado esperado:** Status 200 e métricas Loki

## 📦 Teste 7: Dependências Node.js
```bash
# Instalar dependências
npm install

# Verificar se instalou corretamente
npm list
```

**Resultado esperado:** Todas as dependências instaladas sem erros

## 🗄️ Teste 8: Prisma
```bash
# Gerar cliente Prisma
npm run db:generate

# Criar tabelas no banco
npm run db:push

# Verificar tabelas criadas
sudo docker compose exec postgres psql -U audivox -d audivox -c "\dt"
```

**Resultado esperado:** Cliente gerado e tabelas criadas (files, readings, audio_chunks)

## 🌱 Teste 9: Seed do Banco
```bash
# Executar seed
npm run db:seed

# Verificar dados inseridos
sudo docker compose exec postgres psql -U audivox -d audivox -c "SELECT COUNT(*) FROM files;"
sudo docker compose exec postgres psql -U audivox -d audivox -c "SELECT COUNT(*) FROM readings;"
```

**Resultado esperado:** 1 arquivo e 1 leitura inseridos

## 🛠️ Teste 10: Prisma Studio
```bash
# Abrir Prisma Studio (em terminal separado)
npm run db:studio
```

**Resultado esperado:** Interface web carregando em http://localhost:5555

## 🩺 Teste 11: Health Check Automatizado
```bash
# Executar script de health check
./scripts/health-check.sh
```

**Resultado esperado:** Todos os checks passando com ✅

## 🧹 Teste 12: Limpeza
```bash
# Parar serviços
sudo docker compose down

# Remover volumes (opcional)
sudo docker compose down -v
```

---

## 🎯 Critérios de Sucesso

**✅ AMBIENTE PRONTO quando:**
- Todos os serviços Docker estão "healthy"
- PostgreSQL aceita conexões
- Redis responde PONG
- Prometheus/Grafana/Loki estão acessíveis
- Prisma cria tabelas sem erro
- Seed executa com sucesso
- Health check passa 100%

**❌ FALHA se:**
- Qualquer serviço não inicia
- Conexões de banco falham
- Prisma não consegue conectar
- Health check retorna erro

---

## 🚀 Próximo Passo

**Se todos os testes passarem:** ✅ INFRA-001 CONCLUÍDA
**Próxima história:** INFRA-002: Configuração do Supabase
