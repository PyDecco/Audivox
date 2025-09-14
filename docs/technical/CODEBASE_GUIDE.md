# Guia de Navegação da Base de Código - Audivox

## Visão Geral da Estrutura

O Audivox é um monorepo organizado em aplicações separadas que se comunicam via API REST. A arquitetura segue o padrão cliente-servidor com NestJS como backend único e Next.js/Flutter como clientes.

## Estrutura do Monorepo

```
audivox/
├── apps/
│   ├── server/                    # NestJS API Backend
│   ├── web/                       # Next.js Frontend
│   └── mobile/                    # Flutter App (futuro)
├── packages/
│   └── shared/                    # DTOs e Types compartilhados
├── tools/                         # Scripts DevOps
├── specs/
│   ├── technical/                 # Documentação técnica
│   └── business/                  # Documentação empresarial
├── docker-compose.yml             # Orquestração de serviços
├── package.json                   # Configuração do workspace
├── pnpm-workspace.yaml            # Configuração do pnpm
├── turbo.json                     # Configuração do Turborepo
└── README.md                      # Documentação principal
```

## Apps/Server (NestJS Backend)

### Estrutura de Diretórios
```
apps/server/
├── src/
│   ├── modules/                   # Módulos de funcionalidade
│   │   ├── files/                 # Upload e gerenciamento de arquivos
│   │   ├── readings/               # Sessões de leitura e processamento
│   │   ├── tts/                    # Integração com Piper TTS
│   │   └── storage/                # Integração com Supabase
│   ├── common/                     # Código compartilhado
│   │   ├── decorators/             # Decorators customizados
│   │   ├── filters/                # Exception filters
│   │   ├── guards/                 # Guards de autenticação/autorização
│   │   ├── interceptors/           # Interceptors para logging/métricas
│   │   └── pipes/                  # Validation pipes
│   ├── config/                     # Configurações da aplicação
│   ├── database/                   # Configuração do banco de dados
│   ├── observability/              # Configuração de métricas e logs
│   └── main.ts                     # Bootstrap da aplicação
├── test/                           # Testes
│   ├── unit/                       # Testes unitários
│   ├── integration/                # Testes de integração
│   └── e2e/                        # Testes end-to-end
├── docker/                         # Configurações Docker
├── package.json                    # Dependências do servidor
└── Dockerfile                       # Imagem Docker
```

### Módulos Principais

#### Files Module
**Propósito**: Gerenciar upload, validação e armazenamento de arquivos
- **Controller**: `FilesController` - Endpoints de upload
- **Service**: `FilesService` - Lógica de negócio para arquivos
- **Entity**: `File` - Modelo de dados do arquivo
- **DTOs**: `UploadFileDto`, `FileResponseDto`

#### Readings Module
**Propósito**: Gerenciar sessões de leitura e processamento de documentos
- **Controller**: `ReadingsController` - Endpoints de leitura
- **Service**: `ReadingsService` - Orquestração do processamento
- **Entity**: `Reading` - Modelo de dados da sessão
- **DTOs**: `CreateReadingDto`, `ReadingStatusDto`

#### TTS Module
**Propósito**: Integração com Piper TTS para conversão de texto em áudio
- **Service**: `TtsService` - Wrapper para Piper TTS
- **Processor**: `PageProcessor` - Processamento página por página
- **Models**: `VoiceModel` - Configuração de modelos de voz
- **Utils**: `PiperRunner` - Execução do binário Piper

#### Storage Module
**Propósito**: Integração com Supabase para storage e banco de dados
- **Service**: `StorageService` - Operações de storage
- **Service**: `DatabaseService` - Operações de banco
- **Config**: `SupabaseConfig` - Configuração do Supabase

### Arquivos Chave

#### main.ts
```typescript
// Bootstrap da aplicação NestJS
// Configuração de CORS, validação, pipes globais
// Setup de observabilidade (OpenTelemetry)
// Configuração de rate limiting
```

#### app.module.ts
```typescript
// Módulo raiz da aplicação
// Importação de todos os módulos de funcionalidade
// Configuração de banco de dados
// Configuração de Supabase
```

