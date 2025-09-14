# Guia de Desenvolvimento com IA - Audivox

## Visão Geral

Este guia fornece contexto específico para sistemas de IA auxiliarem no desenvolvimento do Audivox, incluindo padrões de código, abordagens de teste, considerações de performance e limitações conhecidas.

## Padrões de Código

### Estrutura de Arquivos NestJS
```
apps/server/src/
├── modules/
│   ├── files/           # Upload e gerenciamento de arquivos
│   ├── readings/         # Sessões de leitura e processamento
│   ├── tts/             # Integração com Piper TTS
│   └── storage/          # Integração com Supabase
├── common/
│   ├── decorators/       # Decorators customizados
│   ├── filters/          # Exception filters
│   ├── guards/           # Guards de autenticação/autorização
│   ├── interceptors/     # Interceptors para logging/métricas
│   └── pipes/            # Validation pipes
├── config/               # Configurações da aplicação
└── main.ts               # Bootstrap da aplicação
```

### Convenções de Nomenclatura
- **Controllers**: `FilesController`, `ReadingsController`
- **Services**: `FilesService`, `ReadingsService`, `TtsService`
- **DTOs**: `CreateReadingDto`, `UpdateReadingDto`
- **Entities**: `File`, `Reading`, `AudioChunk`
- **Interfaces**: `IPageIndex`, `IAudioProcessor`

### Padrões de Implementação

#### Controllers
```typescript
@Controller('readings')
@ApiTags('readings')
export class ReadingsController {
  constructor(private readonly readingsService: ReadingsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new reading session' })
  @ApiResponse({ status: 201, description: 'Reading created successfully' })
  async create(@Body() createReadingDto: CreateReadingDto): Promise<ReadingResponse> {
    return this.readingsService.create(createReadingDto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get reading status' })
  async getStatus(@Param('id') id: string): Promise<ReadingStatus> {
    return this.readingsService.getStatus(id);
  }
}
```

#### Services
```typescript
@Injectable()
export class ReadingsService {
  constructor(
    private readonly filesService: FilesService,
    private readonly ttsService: TtsService,
    private readonly storageService: StorageService,
    @InjectRepository(Reading) private readonly readingRepo: Repository<Reading>
  ) {}

  async create(dto: CreateReadingDto): Promise<ReadingResponse> {
    // Implementação com tratamento de erro
    try {
      const reading = await this.processDocument(dto);
      return { readingId: reading.id, status: 'queued' };
    } catch (error) {
      this.logger.error('Failed to create reading', { error, dto });
      throw new InternalServerErrorException('Failed to process document');
    }
  }
}
```

#### DTOs com Validação
```typescript
export class CreateReadingDto {
  @IsUUID()
  @ApiProperty({ description: 'File ID' })
  fileId: string;

  @IsIn(['pt_BR', 'es_ES', 'en_US'])
  @ApiProperty({ description: 'Locale for TTS', enum: ['pt_BR', 'es_ES', 'en_US'] })
  locale: string;

  @ValidateNested()
  @Type(() => StartPositionDto)
  @ApiProperty({ description: 'Starting position' })
  start: StartPositionDto;

  @IsNumber()
  @Min(0.8)
  @Max(1.3)
  @ApiProperty({ description: 'Speech speed', minimum: 0.8, maximum: 1.3 })
  speed: number;

  @IsIn(['wav', 'mp3'])
  @ApiProperty({ description: 'Audio format', enum: ['wav', 'mp3'] })
  format: string;
}
```

### Padrões de Error Handling
```typescript
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  constructor(private readonly logger: Logger) {}

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    const status = exception instanceof HttpException 
      ? exception.getStatus() 
      : HttpStatus.INTERNAL_SERVER_ERROR;

    const message = exception instanceof HttpException
      ? exception.getResponse()
      : 'Internal server error';

    this.logger.error('Exception caught', {
      status,
      message,
      url: request.url,
      method: request.method,
      timestamp: new Date().toISOString()
    });

    response.status(status).json({
      statusCode: status,
      message,
      timestamp: new Date().toISOString(),
      path: request.url
    });
  }
}
```

## Abordagens de Teste

### Estrutura de Testes
```
apps/server/test/
├── unit/                 # Testes unitários
│   ├── services/         # Testes de services
│   ├── controllers/      # Testes de controllers
│   └── utils/           # Testes de utilitários
├── integration/          # Testes de integração
│   ├── api/             # Testes de endpoints
│   └── database/        # Testes de banco
└── e2e/                 # Testes end-to-end
    └── readings.e2e-spec.ts
```

