# Documentação da Lógica de Negócio - Audivox

## Visão Geral

A lógica de negócio do Audivox é centrada no processamento de documentos página por página, garantindo controle de memória, streaming contínuo e experiência fluida para o usuário. O sistema é projetado para ser simples, eficiente e escalável.

## Conceitos de Domínio

### Entidades Principais

#### File (Arquivo)
```typescript
interface File {
  id: string;                    // UUID único
  originalName: string;          // Nome original do arquivo
  mimeType: string;              // Tipo MIME (application/pdf, text/plain, etc.)
  size: number;                  // Tamanho em bytes
  path: string;                  // Caminho no storage
  uploadedAt: Date;              // Data de upload
  processedAt?: Date;            // Data de processamento
  status: 'uploaded' | 'processing' | 'processed' | 'error';
  metadata: FileMetadata;        // Metadados específicos do tipo
}
```

#### Reading (Sessão de Leitura)
```typescript
interface Reading {
  id: string;                    // UUID único
  fileId: string;                // Referência ao arquivo
  userId?: string;               // Usuário (futuro)
  locale: 'pt_BR' | 'es_ES' | 'en_US';
  start: StartPosition;          // Ponto de início
  speed: number;                // Velocidade (0.8 - 1.3)
  format: 'wav' | 'mp3';        // Formato de saída
  status: 'queued' | 'processing' | 'done' | 'error';
  progress: number;             // Progresso (0-1)
  currentPage: number;          // Página atual sendo processada
  totalPages: number;           // Total de páginas
  audioPath?: string;           // Caminho do áudio gerado
  audioSize?: number;           // Tamanho do áudio em bytes
  duration?: number;            // Duração em segundos
  createdAt: Date;              // Data de criação
  completedAt?: Date;           // Data de conclusão
  errorMessage?: string;        // Mensagem de erro se houver
}
```

#### PageIndex (Índice de Página)
```typescript
interface PageIndex {
  page: number;                  // Número da página
  startOffset: number;           // Offset inicial no texto
  endOffset: number;            // Offset final no texto
  text: string;                  // Texto da página
  wordCount: number;             // Número de palavras
  charCount: number;             // Número de caracteres
}
```

#### AudioChunk (Chunk de Áudio)
```typescript
interface AudioChunk {
  page: number;                  // Página correspondente
  audioData: Buffer;             // Dados de áudio
  duration: number;              // Duração em segundos
  size: number;                  // Tamanho em bytes
  format: 'wav' | 'mp3';        // Formato do áudio
}
```

### Value Objects

#### StartPosition (Posição de Início)
```typescript
interface StartPosition {
  type: 'page' | 'percent' | 'offset';
  value: number;                 // Valor da posição
}

// Exemplos:
// { type: 'page', value: 10 }     // Página 10
// { type: 'percent', value: 25 }  // 25% do documento
// { type: 'offset', value: 1000 } // Caractere 1000
```

#### FileMetadata (Metadados do Arquivo)
```typescript
interface FileMetadata {
  pages?: number;                // Número de páginas (PDF)
  wordCount?: number;            // Número de palavras
  charCount?: number;            // Número de caracteres
  language?: string;             // Idioma detectado
  title?: string;                // Título do documento
  author?: string;               // Autor do documento
  created?: Date;                // Data de criação
  modified?: Date;               // Data de modificação
}
```

## Regras de Negócio

### Upload de Arquivos

