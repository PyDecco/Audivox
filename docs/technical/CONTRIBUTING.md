# Guia de Fluxo de Desenvolvimento - Audivox

## Visão Geral

Este guia descreve o processo de desenvolvimento do Audivox, incluindo configuração do ambiente, fluxo de trabalho, testes e deploy. O projeto segue um fluxo enxuto e descomplicado, adequado para desenvolvimento rápido de MVP.

## Configuração do Ambiente

### Pré-requisitos
- **Node.js**: v18+ (recomendado v20)
- **pnpm**: v8+ (gerenciador de pacotes)
- **Docker**: v20+ (para serviços de infraestrutura)
- **Git**: v2.30+
- **Linux**: Ubuntu 20.04+ ou equivalente

### Instalação de Dependências

#### 1. Clonar o Repositório
```bash
git clone https://github.com/your-username/audivox.git
cd audivox
```

#### 2. Instalar pnpm
```bash
npm install -g pnpm
```

#### 3. Instalar Dependências
```bash
pnpm install
```

#### 4. Configurar Variáveis de Ambiente
```bash
cp .env.example .env
# Editar .env com suas configurações
```

#### 5. Configurar Piper TTS
```bash
# Baixar binário do Piper
wget https://github.com/rhasspy/piper/releases/latest/download/piper_linux_amd64.tar.gz
tar -xzf piper_linux_amd64.tar.gz

# Baixar modelos ONNX
mkdir -p models
# Baixar modelos para pt_BR, es_ES, en_US
```

#### 6. Configurar Supabase
```bash
# Criar projeto no Supabase
# Configurar variáveis de ambiente
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-key
```

### Estrutura do Workspace
```
audivox/
├── apps/
│   ├── server/          # NestJS API
│   ├── web/             # Next.js Frontend
│   └── mobile/          # Flutter App (futuro)
├── packages/
│   └── shared/          # DTOs compartilhados
├── tools/               # Scripts DevOps
├── docker-compose.yml   # Serviços de infraestrutura
└── package.json         # Configuração do workspace
```

## Fluxo de Desenvolvimento

### Estratégia de Branches
- **main**: Branch principal (produção)
- **develop**: Branch de desenvolvimento
- **feature/**: Features individuais
- **hotfix/**: Correções urgentes

### Processo de Desenvolvimento

#### 1. Criar Branch de Feature
```bash
git checkout develop
git pull origin develop
git checkout -b feature/nova-funcionalidade
```

#### 2. Desenvolver Feature
```bash
# Fazer alterações no código
# Escrever testes
# Atualizar documentação
```

#### 3. Testes Locais
```bash
# Testes unitários
pnpm test

# Testes de integração
pnpm test:integration

# Testes E2E
pnpm test:e2e

# Linting
pnpm lint

# Formatação
pnpm format
```

#### 4. Commit e Push
```bash
git add .
git commit -m "feat: add nova funcionalidade"
git push origin feature/nova-funcionalidade
```

#### 5. Pull Request
- Criar PR para `develop`
- Incluir descrição detalhada
- Referenciar issues relacionadas
- Aguardar review e aprovação

#### 6. Merge
- Após aprovação, fazer merge
- Deletar branch de feature
- Atualizar branch local

### Convenções de Commit

#### Formato
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

#### Tipos
- **feat**: Nova funcionalidade
- **fix**: Correção de bug
- **docs**: Documentação
- **style**: Formatação de código
- **refactor**: Refatoração
- **test**: Testes
- **chore**: Tarefas de manutenção

#### Exemplos
```bash
feat(api): add file upload endpoint
fix(tts): resolve Piper timeout issue
docs(readme): update installation instructions
test(unit): add tests for TtsService
chore(deps): update dependencies
```

## Configuração de Desenvolvimento

### Scripts Disponíveis

#### Desenvolvimento
```bash
# Iniciar servidor em modo dev
pnpm dev:server

# Iniciar frontend em modo dev
pnpm dev:web

# Iniciar ambos simultaneamente
pnpm dev

# Iniciar com hot reload
pnpm dev:watch
```

#### Testes
```bash
# Testes unitários
pnpm test

# Testes com coverage
pnpm test:cov

# Testes de integração
pnpm test:integration

# Testes E2E
pnpm test:e2e

# Testes específicos
pnpm test -- --testNamePattern="TtsService"
```

#### Build
```bash
# Build de produção
pnpm build

# Build específico
pnpm build:server
pnpm build:web

# Build com otimizações
pnpm build:prod
```

#### Linting e Formatação
```bash
# Linting
pnpm lint

# Linting com correção
pnpm lint:fix

# Formatação
pnpm format

# Verificação de tipos
pnpm type-check
```

### Configuração do IDE

#### VS Code
```json
{
  "recommendations": [
    "ms-vscode.vscode-typescript-next",
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-eslint",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-json"
  ],
  "settings": {
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll.eslint": true
    },
    "typescript.preferences.importModuleSpecifier": "relative"
  }
}
```

#### Extensões Recomendadas
- **ESLint**: Linting de JavaScript/TypeScript
- **Prettier**: Formatação de código
- **TypeScript**: Suporte ao TypeScript
- **Tailwind CSS**: Suporte ao Tailwind
- **GitLens**: Melhor integração com Git

### Configuração de Debug

#### VS Code Launch Configuration
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Server",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/apps/server/src/main.ts",
      "env": {
        "NODE_ENV": "development"
      },
      "console": "integratedTerminal",
      "restart": true,
      "protocol": "inspector"
    },
    {
      "name": "Debug Tests",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/node_modules/.bin/jest",
      "args": ["--runInBand"],
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen"
    }
  ]
}
```

## Testes

### Estrutura de Testes
```
apps/server/test/
├── unit/                 # Testes unitários
│   ├── services/         # Testes de services
│   ├── controllers/      # Testes de controllers
│   └── utils/           # Testes de utilitários
├── integration/          # Testes de integração
│   ├── api/             # Testes de endpoints
│   └── database/         # Testes de banco
└── e2e/                 # Testes end-to-end
    └── readings.e2e-spec.ts
```

### Configuração de Testes

#### Jest Configuration
```javascript
// jest.config.js
module.exports = {
  moduleFileExtensions: ['js', 'json', 'ts'],
  rootDir: 'src',
  testRegex: '.*\\.spec\\.ts$',
  transform: {
    '^.+\\.(t|j)s$': 'ts-jest',
  },
  collectCoverageFrom: [
    '**/*.(t|j)s',
    '!**/*.spec.ts',
    '!**/*.interface.ts',
  ],
  coverageDirectory: '../coverage',
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/test/setup.ts'],
};
```

#### Test Setup
```typescript
// test/setup.ts
import { Test } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';