### Testes Unitários
```typescript
describe('ReadingsService', () => {
  let service: ReadingsService;
  let mockFilesService: jest.Mocked<FilesService>;
  let mockTtsService: jest.Mocked<TtsService>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ReadingsService,
        { provide: FilesService, useValue: mockFilesService },
        { provide: TtsService, useValue: mockTtsService }
      ]
    }).compile();

    service = module.get<ReadingsService>(ReadingsService);
  });

  describe('create', () => {
    it('should create a reading session successfully', async () => {
      const dto: CreateReadingDto = {
        fileId: 'file-123',
        locale: 'pt_BR',
        start: { type: 'page', value: 1 },
        speed: 1.0,
        format: 'wav'
      };

      mockFilesService.getFile.mockResolvedValue(mockFile);
      mockTtsService.processDocument.mockResolvedValue(mockAudio);

      const result = await service.create(dto);

      expect(result).toEqual({ readingId: expect.any(String), status: 'queued' });
      expect(mockFilesService.getFile).toHaveBeenCalledWith('file-123');
    });
  });
});
```

### Testes de Integração
```typescript
describe('ReadingsController (Integration)', () => {
  let app: INestApplication;
  let filesService: FilesService;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule]
    }).compile();

    app = moduleFixture.createNestApplication();
    filesService = moduleFixture.get<FilesService>(FilesService);
    await app.init();
  });

  it('/readings (POST)', () => {
    return request(app.getHttpServer())
      .post('/readings')
      .send({
        fileId: 'test-file-id',
        locale: 'pt_BR',
        start: { type: 'page', value: 1 },
        speed: 1.0,
        format: 'wav'
      })
      .expect(201)
      .expect((res) => {
        expect(res.body).toHaveProperty('readingId');
        expect(res.body).toHaveProperty('status', 'queued');
      });
  });
});
```

### Testes de Piper TTS
```typescript
describe('TtsService', () => {
  let service: TtsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [TtsService]
    }).compile();

    service = module.get<TtsService>(TtsService);
  });

  describe('processPageWithPiper', () => {
    it('should process text with Piper TTS', async () => {
      const text = 'Hello world';
      const locale = 'pt_BR';
      const speed = 1.0;

      const result = await service.processPageWithPiper(text, locale, speed);

      expect(result).toBeInstanceOf(Buffer);
      expect(result.length).toBeGreaterThan(0);
    });

    it('should handle Piper errors gracefully', async () => {
      const invalidText = '';
      const locale = 'pt_BR';
      const speed = 1.0;

      await expect(
        service.processPageWithPiper(invalidText, locale, speed)
      ).rejects.toThrow('Piper processing failed');
    });
  });
});
```

## Considerações de Performance

### Otimizações de Memória
```typescript
// Processamento página por página para controle de memória
class PageProcessor {
  private readonly MAX_PAGE_SIZE = 5000; // caracteres
  private readonly CHUNK_SIZE = 1000;    // caracteres por chunk

  async processPage(page: PageIndex): Promise<Buffer> {
    if (page.text.length > this.MAX_PAGE_SIZE) {
      return this.processLargePage(page);
    }
    return this.processPageWithPiper(page.text);
  }

  private async processLargePage(page: PageIndex): Promise<Buffer> {
    const chunks = this.splitIntoChunks(page.text);
    const audioChunks: Buffer[] = [];

    for (const chunk of chunks) {
      const audio = await this.processPageWithPiper(chunk);
      audioChunks.push(audio);
    }

    return this.concatAudioChunks(audioChunks);
  }
}
```

### Cache de Modelos
```typescript
@Injectable()
export class TtsService {
  private modelCache = new Map<string, any>();

  async getModelForLocale(locale: string): Promise<any> {
    if (this.modelCache.has(locale)) {
      return this.modelCache.get(locale);
    }

    const model = await this.loadModel(locale);
    this.modelCache.set(locale, model);
    return model;
  }

  private async loadModel(locale: string): Promise<any> {
    // Carregamento lazy de modelos Piper
    const modelPath = this.getModelPath(locale);
    return fs.readFileSync(modelPath);
  }
}
```

### Streaming de Resposta
```typescript
@Get(':id/audio')
async getAudio(@Param('id') id: string, @Res() res: Response): Promise<void> {
  const reading = await this.readingsService.getReading(id);
  
  if (reading.status !== 'done') {
    throw new BadRequestException('Reading not completed');
  }

  const audioStream = await this.storageService.getAudioStream(reading.audioPath);
  
  res.setHeader('Content-Type', 'audio/wav');
  res.setHeader('Content-Length', reading.audioSize);
  res.setHeader('Accept-Ranges', 'bytes');
  
  audioStream.pipe(res);
}
```

## Padrões de Segurança