#### Validação de Arquivo
```typescript
class FileValidationRules {
  static readonly MAX_FILE_SIZE = 100 * 1024 * 1024; // 100MB
  static readonly ALLOWED_MIME_TYPES = [
    'application/pdf',
    'text/plain',
    'application/epub+zip'
  ];
  static readonly ALLOWED_EXTENSIONS = ['.pdf', '.txt', '.epub'];

  static validateFile(file: Express.Multer.File): ValidationResult {
    // 1. Verificar tamanho
    if (file.size > this.MAX_FILE_SIZE) {
      return { valid: false, error: 'File too large' };
    }

    // 2. Verificar tipo MIME
    if (!this.ALLOWED_MIME_TYPES.includes(file.mimetype)) {
      return { valid: false, error: 'Invalid file type' };
    }

    // 3. Verificar extensão
    const extension = path.extname(file.originalname).toLowerCase();
    if (!this.ALLOWED_EXTENSIONS.includes(extension)) {
      return { valid: false, error: 'Invalid file extension' };
    }

    // 4. Verificar assinatura de arquivo
    if (!this.validateFileSignature(file)) {
      return { valid: false, error: 'Invalid file signature' };
    }

    return { valid: true };
  }
}
```

#### Sanitização de Nome
```typescript
class FileNameSanitizer {
  static sanitize(filename: string): string {
    return filename
      .replace(/[<>:"/\\|?*]/g, '')  // Remove caracteres inválidos
      .replace(/\s+/g, '_')          // Substitui espaços por underscore
      .substring(0, 255);            // Limita tamanho
  }
}
```

### Processamento de Documentos

#### Extração de Texto
```typescript
class TextExtractionRules {
  static async extractText(file: File): Promise<PageIndex[]> {
    switch (file.mimeType) {
      case 'application/pdf':
        return this.extractFromPdf(file);
      case 'text/plain':
        return this.extractFromTxt(file);
      case 'application/epub+zip':
        return this.extractFromEpub(file);
      default:
        throw new Error('Unsupported file type');
    }
  }

  private static async extractFromPdf(file: File): Promise<PageIndex[]> {
    // 1. Tentar extração direta
    let text = await this.runPdfToText(file.path);
    
    // 2. Se falhar, tentar OCR
    if (!text || text.trim().length === 0) {
      text = await this.runOcrPdf(file.path);
    }
    
    // 3. Criar índice de páginas
    return this.createPageIndex(text);
  }
}
```

#### Criação de Índice de Páginas
```typescript
class PageIndexingRules {
  static createPageIndex(text: string): PageIndex[] {
    const pages: PageIndex[] = [];
    const pageBreaks = this.findPageBreaks(text);
    
    for (let i = 0; i < pageBreaks.length; i++) {
      const start = pageBreaks[i];
      const end = pageBreaks[i + 1] || text.length;
      
      pages.push({
        page: i + 1,
        startOffset: start,
        endOffset: end,
        text: text.substring(start, end),
        wordCount: this.countWords(text.substring(start, end)),
        charCount: end - start
      });
    }
    
    return pages;
  }

  private static findPageBreaks(text: string): number[] {
    const breaks = [0]; // Sempre começar na posição 0
    
    // Encontrar quebras de página (\f)
    const pageBreakRegex = /\f/g;
    let match;
    while ((match = pageBreakRegex.exec(text)) !== null) {
      breaks.push(match.index + 1);
    }
    
    return breaks;
  }
}
```

### Processamento de Áudio

#### Configuração de Piper TTS
```typescript
class PiperTtsRules {
  static readonly SUPPORTED_LOCALES = ['pt_BR', 'es_ES', 'en_US'];
  static readonly SPEED_RANGE = { min: 0.8, max: 1.3 };
  static readonly MAX_TEXT_LENGTH = 10000; // caracteres por página

  static validateTtsConfig(config: TtsConfig): ValidationResult {
    // 1. Verificar locale
    if (!this.SUPPORTED_LOCALES.includes(config.locale)) {
      return { valid: false, error: 'Unsupported locale' };
    }

    // 2. Verificar velocidade
    if (config.speed < this.SPEED_RANGE.min || config.speed > this.SPEED_RANGE.max) {
      return { valid: false, error: 'Speed out of range' };
    }

    // 3. Verificar formato
    if (!['wav', 'mp3'].includes(config.format)) {
      return { valid: false, error: 'Unsupported format' };
    }

    return { valid: true };
  }

  static getModelPath(locale: string): string {
    const modelMap = {
      'pt_BR': process.env.PIPER_PT_MODEL,
      'es_ES': process.env.PIPER_ES_MODEL,
      'en_US': process.env.PIPER_EN_MODEL
    };
    
    return modelMap[locale];
  }
}
```

