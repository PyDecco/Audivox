# Especificação da API - Audivox

## Visão Geral

A API do Audivox é uma API REST construída com NestJS que permite upload de arquivos, processamento de documentos e geração de áudio usando Piper TTS. A API segue padrões RESTful e inclui autenticação, rate limiting e observabilidade.

## Base URL

```
Development: http://localhost:3000/api
Production: https://api.audivox.com/api
```

## Autenticação

### Status Atual
- **MVP**: Sem autenticação (público)
- **Futuro**: JWT tokens ou Supabase Auth

### Headers de Requisição
```http
Content-Type: application/json
Accept: application/json
User-Agent: Audivox-Client/1.0
```

## Rate Limiting

### Limites
- **Upload**: 10 requests por 15 minutos por IP
- **Processamento**: 5 requests por 15 minutos por IP
- **Download**: 20 requests por 15 minutos por IP

### Headers de Resposta
```http
X-RateLimit-Limit: 10
X-RateLimit-Remaining: 9
X-RateLimit-Reset: 1640995200
```

### Códigos de Erro
```http
HTTP 429 Too Many Requests
{
  "statusCode": 429,
  "message": "Rate limit exceeded",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "path": "/api/files"
}
```

## Endpoints

### Files (Arquivos)

#### POST /files
Upload de arquivo para processamento.

**Request**
```http
POST /api/files
Content-Type: multipart/form-data

file: [arquivo PDF/EPUB/TXT]
```

**Response**
```json
{
  "fileId": "550e8400-e29b-41d4-a716-446655440000",
  "originalName": "documento.pdf",
  "mimeType": "application/pdf",
  "size": 1024000,
  "status": "uploaded",
  "uploadedAt": "2024-01-01T00:00:00.000Z"
}
```

**Códigos de Erro**
- `400 Bad Request`: Arquivo inválido ou muito grande
- `413 Payload Too Large`: Arquivo excede limite de tamanho
- `415 Unsupported Media Type`: Tipo de arquivo não suportado

#### GET /files/:id
Obter informações de um arquivo.

**Request**
```http
GET /api/files/550e8400-e29b-41d4-a716-446655440000
```

**Response**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "originalName": "documento.pdf",
  "mimeType": "application/pdf",
  "size": 1024000,
  "status": "processed",
  "uploadedAt": "2024-01-01T00:00:00.000Z",
  "processedAt": "2024-01-01T00:01:00.000Z",
  "metadata": {
    "pages": 50,
    "wordCount": 15000,
    "charCount": 75000,
    "language": "pt_BR"
  }
}
```

**Códigos de Erro**
- `404 Not Found`: Arquivo não encontrado

### Readings (Leituras)

#### POST /readings
Criar uma nova sessão de leitura.

**Request**
```http
POST /api/readings
Content-Type: application/json

