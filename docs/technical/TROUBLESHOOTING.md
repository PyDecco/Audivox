# Guia de Solução de Problemas - Audivox

## Visão Geral

Este guia fornece soluções para problemas comuns encontrados durante o desenvolvimento e operação do Audivox, incluindo problemas de integração com Piper TTS, Supabase, processamento de arquivos e performance.

## Problemas de Upload de Arquivos

### Arquivo não é aceito

#### Sintomas
- Erro 400 Bad Request ao fazer upload
- Mensagem "Invalid file type" ou "File too large"
- Upload falha imediatamente

#### Causas Possíveis
1. **Tipo de arquivo não suportado**
2. **Arquivo muito grande (>100MB)**
3. **Arquivo corrompido**
4. **Problema de validação de assinatura**

#### Soluções
```typescript
// Verificar tipos suportados
const allowedTypes = [
  'application/pdf',
  'text/plain',
  'application/epub+zip'
];

// Verificar tamanho
const maxSize = 100 * 1024 * 1024; // 100MB

// Verificar assinatura de arquivo
const isValidSignature = await validateFileSignature(file);
```

#### Debug
```bash
# Verificar tipo MIME
file --mime-type documento.pdf

# Verificar tamanho
ls -lh documento.pdf

# Verificar integridade
pdfinfo documento.pdf
```

### Upload lento ou falha de conexão

#### Sintomas
- Upload demora muito para completar
- Timeout durante upload
- Conexão perdida

#### Causas Possíveis
1. **Arquivo muito grande**
2. **Conexão de rede lenta**
3. **Rate limiting**
4. **Problema no Supabase**

#### Soluções
```typescript
// Implementar upload em chunks
const chunkSize = 1024 * 1024; // 1MB por chunk
const chunks = Math.ceil(file.size / chunkSize);

for (let i = 0; i < chunks; i++) {
  const start = i * chunkSize;
  const end = Math.min(start + chunkSize, file.size);
  const chunk = file.slice(start, end);
  
  await uploadChunk(chunk, i);
}
```

#### Debug
```bash
# Testar conectividade
curl -I https://your-project.supabase.co

# Verificar rate limits
curl -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  https://your-project.supabase.co/rest/v1/
```

## Problemas de Processamento de Documentos

### Extração de texto falha

#### Sintomas
- Erro "Text extraction failed"
- Páginas vazias no resultado
- Processamento para na extração

#### Causas Possíveis
1. **PDF corrompido ou protegido**
2. **PDF escaneado (imagem)**
3. **Problema com Poppler**
4. **Encoding incorreto**

#### Soluções
```typescript
// Tentar extração direta primeiro
let text = await runPdfToText(filePath);

// Se falhar, tentar OCR
if (!text || text.trim().length === 0) {
  text = await runOcrPdf(filePath);
}

// Validar resultado
if (!text || text.trim().length === 0) {
  throw new Error('Unable to extract text from PDF');
}
```

#### Debug
```bash
# Testar pdftotext manualmente
pdftotext -layout -enc UTF-8 documento.pdf output.txt

# Verificar se é PDF escaneado
pdfinfo documento.pdf

# Testar OCR
ocrmypdf --force-ocr documento.pdf documento_ocr.pdf
```

### Páginas não são detectadas corretamente

#### Sintomas
- Número incorreto de páginas
- Páginas vazias ou duplicadas
- Quebras de página incorretas

#### Causas Possíveis
1. **PDF com formatação complexa**
2. **Problema na detecção de quebras de página**
3. **Encoding de caracteres especiais**

#### Soluções
```typescript
// Melhorar detecção de quebras de página
function findPageBreaks(text: string): number[] {
  const breaks = [0];
  
  // Quebras de página explícitas
  const pageBreakRegex = /\f/g;
  let match;
  while ((match = pageBreakRegex.exec(text)) !== null) {
    breaks.push(match.index + 1);
  }
  
  // Detectar quebras por tamanho de página
  const avgPageSize = text.length / estimatedPages;
  for (let i = avgPageSize; i < text.length; i += avgPageSize) {
    const nearestBreak = findNearestBreak(text, i);
    if (nearestBreak > breaks[breaks.length - 1]) {
      breaks.push(nearestBreak);
    }
  }
  
  return breaks;
}
```

## Problemas de Piper TTS

### Piper não executa

#### Sintomas
- Erro "Piper not found" ou "Piper execution failed"
- Timeout na execução do Piper
- Código de saída diferente de 0