#### Processamento Página por Página
```typescript
class PageProcessingRules {
  static async processPage(
    page: PageIndex,
    config: TtsConfig
  ): Promise<AudioChunk> {
    // 1. Validar tamanho da página
    if (page.text.length > PiperTtsRules.MAX_TEXT_LENGTH) {
      throw new Error('Page too long for processing');
    }

    // 2. Processar com Piper
    const audioData = await this.runPiper(page.text, config);
    
    // 3. Validar resultado
    if (!audioData || audioData.length === 0) {
      throw new Error('Piper processing failed');
    }

    return {
      page: page.page,
      audioData,
      duration: this.calculateDuration(audioData),
      size: audioData.length,
      format: config.format
    };
  }

  private static async runPiper(
    text: string,
    config: TtsConfig
  ): Promise<Buffer> {
    const modelPath = PiperTtsRules.getModelPath(config.locale);
    const configPath = this.getConfigPath(config.locale);
    
    return new Promise((resolve, reject) => {
      const piper = spawn(PIPER_BIN, [
        '--model', modelPath,
        '--config', configPath,
        '--length_scale', String(config.speed),
        '--output_file', tempFile
      ]);

      piper.stdin.write(text);
      piper.stdin.end();

      piper.on('close', (code) => {
        if (code === 0) {
          resolve(fs.readFileSync(tempFile));
        } else {
          reject(new Error(`Piper failed with code ${code}`));
        }
      });

      // Timeout de 30 segundos
      setTimeout(() => {
        piper.kill();
        reject(new Error('Piper timeout'));
      }, 30000);
    });
  }
}
```

### Cálculo de Progresso

#### Progresso de Leitura
```typescript
class ProgressCalculationRules {
  static calculateProgress(reading: Reading): number {
    if (reading.status === 'done') return 1.0;
    if (reading.status === 'error') return 0.0;
    if (reading.status === 'queued') return 0.0;
    
    // Progresso baseado na página atual
    return reading.currentPage / reading.totalPages;
  }

  static estimateRemainingTime(
    reading: Reading,
    averageTimePerPage: number
  ): number {
    const remainingPages = reading.totalPages - reading.currentPage;
    return remainingPages * averageTimePerPage;
  }
}
```

## Workflows de Negócio

### Workflow de Upload
```typescript
class UploadWorkflow {
  async execute(file: Express.Multer.File): Promise<File> {
    // 1. Validar arquivo
    const validation = FileValidationRules.validateFile(file);
    if (!validation.valid) {
      throw new BadRequestException(validation.error);
    }

    // 2. Sanitizar nome
    const sanitizedName = FileNameSanitizer.sanitize(file.originalname);

    // 3. Salvar arquivo
    const filePath = await this.storageService.saveFile(file, sanitizedName);

    // 4. Extrair metadados
    const metadata = await this.extractMetadata(filePath, file.mimetype);

    // 5. Criar entidade
    const fileEntity = await this.fileRepository.save({
      originalName: file.originalname,
      mimeType: file.mimetype,
      size: file.size,
      path: filePath,
      status: 'uploaded',
      metadata
    });

    return fileEntity;
  }
}
```