{
  "fileId": "550e8400-e29b-41d4-a716-446655440000",
  "locale": "pt_BR",
  "start": {
    "type": "page",
    "value": 10
  },
  "speed": 1.0,
  "format": "wav",
  "stream": false
}
```

**Parâmetros**
- `fileId` (string, obrigatório): ID do arquivo
- `locale` (string, obrigatório): Idioma para TTS (`pt_BR`, `es_ES`, `en_US`)
- `start` (object, obrigatório): Posição de início
  - `type` (string): `page`, `percent`, ou `offset`
  - `value` (number): Valor da posição
- `speed` (number, obrigatório): Velocidade da fala (0.8 - 1.3)
- `format` (string, obrigatório): Formato de áudio (`wav`, `mp3`)
- `stream` (boolean, opcional): Se deve retornar streaming (futuro)

**Response**
```json
{
  "readingId": "660e8400-e29b-41d4-a716-446655440001",
  "status": "queued",
  "progress": 0.0,
  "estimatedTime": 300
}
```

**Códigos de Erro**
- `400 Bad Request`: Parâmetros inválidos
- `404 Not Found`: Arquivo não encontrado
- `422 Unprocessable Entity`: Arquivo não pode ser processado

#### GET /readings/:id
Obter status de uma sessão de leitura.

**Request**
```http
GET /api/readings/660e8400-e29b-41d4-a716-446655440001
```

**Response**
```json
{
  "id": "660e8400-e29b-41d4-a716-446655440001",
  "fileId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "processing",
  "progress": 0.42,
  "currentPage": 21,
  "totalPages": 50,
  "locale": "pt_BR",
  "speed": 1.0,
  "format": "wav",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "estimatedCompletion": "2024-01-01T00:05:00.000Z"
}
```

**Status Possíveis**
- `queued`: Na fila para processamento
- `processing`: Sendo processado
- `done`: Concluído com sucesso
- `error`: Erro no processamento

**Códigos de Erro**
- `404 Not Found`: Sessão de leitura não encontrada

#### GET /readings/:id/audio
Obter o áudio gerado.

**Request**
```http
GET /api/readings/660e8400-e29b-41d4-a716-446655440001/audio
```

**Response**
```http
HTTP/1.1 200 OK
Content-Type: audio/wav
Content-Length: 2048000
Accept-Ranges: bytes
Cache-Control: public, max-age=3600

[Binary audio data]
```

**Suporte a Range Requests**
```http
GET /api/readings/660e8400-e29b-41d4-a716-446655440001/audio
Range: bytes=0-1023
```

**Response com Range**
```http
HTTP/1.1 206 Partial Content
Content-Type: audio/wav
Content-Length: 1024
Content-Range: bytes 0-1023/2048000
Accept-Ranges: bytes

[Binary audio data]
```

**Códigos de Erro**
- `404 Not Found`: Sessão de leitura não encontrada
- `400 Bad Request`: Áudio ainda não está pronto
- `410 Gone`: Áudio expirado e removido

#### DELETE /readings/:id
Cancelar uma sessão de leitura.

**Request**
```http
DELETE /api/readings/660e8400-e29b-41d4-a716-446655440001
```

**Response**
```json
{
  "message": "Reading cancelled successfully"
}
```

**Códigos de Erro**
- `404 Not Found`: Sessão de leitura não encontrada
- `409 Conflict`: Não é possível cancelar (já concluído)

### Voices (Vozes)

#### GET /voices
Listar vozes/idiomas disponíveis.

**Request**
```http
GET /api/voices
```

**Response**
```json
[
  {
    "locale": "pt_BR",
    "name": "Português Brasileiro",
    "model": "pt_BR-faber-medium",
    "available": true
  },
  {
    "locale": "es_ES",
    "name": "Español",
    "model": "es_ES-medium",
    "available": true
  },
  {
    "locale": "en_US",
    "name": "English (US)",
    "model": "en_US-medium",
    "available": true
  }
]
```

### Health Check

#### GET /health
Verificar saúde da aplicação.

**Request**
```http
GET /api/health
```

**Response**
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "uptime": 3600,
  "version": "1.0.0",
  "checks": {
    "database": "ok",
    "supabase": "ok",
    "piper": "ok",
    "storage": "ok"
  }
}
```

**Status Possíveis**
- `ok`: Todos os serviços funcionando
- `degraded`: Alguns serviços com problemas
- `down`: Serviços críticos indisponíveis

## Modelos de Dados

### File (Arquivo)
```typescript
interface File {
  id: string;                    // UUID único
  originalName: string;          // Nome original do arquivo
  mimeType: string;              // Tipo MIME
  size: number;                  // Tamanho em bytes
  status: 'uploaded' | 'processing' | 'processed' | 'error';
  uploadedAt: Date;              // Data de upload
  processedAt?: Date;            // Data de processamento
  metadata?: FileMetadata;       // Metadados do arquivo
}
```