let app: INestApplication;

beforeAll(async () => {
  const moduleFixture = await Test.createTestingModule({
    imports: [AppModule],
  }).compile();

  app = moduleFixture.createNestApplication();
  await app.init();
});

afterAll(async () => {
  await app.close();
});
```

### Exemplos de Testes

#### Teste Unitário
```typescript
// test/unit/services/tts.service.spec.ts
describe('TtsService', () => {
  let service: TtsService;
  let mockPiperRunner: jest.Mocked<PiperRunner>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TtsService,
        { provide: PiperRunner, useValue: mockPiperRunner },
      ],
    }).compile();

    service = module.get<TtsService>(TtsService);
  });

  describe('processPageWithPiper', () => {
    it('should process text successfully', async () => {
      const text = 'Hello world';
      const locale = 'pt_BR';
      const speed = 1.0;

      mockPiperRunner.run.mockResolvedValue(mockAudioBuffer);

      const result = await service.processPageWithPiper(text, locale, speed);

      expect(result).toBeInstanceOf(Buffer);
      expect(mockPiperRunner.run).toHaveBeenCalledWith({
        text,
        locale,
        speed,
      });
    });
  });
});
```

#### Teste de Integração
```typescript
// test/integration/api/files.e2e-spec.ts
describe('FilesController (e2e)', () => {
  let app: INestApplication;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('/files (POST)', () => {
    return request(app.getHttpServer())
      .post('/files')
      .attach('file', 'test/fixtures/sample.pdf')
      .expect(201)
      .expect((res) => {
        expect(res.body).toHaveProperty('fileId');
        expect(res.body).toHaveProperty('status', 'uploaded');
      });
  });
});
```

### Cobertura de Testes
```bash
# Executar testes com coverage
pnpm test:cov

# Gerar relatório HTML
pnpm test:cov -- --coverageReporters=html

# Verificar cobertura mínima
pnpm test:cov -- --coverageThreshold='{"global":{"branches":70,"functions":70,"lines":70,"statements":70}}'
```

## Deploy

### Ambiente de Desenvolvimento

#### Docker Compose
```bash
# Iniciar serviços de infraestrutura
docker-compose up -d

# Verificar status
docker-compose ps