#### Causas Possíveis
1. **Binário do Piper não encontrado**
2. **Permissões insuficientes**
3. **Modelos ONNX não encontrados**
4. **Problema de memória**

#### Soluções
```typescript
// Verificar se Piper existe
const piperPath = process.env.PIPER_BIN;
if (!fs.existsSync(piperPath)) {
  throw new Error(`Piper binary not found at ${piperPath}`);
}

// Verificar permissões
fs.access(piperPath, fs.constants.F_OK | fs.constants.X_OK, (err) => {
  if (err) {
    throw new Error(`Piper binary not executable: ${err.message}`);
  }
});

// Verificar modelos
const modelPath = process.env.PIPER_PT_MODEL;
if (!fs.existsSync(modelPath)) {
  throw new Error(`Piper model not found at ${modelPath}`);
}
```

#### Debug
```bash
# Verificar se Piper existe
ls -la /path/to/piper

# Testar execução manual
echo "Hello world" | /path/to/piper --model /path/to/model.onnx

# Verificar memória disponível
free -h

# Verificar logs do sistema
journalctl -u audivox -f
```

### Piper timeout

#### Sintomas
- Erro "Piper timeout" após 30 segundos
- Processamento para sem erro
- Alto uso de CPU sem progresso

#### Causas Possíveis
1. **Texto muito longo para processar**
2. **Modelo corrompido**
3. **Problema de memória**
4. **Piper travado**

#### Soluções
```typescript
// Implementar timeout com kill
const piper = spawn(PIPER_BIN, args);
const timeout = setTimeout(() => {
  piper.kill('SIGKILL');
  reject(new Error('Piper timeout'));
}, 30000);

piper.on('close', (code) => {
  clearTimeout(timeout);
  if (code === 0) {
    resolve(result);
  } else {
    reject(new Error(`Piper failed with code ${code}`));
  }
});

// Dividir texto em chunks menores
if (text.length > MAX_TEXT_LENGTH) {
  const chunks = splitTextIntoChunks(text, MAX_TEXT_LENGTH);
  const audioChunks = [];
  
  for (const chunk of chunks) {
    const audio = await processChunkWithPiper(chunk);
    audioChunks.push(audio);
  }
  
  return concatAudioChunks(audioChunks);
}
```

### Qualidade de áudio ruim

#### Sintomas
- Áudio com qualidade ruim
- Voz robótica ou distorcida
- Problemas de pronúncia

#### Causas Possíveis
1. **Modelo de baixa qualidade**
2. **Configurações incorretas**
3. **Texto mal formatado**
4. **Problema na concatenação**

#### Soluções
```typescript
// Usar modelo de alta qualidade
const modelPath = process.env.PIPER_PT_MODEL_HIGH_QUALITY;

// Configurar parâmetros otimizados
const piperArgs = [
  '--model', modelPath,
  '--config', configPath,
  '--length_scale', String(speed),
  '--noise_scale', '0.667',
  '--noise_w', '0.8',
  '--output_file', outputPath
];

// Limpar texto antes do processamento
const cleanText = text
  .replace(/\s+/g, ' ')           // Múltiplos espaços
  .replace(/\n+/g, ' ')           // Quebras de linha
  .replace(/[^\w\s.,!?;:]/g, '')  // Caracteres especiais
  .trim();
```

## Problemas de Supabase

### Conexão falha

#### Sintomas
- Erro "Connection failed" ou "Database error"
- Timeout ao conectar
- Operações de banco falham

#### Causas Possíveis
1. **URL ou chave incorreta**
2. **Problema de rede**
3. **Supabase indisponível**
4. **Rate limiting**

#### Soluções
```typescript
// Verificar configuração
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('Supabase configuration missing');
}

// Implementar retry com backoff
async function withRetry<T>(
  operation: () => Promise<T>,
  maxRetries: number = 3
): Promise<T> {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await operation();
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      
      const delay = Math.pow(2, i) * 1000; // Exponential backoff
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

#### Debug
```bash
# Testar conexão
curl -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  "$SUPABASE_URL/rest/v1/"

# Verificar status do Supabase
curl https://status.supabase.com/api/v2/status.json
```

### Storage falha

#### Sintomas
- Erro ao salvar arquivos
- Upload para Supabase Storage falha
- Arquivos não encontrados

#### Causas Possíveis
1. **Quota de storage excedida**
2. **Permissões incorretas**
3. **Problema de rede**
4. **Arquivo muito grande**

#### Soluções
```typescript
// Verificar quota antes do upload
const { data: usage } = await supabase.storage
  .from('files')
  .getBucket('audivox');