### Reading (Leitura)
```typescript
interface Reading {
  id: string;                    // UUID único
  fileId: string;                // ID do arquivo
  locale: 'pt_BR' | 'es_ES' | 'en_US';
  start: StartPosition;          // Posição de início
  speed: number;                // Velocidade (0.8 - 1.3)
  format: 'wav' | 'mp3';        // Formato de áudio
  status: 'queued' | 'processing' | 'done' | 'error';
  progress: number;             // Progresso (0-1)
  currentPage: number;          // Página atual
  totalPages: number;           // Total de páginas
  audioPath?: string;           // Caminho do áudio
  audioSize?: number;           // Tamanho do áudio
  duration?: number;            // Duração em segundos
  createdAt: Date;              // Data de criação
  completedAt?: Date;           // Data de conclusão
  errorMessage?: string;        // Mensagem de erro
}
```

### StartPosition (Posição de Início)
```typescript
interface StartPosition {
  type: 'page' | 'percent' | 'offset';
  value: number;                 // Valor da posição
}
```

### FileMetadata (Metadados do Arquivo)
```typescript
interface FileMetadata {
  pages?: number;                // Número de páginas
  wordCount?: number;            // Número de palavras
  charCount?: number;            // Número de caracteres
  language?: string;             // Idioma detectado
  title?: string;                // Título do documento
  author?: string;               // Autor do documento
}
```

### Voice (Voz)
```typescript
interface Voice {
  locale: string;                // Código do idioma
  name: string;                  // Nome do idioma
  model: string;                 // Nome do modelo
  available: boolean;            // Se está disponível
}
```

## Tratamento de Erros

### Estrutura de Erro
```typescript
interface ApiError {
  statusCode: number;            // Código HTTP
  message: string;               // Mensagem de erro
  error?: string;                // Tipo de erro
  timestamp: string;             // Timestamp do erro
  path: string;                  // Caminho da requisição
  requestId?: string;            // ID da requisição
}
```

### Códigos de Erro Comuns

#### 400 Bad Request
```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "error": "Bad Request",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "path": "/api/readings",
  "details": [
    {
      "field": "speed",
      "message": "Speed must be between 0.8 and 1.3"
    }
  ]
}
```

#### 404 Not Found
```json
{
  "statusCode": 404,
  "message": "Resource not found",
  "error": "Not Found",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "path": "/api/files/550e8400-e29b-41d4-a716-446655440000"
}
```

#### 422 Unprocessable Entity
```json
{
  "statusCode": 422,
  "message": "File cannot be processed",
  "error": "Unprocessable Entity",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "path": "/api/readings",
  "details": "File is corrupted or unsupported format"
}
```

#### 500 Internal Server Error
```json
{
  "statusCode": 500,
  "message": "Internal server error",
  "error": "Internal Server Error",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "path": "/api/readings/660e8400-e29b-41d4-a716-446655440001",
  "requestId": "req-123456"
}
```

## Validação de Dados

### Upload de Arquivo
- **Tamanho máximo**: 100MB
- **Tipos suportados**: PDF, TXT, EPUB
- **Validação**: MIME type + assinatura de arquivo

### Configuração de Leitura
- **Locale**: Deve ser um dos valores suportados
- **Speed**: Entre 0.8 e 1.3
- **Format**: `wav` ou `mp3`
- **Start**: Posição válida dentro do documento

### Validação de Start Position
```typescript
// Página
{ "type": "page", "value": 10 }     // Página 10
{ "type": "page", "value": 1 }     // Primeira página

// Percentual
{ "type": "percent", "value": 25 }  // 25% do documento
{ "type": "percent", "value": 0 }   // Início do documento

// Offset
{ "type": "offset", "value": 1000 } // Caractere 1000
{ "type": "offset", "value": 0 }    // Início do texto
```

## Webhooks (Futuro)

### Eventos Suportados
- `reading.completed`: Leitura concluída
- `reading.failed`: Leitura falhou
- `file.processed`: Arquivo processado