### Workflow de Leitura
```typescript
class ReadingWorkflow {
  async execute(dto: CreateReadingDto): Promise<Reading> {
    // 1. Validar arquivo
    const file = await this.fileService.getFile(dto.fileId);
    if (!file) {
      throw new NotFoundException('File not found');
    }

    // 2. Validar configuração TTS
    const ttsValidation = PiperTtsRules.validateTtsConfig(dto);
    if (!ttsValidation.valid) {
      throw new BadRequestException(ttsValidation.error);
    }

    // 3. Extrair texto se necessário
    if (file.status === 'uploaded') {
      await this.extractTextFromFile(file);
    }

    // 4. Criar sessão de leitura
    const reading = await this.readingRepository.save({
      fileId: dto.fileId,
      locale: dto.locale,
      start: dto.start,
      speed: dto.speed,
      format: dto.format,
      status: 'queued',
      progress: 0,
      currentPage: 0,
      totalPages: file.metadata.pages
    });

    // 5. Iniciar processamento assíncrono
    this.processReadingAsync(reading);

    return reading;
  }
}
```

### Workflow de Processamento
```typescript
class ProcessingWorkflow {
  async execute(reading: Reading): Promise<void> {
    try {
      // 1. Atualizar status
      reading.status = 'processing';
      await this.readingRepository.save(reading);

      // 2. Obter páginas do arquivo
      const pages = await this.getPagesFromFile(reading.fileId);

      // 3. Calcular página inicial
      const startPage = this.calculateStartPage(reading.start, pages);

      // 4. Processar páginas sequencialmente
      const audioChunks: AudioChunk[] = [];
      
      for (let i = startPage; i < pages.length; i++) {
        const page = pages[i];
        
        // Atualizar progresso
        reading.currentPage = i + 1;
        reading.progress = ProgressCalculationRules.calculateProgress(reading);
        await this.readingRepository.save(reading);

        // Processar página
        const audioChunk = await PageProcessingRules.processPage(page, {
          locale: reading.locale,
          speed: reading.speed,
          format: reading.format
        });

        audioChunks.push(audioChunk);
      }

      // 5. Concatenar áudios
      const finalAudio = await this.concatAudioChunks(audioChunks);

      // 6. Salvar áudio
      const audioPath = await this.storageService.saveAudio(finalAudio, reading.id);

      // 7. Finalizar
      reading.status = 'done';
      reading.audioPath = audioPath;
      reading.audioSize = finalAudio.length;
      reading.completedAt = new Date();
      await this.readingRepository.save(reading);

    } catch (error) {
      // Tratar erro
      reading.status = 'error';
      reading.errorMessage = error.message;
      await this.readingRepository.save(reading);
      
      this.logger.error('Processing failed', { readingId: reading.id, error });
    }
  }
}
```

## Casos Extremos

### Arquivo Corrompido
```typescript
class CorruptedFileHandler {
  async handle(file: File): Promise<ProcessingResult> {
    try {
      // Tentar extração normal
      return await this.normalExtraction(file);
    } catch (error) {
      // Tentar OCR
      try {
        return await this.ocrExtraction(file);
      } catch (ocrError) {
        // Marcar como erro
        return {
          success: false,
          error: 'File is corrupted and cannot be processed',
          pages: []
        };
      }
    }
  }
}
```

### Piper TTS Falha
```typescript
class PiperFailureHandler {
  async handle(page: PageIndex, config: TtsConfig): Promise<AudioChunk> {
    // Tentar com configurações diferentes
    const fallbackConfigs = [
      { ...config, speed: 1.0 }, // Velocidade padrão
      { ...config, speed: 0.9 }, // Velocidade mais lenta
      { ...config, speed: 1.1 }  // Velocidade mais rápida
    ];

    for (const fallbackConfig of fallbackConfigs) {
      try {
        return await PageProcessingRules.processPage(page, fallbackConfig);
      } catch (error) {
        this.logger.warn('Piper fallback failed', { 
          page: page.page, 
          config: fallbackConfig,
          error: error.message 
        });
      }
    }

    throw new Error('All Piper configurations failed');
  }
}
```