#### config/
```typescript
// Configurações centralizadas
// Variáveis de ambiente
// Configuração de Piper TTS
// Configuração de Supabase
```

## Apps/Web (Next.js Frontend)

### Estrutura de Diretórios
```
apps/web/
├── src/
│   ├── app/                        # App Router (Next.js 13+)
│   │   ├── (auth)/                 # Rotas de autenticação
│   │   ├── dashboard/              # Dashboard principal
│   │   ├── upload/                  # Página de upload
│   │   ├── reading/                # Página de leitura
│   │   └── layout.tsx              # Layout raiz
│   ├── components/                 # Componentes reutilizáveis
│   │   ├── ui/                     # Componentes de UI base
│   │   ├── forms/                  # Componentes de formulário
│   │   ├── player/                 # Player de áudio
│   │   └── upload/                 # Componentes de upload
│   ├── lib/                        # Utilitários e configurações
│   │   ├── api.ts                  # Cliente da API
│   │   ├── utils.ts                # Funções utilitárias
│   │   └── validations.ts          # Schemas de validação
│   ├── hooks/                      # Custom hooks
│   ├── types/                      # Definições de tipos
│   └── styles/                     # Estilos globais
├── public/                         # Arquivos estáticos
├── package.json                    # Dependências do frontend
└── next.config.js                  # Configuração do Next.js
```

### Componentes Principais

#### Upload Component
**Propósito**: Interface para upload de arquivos
- **Funcionalidades**: Drag & drop, validação, progresso
- **Integração**: API de upload do NestJS
- **Validação**: Tipos de arquivo, tamanho máximo

#### Reading Config Component
**Propósito**: Configuração de parâmetros de leitura
- **Funcionalidades**: Seleção de idioma, velocidade, ponto inicial
- **Preview**: Visualização do PDF durante configuração
- **Validação**: Parâmetros válidos

#### Audio Player Component
**Propósito**: Reprodução de áudio gerado
- **Funcionalidades**: Play/pause, seek, download
- **Streaming**: Reprodução durante processamento
- **Controles**: Velocidade, volume, marcadores

### Fluxo de Dados
```
User Action → Component → API Client → NestJS API → Supabase
                ↓
            State Update → UI Update
```

## Apps/Mobile (Flutter - Futuro)

### Estrutura Planejada
```
apps/mobile/
├── lib/
│   ├── main.dart                   # Entry point
│   ├── app/                        # Configuração da app
│   ├── features/                   # Features da aplicação
│   │   ├── upload/                 # Feature de upload
│   │   ├── reading/                # Feature de leitura
│   │   └── player/                 # Feature de player
│   ├── shared/                     # Código compartilhado
│   │   ├── models/                 # Modelos de dados
│   │   ├── services/                # Serviços de API
│   │   └── widgets/                # Widgets reutilizáveis
│   └── core/                       # Configurações core
├── test/                           # Testes
└── pubspec.yaml                    # Dependências Flutter
```

## Packages/Shared

### Estrutura
```
packages/shared/
├── src/
│   ├── dto/                        # DTOs compartilhados
│   ├── types/                      # Tipos TypeScript
│   ├── enums/                      # Enums compartilhados
│   └── utils/                      # Utilitários compartilhados
├── package.json                    # Configuração do pacote
└── tsconfig.json                   # Configuração TypeScript
```

### DTOs Compartilhados
- **FileDto**: Estrutura de dados de arquivo
- **ReadingDto**: Estrutura de dados de leitura
- **AudioDto**: Estrutura de dados de áudio
- **ErrorDto**: Estrutura de dados de erro

## Tools/

### Scripts DevOps
```
tools/
├── scripts/
│   ├── build.sh                    # Script de build
│   ├── deploy.sh                   # Script de deploy
│   ├── test.sh                     # Script de testes
│   └── setup.sh                    # Script de setup
├── docker/
│   ├── docker-compose.yml          # Orquestração de serviços
│   ├── Dockerfile.server           # Imagem do servidor
│   └── Dockerfile.web              # Imagem do frontend
└── k8s/                            # Configurações Kubernetes
    ├── namespace.yaml
    ├── deployment.yaml
    └── service.yaml
```