### Estrutura do Webhook
```json
{
  "event": "reading.completed",
  "data": {
    "readingId": "660e8400-e29b-41d4-a716-446655440001",
    "fileId": "550e8400-e29b-41d4-a716-446655440000",
    "status": "done",
    "audioUrl": "https://api.audivox.com/api/readings/660e8400-e29b-41d4-a716-446655440001/audio"
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## SDKs e Bibliotecas

### JavaScript/TypeScript
```typescript
import { AudivoxClient } from '@audivox/client';

const client = new AudivoxClient({
  baseUrl: 'https://api.audivox.com/api',
  apiKey: 'your-api-key'
});

// Upload de arquivo
const file = await client.files.upload(fileData);

// Criar leitura
const reading = await client.readings.create({
  fileId: file.id,
  locale: 'pt_BR',
  start: { type: 'page', value: 1 },
  speed: 1.0,
  format: 'wav'
});

// Obter áudio
const audio = await client.readings.getAudio(reading.id);
```

### Python
```python
from audivox import AudivoxClient

client = AudivoxClient(
    base_url='https://api.audivox.com/api',
    api_key='your-api-key'
)

# Upload de arquivo
file = client.files.upload(file_data)

# Criar leitura
reading = client.readings.create({
    'fileId': file['id'],
    'locale': 'pt_BR',
    'start': {'type': 'page', 'value': 1},
    'speed': 1.0,
    'format': 'wav'
})

# Obter áudio
audio = client.readings.get_audio(reading['id'])
```

## Exemplos de Uso

### Fluxo Completo
```bash
# 1. Upload de arquivo
curl -X POST http://localhost:3000/api/files \
  -F "file=@documento.pdf"

# Resposta: {"fileId": "550e8400-e29b-41d4-a716-446655440000"}

# 2. Criar leitura
curl -X POST http://localhost:3000/api/readings \
  -H "Content-Type: application/json" \
  -d '{
    "fileId": "550e8400-e29b-41d4-a716-446655440000",
    "locale": "pt_BR",
    "start": {"type": "page", "value": 1},
    "speed": 1.0,
    "format": "wav"
  }'

# Resposta: {"readingId": "660e8400-e29b-41d4-a716-446655440001", "status": "queued"}

# 3. Verificar status
curl http://localhost:3000/api/readings/660e8400-e29b-41d4-a716-446655440001

# Resposta: {"status": "processing", "progress": 0.42}

# 4. Baixar áudio
curl -L http://localhost:3000/api/readings/660e8400-e29b-41d4-a716-446655440001/audio \
  -o audio.wav
```

### Polling de Status
```javascript
async function waitForCompletion(readingId) {
  while (true) {
    const response = await fetch(`/api/readings/${readingId}`);
    const reading = await response.json();
    
    if (reading.status === 'done') {
      return reading;
    } else if (reading.status === 'error') {
      throw new Error(reading.errorMessage);
    }
    
    // Aguardar 2 segundos antes da próxima verificação
    await new Promise(resolve => setTimeout(resolve, 2000));
  }
}
```

## Limitações e Considerações

### Limitações Atuais
- **Tamanho de arquivo**: Máximo 100MB
- **Tipos suportados**: PDF, TXT, EPUB apenas
- **Idiomas**: Português, Espanhol, Inglês apenas
- **Concorrência**: Processamento sequencial por arquivo

### Considerações de Performance
- **Tempo de processamento**: ~2-5 segundos por página
- **Tamanho de áudio**: ~1MB por minuto de áudio
- **Retenção**: Áudios são mantidos por 24 horas
- **Rate limiting**: Aplicado por IP

### Futuras Melhorias
- **Streaming**: Suporte a streaming em tempo real
- **Webhooks**: Notificações de eventos
- **Batch processing**: Processamento em lote
- **Mais idiomas**: Suporte a mais idiomas
- **Autenticação**: Sistema de autenticação completo
