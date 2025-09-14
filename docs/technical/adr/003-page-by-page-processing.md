# ADR-003: Processamento Página por Página

## Status
Aceito

## Contexto
O Piper TTS, quando não configurado corretamente, processa documentos inteiros de uma vez, causando problemas de memória e performance. O Audivox precisa de um processamento eficiente que permita streaming contínuo e controle de recursos.

## Decisão
Implementar processamento página por página com streaming contínuo, onde o Piper processa uma página por vez enquanto a próxima já está sendo preparada, garantindo fluxo fluido e controle de memória.

## Alternativas Consideradas

### 1. Processamento Completo
- **Prós**: Simples de implementar, Piper processa tudo de uma vez
- **Contras**: Alto uso de memória, sem controle de progresso, bloqueante
- **Decisão**: Rejeitado - inadequado para documentos grandes

### 2. Chunking por Tamanho
- **Prós**: Controle de memória, processamento em pedaços
- **Contras**: Quebra de contexto, páginas podem ser cortadas
- **Decisão**: Rejeitado - quebra semântica de páginas

### 3. Processamento Página por Página (Escolhido)
- **Prós**: Controle de memória, progresso granular, streaming contínuo
- **Contras**: Complexidade de implementação, sincronização necessária
- **Decisão**: Aceito - melhor experiência do usuário e controle de recursos

### 4. Processamento Assíncrono com Fila
- **Prós**: Não bloqueante, escalável, controle de recursos
- **Contras**: Complexidade excessiva para MVP, overhead de infraestrutura
- **Decisão**: Rejeitado - complexidade desnecessária para MVP

## Implementação

### Fluxo de Processamento
```
1. Upload do documento
2. Extração de texto página por página
3. Criação de índice de páginas
4. Processamento sequencial:
   - Página N → Piper TTS → Áudio N
   - Página N+1 → Piper TTS → Áudio N+1 (paralelo)
   - Concatenação de áudios
5. Streaming do resultado
```

### Estrutura de Dados
```typescript
interface PageIndex {
  page: number;
  startOffset: number;
  endOffset: number;
  text: string;
}

interface ReadingSession {
  id: string;
  fileId: string;
  currentPage: number;
  totalPages: number;
  status: 'processing' | 'done' | 'error';
  progress: number;
  audioChunks: AudioChunk[];
}
```

### Pipeline de Processamento
1. **Extração**: `pdftotext -layout -enc UTF-8 -nopgbrk`
2. **Indexação**: Criação de índice de páginas com offsets
3. **Segmentação**: Divisão em páginas individuais
4. **Processamento**: Piper TTS por página
5. **Concatenação**: União dos áudios gerados
6. **Streaming**: Entrega contínua do resultado

## Consequências

### Positivas
- **Controle de memória**: Processamento limitado por página
- **Progresso granular**: Usuário vê progresso página por página
- **Streaming contínuo**: Experiência fluida sem interrupções
- **Escalabilidade**: Pode processar documentos de qualquer tamanho
- **Debugging**: Mais fácil identificar problemas por página

### Negativas
- **Complexidade**: Implementação mais complexa
- **Sincronização**: Necessidade de coordenar processamento
- **Latência**: Tempo adicional para indexação
- **Armazenamento**: Necessidade de armazenar áudios intermediários

## Detalhes Técnicos

### Extração de Texto
```bash
# Comando para extração com layout preservado
pdftotext -layout -enc UTF-8 -nopgbrk input.pdf output.txt

# Fallback com OCR se necessário
ocrmypdf --force-ocr input.pdf output_ocr.pdf
pdftotext -layout -enc UTF-8 -nopgbrk output_ocr.pdf output.txt
```

### Indexação de Páginas
```typescript
interface PageIndex {
  page: number;
  startOffset: number;
  endOffset: number;
  text: string;
  wordCount: number;
}

function createPageIndex(text: string): PageIndex[] {
  // Implementação de indexação por página
  // Considera quebras de página (\f) e formatação
}
```

### Processamento com Piper
```typescript
async function processPageWithPiper(
  text: string,
  locale: string,
  speed: number
): Promise<Buffer> {
  const model = getModelForLocale(locale);
  const config = getConfigForLocale(locale);
  
  return new Promise((resolve, reject) => {
    const piper = spawn(PIPER_BIN, [
      '--model', model,
      '--config', config,
      '--length_scale', String(speed),
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
  });
}
```

### Streaming Contínuo
```typescript
class StreamingProcessor {
  private currentPage = 0;
  private totalPages = 0;
  private audioChunks: Buffer[] = [];
  
  async processDocument(fileId: string): Promise<Readable> {
    const pages = await this.extractPages(fileId);
    this.totalPages = pages.length;
    
    return new Readable({
      read() {
        this.processNextPage();
      }
    });
  }
  
  private async processNextPage() {
    if (this.currentPage >= this.totalPages) {
      this.push(null); // End stream
      return;
    }
    
    const page = this.pages[this.currentPage];
    const audio = await this.processPageWithPiper(page.text);
    
    this.audioChunks.push(audio);
    this.push(audio);
    
    this.currentPage++;
    this.processNextPage(); // Process next page
  }
}
```

## Monitoramento

### Métricas
- **Tempo por página**: Duração do processamento por página
- **Memória utilizada**: Uso de RAM durante processamento
- **Taxa de sucesso**: Percentual de páginas processadas com sucesso
- **Progresso**: Páginas processadas vs total

### Logs
```typescript
logger.info('Processing page', {
  readingId,
  page: currentPage,
  totalPages,
  textLength: page.text.length,
  processingTime: Date.now() - startTime
});
```

## Tratamento de Erros

### Erros por Página
- **Página vazia**: Pular página e continuar
- **Erro de Piper**: Tentar novamente com configurações diferentes
- **Falha de OCR**: Usar fallback ou marcar como erro
- **Timeout**: Cancelar processamento e retornar erro

### Recuperação
- **Retry automático**: Tentar processar página novamente
- **Fallback**: Usar configurações alternativas
- **Graceful degradation**: Continuar com páginas que funcionaram
- **Error reporting**: Log detalhado de erros

## Revisão
Esta decisão será revisada quando:
- Necessidade de processamento mais rápido
- Problemas de performance identificados
- Requisitos de processamento em lote
- Feedback negativo sobre experiência de streaming
