# ADR-004: Observabilidade

## Status
Aceito

## Contexto
O Audivox precisa de observabilidade completa para monitorar performance, debug de problemas e entender o comportamento do sistema, especialmente considerando o processamento de áudio e integração com ferramentas externas como Piper TTS.

## Decisão
Implementar observabilidade usando OpenTelemetry + Prometheus + Grafana com Docker/Kubernetes para coleta automática de métricas, logs e traces sem dor de cabeça e gastando muito menos.

## Alternativas Consideradas

### 1. Logs Simples
- **Prós**: Simples, barato, fácil de implementar
- **Contras**: Limitado, difícil de escalar, sem métricas
- **Decisão**: Rejeitado - insuficiente para monitoramento completo

### 2. ELK Stack (Elasticsearch + Logstash + Kibana)
- **Prós**: Completo, flexível, poderoso
- **Contras**: Complexo, recursos intensivos, custos
- **Decisão**: Rejeitado - complexidade excessiva para MVP

### 3. Cloud Solutions (DataDog, New Relic)
- **Prós**: Completo, gerenciado, fácil de usar
- **Contras**: Custos altos, vendor lock-in
- **Decisão**: Rejeitado - viola restrição de orçamento zero

### 4. OpenTelemetry + Prometheus + Grafana (Escolhido)
- **Prós**: Padrão da indústria, gratuito, integração com Kubernetes
- **Contras**: Curva de aprendizado inicial
- **Decisão**: Aceito - adequado para observabilidade completa

## Implementação

### Stack de Observabilidade
```
Aplicação (NestJS) → OpenTelemetry → Prometheus → Grafana
                  ↓
                Logs → Loki → Grafana
```

### Componentes
- **OpenTelemetry**: Coleta de métricas, logs e traces
- **Prometheus**: Armazenamento de métricas
- **Grafana**: Visualização e dashboards
- **Loki**: Armazenamento de logs
- **Jaeger**: Visualização de traces (opcional)

### Configuração Docker
```yaml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
  
  grafana:
    image: grafana/grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-storage:/var/lib/grafana
  
  loki:
    image: grafana/loki
    ports:
      - "3100:3100"
    volumes:
      - ./loki-config.yml:/etc/loki/local-config.yaml
```

## Métricas Implementadas

### Métricas de Aplicação
```typescript
// Tempo de processamento por página
const processingTimeHistogram = new Histogram({
  name: 'audivox_page_processing_duration_seconds',
  help: 'Time spent processing each page',
  labelNames: ['locale', 'file_type'],
  buckets: [0.1, 0.5, 1, 2, 5, 10, 30]
});

// Taxa de sucesso
const successCounter = new Counter({
  name: 'audivox_pages_processed_total',
  help: 'Total number of pages processed',
  labelNames: ['status', 'locale']
});

// Uso de memória
const memoryUsageGauge = new Gauge({
  name: 'audivox_memory_usage_bytes',
  help: 'Memory usage of the application',
  labelNames: ['type']
});
```

### Métricas de Sistema
- **CPU**: Uso de CPU por processo
- **Memória**: Uso de RAM e swap
- **Disco**: Espaço em disco e I/O
- **Rede**: Tráfego de rede e latência

### Métricas de Negócio
- **Uploads**: Número de uploads por período
- **Conversões**: Taxa de sucesso de conversões
- **Usuários**: Usuários ativos e novos
- **Performance**: Tempo médio de processamento

## Logs Estruturados

### Formato de Log
```typescript
interface LogEntry {
  timestamp: string;
  level: 'info' | 'warn' | 'error';
  message: string;
  requestId: string;
  readingId?: string;
  userId?: string;
  metadata: Record<string, any>;
}
```