### Validação de Upload
```typescript
@Post('files')
@UseInterceptors(FileInterceptor('file', {
  limits: { fileSize: 100 * 1024 * 1024 }, // 100MB
  fileFilter: (req, file, callback) => {
    const allowedMimes = ['application/pdf', 'text/plain', 'application/epub+zip'];
    if (allowedMimes.includes(file.mimetype)) {
      callback(null, true);
    } else {
      callback(new BadRequestException('Invalid file type'), false);
    }
  }
}))
async uploadFile(@UploadedFile() file: Express.Multer.File): Promise<FileResponse> {
  // Validação adicional de assinatura de arquivo
  const isValid = await this.validateFileSignature(file);
  if (!isValid) {
    throw new BadRequestException('Invalid file signature');
  }

  return this.filesService.saveFile(file);
}
```

### Rate Limiting
```typescript
@Injectable()
export class RateLimitGuard implements CanActivate {
  private readonly requests = new Map<string, number[]>();

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const ip = request.ip;
    const now = Date.now();
    const windowMs = 15 * 60 * 1000; // 15 minutos
    const maxRequests = 10; // 10 requests por janela

    const userRequests = this.requests.get(ip) || [];
    const recentRequests = userRequests.filter(time => now - time < windowMs);

    if (recentRequests.length >= maxRequests) {
      throw new TooManyRequestsException('Rate limit exceeded');
    }

    recentRequests.push(now);
    this.requests.set(ip, recentRequests);

    return true;
  }
}
```

### Sanitização de Dados
```typescript
@Injectable()
export class SanitizationPipe implements PipeTransform {
  transform(value: any): any {
    if (typeof value === 'string') {
      return value.trim().replace(/[<>]/g, '');
    }
    
    if (typeof value === 'object' && value !== null) {
      return this.sanitizeObject(value);
    }
    
    return value;
  }

  private sanitizeObject(obj: any): any {
    const sanitized = {};
    for (const [key, val] of Object.entries(obj)) {
      sanitized[key] = this.transform(val);
    }
    return sanitized;
  }
}
```

## Limitações Conhecidas

### Piper TTS
- **Timeout**: Piper pode falhar com textos muito longos (>10k caracteres)
- **Memória**: Modelos ONNX consomem ~500MB de RAM por idioma
- **Latência**: Primeira execução pode ser lenta devido ao carregamento do modelo
- **Fallback**: Sem fallback automático se Piper falhar

### Supabase
- **Rate Limits**: Limites de API podem ser atingidos com uso intenso
- **Storage**: Limite de 1GB no plano gratuito
- **Conectividade**: Dependência de internet para storage

### Processamento de Arquivos
- **OCR**: Pode ser lento para PDFs escaneados grandes
- **Formato**: Alguns PDFs podem não ser processados corretamente
- **Encoding**: Problemas com caracteres especiais em alguns documentos

## Pegadinhas Comuns

### 1. Piper TTS Timeout
```typescript
// ❌ Errado - sem timeout
const piper = spawn(PIPER_BIN, args);

// ✅ Correto - com timeout
const piper = spawn(PIPER_BIN, args);
const timeout = setTimeout(() => {
  piper.kill();
  reject(new Error('Piper timeout'));
}, 30000); // 30 segundos
```

### 2. Memory Leaks
```typescript
// ❌ Errado - não limpa streams
const audioStream = fs.createReadStream(audioPath);
audioStream.pipe(response);

// ✅ Correto - limpa streams
const audioStream = fs.createReadStream(audioPath);
audioStream.pipe(response);
audioStream.on('end', () => audioStream.destroy());
```

### 3. Validação de Arquivo
```typescript
// ❌ Errado - apenas extensão
if (!file.originalname.endsWith('.pdf')) {
  throw new Error('Invalid file');
}

// ✅ Correto - validação de MIME type e assinatura
const isValidMime = allowedMimes.includes(file.mimetype);
const isValidSignature = await validateFileSignature(file);
if (!isValidMime || !isValidSignature) {
  throw new Error('Invalid file');
}
```

## Debugging

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
@Get('health')
async getHealth(): Promise<HealthCheckResult> {
  const checks = await this.health.check([
    () => this.checkDatabase(),
    () => this.checkSupabase(),
    () => this.checkPiperTts()
  ]);

  return checks;
}
```

## Considerações para IA

### Contexto de Desenvolvimento
- **Prioridade**: Desenvolvimento rápido (MVP em dias)
- **Desenvolvedor**: Único com experiência em NestJS
- **Orçamento**: Zero para infraestrutura inicial
- **Foco**: Funcionalidade core primeiro, otimizações depois

### Padrões Esperados
- **Código limpo**: Seguir convenções do NestJS
- **Tratamento de erro**: Sempre tratar erros graciosamente
- **Logs**: Incluir contexto suficiente para debug
- **Testes**: Testes básicos para funcionalidades críticas
- **Documentação**: Comentários em código complexo

### Limitações a Considerar
- **Piper TTS**: Pode falhar com textos muito longos
- **Supabase**: Rate limits e limites de storage
- **Memória**: Processamento página por página é crítico
- **Performance**: Foco em funcionalidade, otimização depois