# Ver logs
docker-compose logs -f
```

#### Serviços Incluídos
- **PostgreSQL**: Banco de dados
- **Redis**: Cache e sessões
- **Prometheus**: Métricas
- **Grafana**: Dashboards
- **Loki**: Logs

### Ambiente de Produção

#### Build de Produção
```bash
# Build completo
pnpm build:prod

# Build específico
pnpm build:server:prod
pnpm build:web:prod
```

#### Docker
```bash
# Build da imagem
docker build -t audivox:latest .

# Executar container
docker run -d \
  --name audivox \
  -p 3000:3000 \
  -e NODE_ENV=production \
  audivox:latest
```

#### Kubernetes
```bash
# Aplicar configurações
kubectl apply -f k8s/

# Verificar status
kubectl get pods
kubectl get services

# Ver logs
kubectl logs -f deployment/audivox-server
```

### CI/CD

#### GitHub Actions
```yaml
# .github/workflows/ci.yml
name: CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'pnpm'
      
      - run: pnpm install
      - run: pnpm test
      - run: pnpm lint
      - run: pnpm build

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - run: pnpm build:prod
      - run: docker build -t audivox:latest .
      - run: docker push audivox:latest
```

## Monitoramento e Observabilidade

### Logs
```typescript
// Configuração de logs
import { Logger } from '@nestjs/common';

const logger = new Logger('AppModule');

// Log estruturado
logger.log('Processing started', {
  readingId: '123',
  fileId: '456',
  timestamp: new Date().toISOString(),
});
```

### Métricas
```typescript
// Instrumentação de métricas
import { Counter, Histogram } from 'prom-client';

const processingCounter = new Counter({
  name: 'audivox_processing_total',
  help: 'Total number of processing requests',
  labelNames: ['status'],
});

const processingDuration = new Histogram({
  name: 'audivox_processing_duration_seconds',
  help: 'Processing duration in seconds',
  labelNames: ['locale'],
});
```

### Health Checks
```typescript
// Health check endpoint
@Get('health')
async getHealth(): Promise<HealthCheckResult> {
  return this.health.check([
    () => this.checkDatabase(),
    () => this.checkSupabase(),
    () => this.checkPiperTts(),
  ]);
}
```

## Troubleshooting

### Problemas Comuns

#### 1. Piper TTS não funciona
```bash
# Verificar se o binário existe
ls -la /path/to/piper

# Verificar permissões
chmod +x /path/to/piper

# Testar manualmente
echo "Hello world" | /path/to/piper --model /path/to/model.onnx
```

#### 2. Supabase connection failed
```bash
# Verificar variáveis de ambiente
echo $SUPABASE_URL
echo $SUPABASE_ANON_KEY

# Testar conexão
curl -H "apikey: $SUPABASE_ANON_KEY" $SUPABASE_URL/rest/v1/
```

#### 3. Testes falhando
```bash
# Limpar cache
pnpm test -- --clearCache

# Executar testes específicos
pnpm test -- --testNamePattern="TtsService"

# Verificar configuração
pnpm test -- --verbose
```

### Debug

#### Logs de Debug
```bash
# Habilitar logs detalhados
NODE_ENV=development LOG_LEVEL=debug pnpm dev:server
```

#### Profiling
```bash
# Profiling de CPU
node --prof apps/server/dist/main.js

# Profiling de memória
node --inspect apps/server/dist/main.js
```

## Contribuição

### Processo de Contribuição
1. Fork do repositório
2. Criar branch de feature
3. Implementar mudanças
4. Escrever testes
5. Atualizar documentação
6. Criar Pull Request

### Padrões de Código
- **TypeScript**: Tipagem estrita
- **ESLint**: Configuração padrão
- **Prettier**: Formatação consistente
- **Commits**: Convencionais
- **Testes**: Cobertura mínima de 70%

### Review Process
- **Automático**: CI/CD pipeline
- **Manual**: Review de código
- **Aprovação**: Pelo menos 1 aprovação
- **Merge**: Após aprovação e testes passando

## Recursos Adicionais

### Documentação
- **README**: Visão geral do projeto
- **API Docs**: Documentação da API
- **Architecture**: Decisões arquiteturais
- **Business Logic**: Regras de negócio

### Comunidade
- **Discord**: Canal de discussão
- **GitHub Issues**: Bug reports e feature requests
- **GitHub Discussions**: Perguntas e discussões

### Ferramentas
- **VS Code**: IDE recomendado
- **Docker**: Containerização
- **Kubernetes**: Orquestração
- **Prometheus**: Métricas
- **Grafana**: Dashboards