### Memória Insuficiente
```typescript
class MemoryManagementRules {
  static readonly MAX_MEMORY_USAGE = 1024 * 1024 * 1024; // 1GB

  static checkMemoryUsage(): boolean {
    const usage = process.memoryUsage();
    return usage.heapUsed < this.MAX_MEMORY_USAGE;
  }

  static async cleanupMemory(): Promise<void> {
    // Forçar garbage collection
    if (global.gc) {
      global.gc();
    }

    // Limpar cache de modelos se necessário
    await this.clearModelCache();
  }
}
```

## Validações de Negócio

### Validação de Start Position
```typescript
class StartPositionValidator {
  static validate(start: StartPosition, totalPages: number): ValidationResult {
    switch (start.type) {
      case 'page':
        if (start.value < 1 || start.value > totalPages) {
          return { valid: false, error: 'Page number out of range' };
        }
        break;
      
      case 'percent':
        if (start.value < 0 || start.value > 100) {
          return { valid: false, error: 'Percent out of range' };
        }
        break;
      
      case 'offset':
        if (start.value < 0) {
          return { valid: false, error: 'Offset cannot be negative' };
        }
        break;
    }

    return { valid: true };
  }
}
```

### Validação de Configuração de Leitura
```typescript
class ReadingConfigValidator {
  static validate(dto: CreateReadingDto): ValidationResult {
    // 1. Validar fileId
    if (!dto.fileId || typeof dto.fileId !== 'string') {
      return { valid: false, error: 'Invalid file ID' };
    }

    // 2. Validar locale
    if (!PiperTtsRules.SUPPORTED_LOCALES.includes(dto.locale)) {
      return { valid: false, error: 'Unsupported locale' };
    }

    // 3. Validar speed
    if (dto.speed < PiperTtsRules.SPEED_RANGE.min || 
        dto.speed > PiperTtsRules.SPEED_RANGE.max) {
      return { valid: false, error: 'Speed out of range' };
    }

    // 4. Validar format
    if (!['wav', 'mp3'].includes(dto.format)) {
      return { valid: false, error: 'Unsupported format' };
    }

    // 5. Validar start position
    return StartPositionValidator.validate(dto.start, 0); // Total pages será validado depois
  }
}
```

## Regras de Performance

### Otimização de Processamento
```typescript
class PerformanceOptimizationRules {
  static readonly OPTIMAL_PAGE_SIZE = 2000; // caracteres
  static readonly MAX_CONCURRENT_PROCESSES = 2;

  static optimizePageSize(page: PageIndex): PageIndex[] {
    if (page.text.length <= this.OPTIMAL_PAGE_SIZE) {
      return [page];
    }

    // Dividir página em chunks menores
    return this.splitPageIntoChunks(page);
  }

  private static splitPageIntoChunks(page: PageIndex): PageIndex[] {
    const chunks: PageIndex[] = [];
    const text = page.text;
    const chunkSize = this.OPTIMAL_PAGE_SIZE;

    for (let i = 0; i < text.length; i += chunkSize) {
      const chunkText = text.substring(i, i + chunkSize);
      chunks.push({
        page: page.page,
        startOffset: page.startOffset + i,
        endOffset: page.startOffset + i + chunkText.length,
        text: chunkText,
        wordCount: this.countWords(chunkText),
        charCount: chunkText.length
      });
    }

    return chunks;
  }
}
```

### Cache de Resultados
```typescript
class CacheRules {
  static readonly CACHE_TTL = 24 * 60 * 60 * 1000; // 24 horas

  static generateCacheKey(page: PageIndex, config: TtsConfig): string {
    const content = `${page.text}_${config.locale}_${config.speed}_${config.format}`;
    return crypto.createHash('md5').update(content).digest('hex');
  }

  static async getCachedAudio(cacheKey: string): Promise<Buffer | null> {
    // Implementar cache (Redis ou arquivo)
    return null; // Placeholder
  }

  static async setCachedAudio(cacheKey: string, audio: Buffer): Promise<void> {
    // Implementar cache (Redis ou arquivo)
  }
}