if (usage.used > usage.limit * 0.9) {
  throw new Error('Storage quota nearly exceeded');
}

// Implementar upload em chunks
async function uploadLargeFile(file: Buffer, path: string) {
  const chunkSize = 1024 * 1024; // 1MB
  const chunks = Math.ceil(file.length / chunkSize);
  
  for (let i = 0; i < chunks; i++) {
    const start = i * chunkSize;
    const end = Math.min(start + chunkSize, file.length);
    const chunk = file.slice(start, end);
    
    const { error } = await supabase.storage
      .from('files')
      .upload(`${path}.part${i}`, chunk);
    
    if (error) throw error;
  }
}
```

## Problemas de Performance

### Processamento lento

#### Sintomas
- Tempo de processamento muito alto
- Sistema lento durante processamento
- Timeout em documentos grandes

#### Causas Possíveis
1. **Documento muito grande**
2. **Piper TTS lento**
3. **Problema de memória**
4. **CPU insuficiente**

#### Soluções
```typescript
// Implementar processamento assíncrono
async function processDocumentAsync(fileId: string) {
  const reading = await this.readingRepository.findOne({ fileId });
  
  // Processar em background
  setImmediate(async () => {
    try {
      await this.processDocument(reading);
    } catch (error) {
      await this.handleProcessingError(reading, error);
    }
  });
  
  return { readingId: reading.id, status: 'queued' };
}

// Otimizar uso de memória
class MemoryOptimizedProcessor {
  private readonly MAX_MEMORY_USAGE = 1024 * 1024 * 1024; // 1GB
  
  async processPage(page: PageIndex): Promise<AudioChunk> {
    // Verificar memória antes do processamento
    if (!this.checkMemoryUsage()) {
      await this.cleanupMemory();
    }
    
    const result = await this.processWithPiper(page);
    
    // Limpar memória após processamento
    this.cleanupMemory();
    
    return result;
  }
}
```

### Alto uso de memória

#### Sintomas
- Sistema fica lento
- Out of memory errors
- Processo mata outros processos

#### Causas Possíveis
1. **Memory leaks**
2. **Modelos Piper carregados em memória**
3. **Cache muito grande**
4. **Streams não fechados**

#### Soluções
```typescript
// Implementar cleanup de memória
class MemoryManager {
  private modelCache = new Map<string, any>();
  
  async cleanupMemory(): Promise<void> {
    // Limpar cache de modelos
    this.modelCache.clear();
    
    // Forçar garbage collection
    if (global.gc) {
      global.gc();
    }
    
    // Limpar streams abertos
    this.closeOpenStreams();
  }
  
  private closeOpenStreams(): void {
    // Implementar fechamento de streams
    this.openStreams.forEach(stream => {
      if (!stream.destroyed) {
        stream.destroy();
      }
    });
    this.openStreams.clear();
  }
}

// Monitorar uso de memória
setInterval(() => {
  const usage = process.memoryUsage();
  if (usage.heapUsed > MAX_MEMORY_USAGE) {
    this.memoryManager.cleanupMemory();
  }
}, 30000); // A cada 30 segundos
```

## Problemas de Observabilidade

### Métricas não aparecem

#### Sintomas
- Prometheus não recebe métricas
- Grafana sem dados
- Dashboards vazios

#### Causas Possíveis
1. **OpenTelemetry não configurado**
2. **Prometheus não conectado**
3. **Métricas não instrumentadas**
4. **Problema de rede**

#### Soluções
```typescript
// Configurar OpenTelemetry
import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';

const sdk = new NodeSDK({
  instrumentations: [getNodeAutoInstrumentations()],
  serviceName: 'audivox-server',
  serviceVersion: '1.0.0',
});

sdk.start();

// Instrumentar métricas customizadas
import { Counter, Histogram } from 'prom-client';

const processingCounter = new Counter({
  name: 'audivox_processing_total',
  help: 'Total number of processing requests',
  labelNames: ['status', 'locale'],
});

const processingDuration = new Histogram({
  name: 'audivox_processing_duration_seconds',
  help: 'Processing duration in seconds',
  labelNames: ['locale'],
  buckets: [0.1, 0.5, 1, 2, 5, 10, 30],
});
```

#### Debug
```bash
# Verificar se Prometheus está rodando
curl http://localhost:9090/api/v1/targets