### Exemplos de Logs
```typescript
// Log de início de processamento
logger.info('Starting document processing', {
  requestId: 'req-123',
  readingId: 'reading-456',
  fileId: 'file-789',
  locale: 'pt_BR',
  totalPages: 50
});

// Log de progresso
logger.info('Page processed', {
  requestId: 'req-123',
  readingId: 'reading-456',
  currentPage: 25,
  totalPages: 50,
  processingTime: 2.5,
  audioSize: 1024000
});

// Log de erro
logger.error('Piper processing failed', {
  requestId: 'req-123',
  readingId: 'reading-456',
  page: 25,
  error: 'Piper timeout',
  retryCount: 2
});
```

## Traces Distribuídos

### Instrumentação
```typescript
import { trace, context } from '@opentelemetry/api';

async function processDocument(fileId: string) {
  const tracer = trace.getTracer('audivox-processor');
  
  return tracer.startActiveSpan('process-document', async (span) => {
    span.setAttributes({
      'file.id': fileId,
      'file.type': 'pdf',
      'locale': 'pt_BR'
    });
    
    try {
      const pages = await extractPages(fileId);
      span.setAttribute('pages.count', pages.length);
      
      for (const page of pages) {
        await processPage(page, span);
      }
      
      span.setStatus({ code: SpanStatusCode.OK });
    } catch (error) {
      span.setStatus({ 
        code: SpanStatusCode.ERROR, 
        message: error.message 
      });
      throw error;
    } finally {
      span.end();
    }
  });
}
```

## Dashboards do Grafana

### Dashboard Principal
- **Visão Geral**: Métricas de sistema e aplicação
- **Performance**: Tempo de processamento e throughput
- **Erros**: Taxa de erro e tipos de erro
- **Recursos**: CPU, memória e disco

### Dashboard de Negócio
- **Uploads**: Volume de uploads por período
- **Conversões**: Taxa de sucesso e falhas
- **Usuários**: Usuários ativos e crescimento
- **Qualidade**: Métricas de qualidade do áudio

### Dashboard de Debug
- **Traces**: Traces detalhados de requisições
- **Logs**: Logs em tempo real com filtros
- **Métricas**: Métricas granulares por componente
- **Alertas**: Status de alertas e notificações

## Alertas

### Alertas Críticos
```yaml
# Taxa de erro alta
- alert: HighErrorRate
  expr: rate(audivox_pages_processed_total{status="error"}[5m]) > 0.1
  for: 2m
  labels:
    severity: critical
  annotations:
    summary: "High error rate detected"

# Tempo de processamento alto
- alert: HighProcessingTime
  expr: histogram_quantile(0.95, audivox_page_processing_duration_seconds) > 30
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Processing time is high"
```

### Alertas de Sistema
- **CPU alta**: > 80% por 5 minutos
- **Memória alta**: > 90% por 2 minutos
- **Disco cheio**: > 95% por 1 minuto
- **Serviço down**: Health check falhando

## Consequências

### Positivas
- **Visibilidade completa**: Monitoramento de todos os aspectos
- **Debug eficiente**: Logs estruturados e traces
- **Performance**: Identificação rápida de gargalos
- **Custo zero**: Stack gratuito e open source
- **Escalabilidade**: Integração com Kubernetes

### Negativas
- **Complexidade inicial**: Setup e configuração
- **Recursos**: Uso de CPU e memória para observabilidade
- **Curva de aprendizado**: Necessidade de aprender ferramentas
- **Manutenção**: Manutenção de dashboards e alertas

## Implementação por Fases

### Fase 1: Métricas Básicas
- [ ] OpenTelemetry básico
- [ ] Métricas de aplicação
- [ ] Dashboard simples no Grafana

### Fase 2: Logs Estruturados
- [ ] Logs estruturados
- [ ] Integração com Loki
- [ ] Dashboard de logs

### Fase 3: Traces Distribuídos
- [ ] Instrumentação completa
- [ ] Traces entre serviços
- [ ] Dashboard de traces

### Fase 4: Alertas e Automação
- [ ] Alertas críticos
- [ ] Notificações
- [ ] Automação de respostas

## Revisão
Esta decisão será revisada quando:
- Necessidade de observabilidade mais avançada
- Problemas de performance com stack atual
- Requisitos de compliance ou auditoria
- Crescimento que justifique soluções mais robustas