## Fluxos de Dados Principais

### 1. Upload de Arquivo
```
Frontend → FilesController → FilesService → Supabase Storage
                ↓
            File Entity → Database
                ↓
            Response → Frontend
```

### 2. Processamento de Leitura
```
Frontend → ReadingsController → ReadingsService → TtsService
                ↓
            PageProcessor → Piper TTS → Audio Generation
                ↓
            StorageService → Supabase Storage
                ↓
            Reading Entity → Database
                ↓
            Response → Frontend
```

### 3. Streaming de Áudio
```
Frontend → ReadingsController → StorageService → Supabase Storage
                ↓
            Audio Stream → Frontend Player
```

## Pontos de Integração

### API REST
- **Base URL**: `http://localhost:3000/api`
- **Autenticação**: Futuro (não no MVP)
- **Rate Limiting**: Implementado
- **CORS**: Configurado para frontend

### Supabase
- **Database**: PostgreSQL
- **Storage**: Arquivos de áudio
- **API**: REST e GraphQL
- **Auth**: Futuro (não no MVP)

### Piper TTS
- **Binário**: Executável local
- **Modelos**: ONNX files
- **Configuração**: Via variáveis de ambiente
- **Processamento**: Página por página

## Configurações de Ambiente

### Variáveis de Ambiente
```bash
# Piper TTS
PIPER_BIN=/path/to/piper
PIPER_PT_MODEL=/path/to/pt_model.onnx
PIPER_PT_CFG=/path/to/pt_model.json

# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-key

# Application
PORT=3000
NODE_ENV=development
LOG_LEVEL=info

# Observability
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

### Docker Compose
```yaml
version: '3.8'
services:
  server:
    build: ./apps/server
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - supabase
      - prometheus

  web:
    build: ./apps/web
    ports:
      - "3001:3000"
    depends_on:
      - server

  supabase:
    image: supabase/postgres
    environment:
      - POSTGRES_PASSWORD=password
    volumes:
      - supabase_data:/var/lib/postgresql/data

  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
```

## Padrões de Desenvolvimento

### Convenções de Código
- **TypeScript**: Tipagem estrita
- **ESLint**: Configuração padrão do NestJS
- **Prettier**: Formatação consistente
- **Commits**: Convencionais (feat, fix, docs, etc.)

### Estrutura de Commits
```
feat: add page-by-page processing
fix: resolve Piper TTS timeout issue
docs: update API documentation
test: add unit tests for TtsService
```

### Branching Strategy
- **main**: Branch principal
- **develop**: Branch de desenvolvimento
- **feature/**: Features individuais
- **hotfix/**: Correções urgentes

## Debugging e Desenvolvimento

### Logs Estruturados
```typescript
// Sempre incluir contexto relevante
this.logger.info('Processing page', {
  readingId: reading.id,
  page: currentPage,
  totalPages: totalPages,
  textLength: page.text.length,
  processingTime: Date.now() - startTime
});
```

### Health Checks
```typescript
@Get('health')
async getHealth(): Promise<HealthCheckResult> {
  return this.health.check([
    () => this.checkDatabase(),
    () => this.checkSupabase(),
    () => this.checkPiperTts()
  ]);
}
```

### Métricas de Performance
```typescript
// Instrumentar operações críticas
const startTime = Date.now();
try {
  const result = await this.processPage(page);
  this.metrics.recordProcessingTime(Date.now() - startTime);
  return result;
} catch (error) {
  this.metrics.recordError(error);
  throw error;
}
```

## Considerações de Escalabilidade

### Limitações Atuais
- **Processamento**: Sequencial por documento
- **Armazenamento**: Supabase limits
- **Memória**: Modelos Piper carregados em memória
- **Conectividade**: Dependência de Supabase

### Melhorias Futuras
- **Processamento paralelo**: Múltiplos documentos simultâneos
- **Cache de modelos**: Modelos compartilhados entre instâncias
- **CDN**: Distribuição de áudios gerados
- **Load balancing**: Múltiplas instâncias do servidor