# Verificar métricas da aplicação
curl http://localhost:3000/metrics

# Verificar logs do OpenTelemetry
journalctl -u audivox -f | grep otel
```

### Logs não aparecem

#### Sintomas
- Logs não são exibidos
- Loki sem dados
- Debug difícil

#### Causas Possíveis
1. **Logger não configurado**
2. **Loki não conectado**
3. **Nível de log incorreto**
4. **Problema de formatação**

#### Soluções
```typescript
// Configurar logger estruturado
import { Logger } from '@nestjs/common';

const logger = new Logger('AppModule');

// Log estruturado
logger.log('Processing started', {
  readingId: '123',
  fileId: '456',
  timestamp: new Date().toISOString(),
  level: 'info',
});

// Configurar níveis de log
const logLevel = process.env.LOG_LEVEL || 'info';
const logger = new Logger('AppModule', {
  logLevels: ['error', 'warn', 'log', 'debug', 'verbose'],
});
```

## Problemas de Deploy

### Container não inicia

#### Sintomas
- Docker container falha ao iniciar
- Erro "Container exited with code 1"
- Aplicação não responde

#### Causas Possíveis
1. **Variáveis de ambiente faltando**
2. **Dependências não instaladas**
3. **Porta já em uso**
4. **Problema de permissões**

#### Soluções
```dockerfile
# Dockerfile otimizado
FROM node:20-alpine

WORKDIR /app

# Instalar dependências do sistema
RUN apk add --no-cache \
  poppler-utils \
  tesseract-ocr \
  ffmpeg

# Copiar package.json e instalar dependências
COPY package*.json ./
RUN npm install -g pnpm
RUN pnpm install --frozen-lockfile

# Copiar código
COPY . .

# Build da aplicação
RUN pnpm build

# Expor porta
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1

# Comando de inicialização
CMD ["pnpm", "start:prod"]
```

#### Debug
```bash
# Verificar logs do container
docker logs audivox-container

# Executar container interativamente
docker run -it --env-file .env audivox:latest /bin/sh

# Verificar variáveis de ambiente
docker exec audivox-container env
```

### Kubernetes deployment falha

#### Sintomas
- Pods não iniciam
- Status "CrashLoopBackOff"
- Serviços não conectam

#### Causas Possíveis
1. **Configuração incorreta**
2. **Recursos insuficientes**
3. **Secrets não configurados**
4. **Problema de rede**

#### Soluções
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: audivox-server
spec:
  replicas: 2
  selector:
    matchLabels:
      app: audivox-server
  template:
    metadata:
      labels:
        app: audivox-server
    spec:
      containers:
      - name: audivox-server
        image: audivox:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: PORT
          value: "3000"
        envFrom:
        - secretRef:
            name: audivox-secrets
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /api/health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /api/health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

#### Debug
```bash
# Verificar status dos pods
kubectl get pods

# Verificar logs
kubectl logs -f deployment/audivox-server

# Verificar eventos
kubectl get events --sort-by=.metadata.creationTimestamp

# Descrever pod para debug
kubectl describe pod audivox-server-xxx
```

## Ferramentas de Debug

### Logs Estruturados
```typescript
// Configurar logger com contexto
const logger = new Logger('TtsService');

// Log com contexto
logger.log('Processing page', {
  readingId: reading.id,
  page: currentPage,
  totalPages: totalPages,
  textLength: page.text.length,
  processingTime: Date.now() - startTime,
  timestamp: new Date().toISOString(),
});
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

### Health Checks
```typescript
// Health check abrangente
@Get('health')
async getHealth(): Promise<HealthCheckResult> {
  return this.health.check([
    () => this.checkDatabase(),
    () => this.checkSupabase(),
    () => this.checkPiperTts(),
    () => this.checkStorage(),
    () => this.checkMemory(),
  ]);
}
```

## Contatos e Recursos

### Documentação
- **README**: Visão geral do projeto
- **API Docs**: Documentação da API
- **Architecture**: Decisões arquiteturais
- **Business Logic**: Regras de negócio

### Comunidade
- **Discord**: Canal de discussão
- **GitHub Issues**: Bug reports
- **GitHub Discussions**: Perguntas

### Ferramentas de Debug
- **VS Code**: IDE com debugging
- **Docker**: Containerização
- **Kubernetes**: Orquestração
- **Prometheus**: Métricas
- **Grafana**: Dashboards
