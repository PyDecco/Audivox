# Audivox MVP - Quadro Kanban de Desenvolvimento

## 📋 To Do

### INFRA-001: Setup do Ambiente de Desenvolvimento

  - due: 2024-09-14
  - tags: [infra, setup, docker]
  - priority: high
  - workload: Easy
  - steps:
      - [ ] Criar docker-compose.yml com PostgreSQL, Redis, Prometheus
      - [ ] Criar scripts de setup automatizados
      - [ ] Configurar variáveis de ambiente (.env.example)
      - [ ] Implementar health checks básicos
    ```md
    **Como** desenvolvedor  
    **Quero** ter um ambiente de desenvolvimento configurado  
    **Para** poder desenvolver o MVP rapidamente  
    
    **Critérios de Aceitação:**
    - Docker Compose com serviços básicos (PostgreSQL, Redis, Prometheus)
    - Scripts de setup automatizados
    - Variáveis de ambiente configuradas
    - Health checks básicos funcionando
    
    **Estimativa**: 30 minutos
    ```

### INFRA-002: Configuração do Supabase

  - due: 2024-09-14
  - tags: [infra, supabase, database]
  - priority: high
  - workload: Easy
  - steps:
      - [ ] Criar projeto Supabase
      - [ ] Criar tabelas básicas (files, readings)
      - [ ] Configurar storage bucket
      - [ ] Testar conexão
    ```md
    **Como** desenvolvedor  
    **Quero** ter Supabase configurado e conectado  
    **Para** armazenar arquivos e metadados  
    
    **Critérios de Aceitação:**
    - Projeto Supabase criado
    - Tabelas básicas criadas (files, readings)
    - Storage bucket configurado
    - Conexão testada e funcionando
    
    **Estimativa**: 20 minutos
    ```

### INFRA-003: Setup do Piper TTS

  - due: 2024-09-14
  - tags: [infra, piper, tts]
  - priority: high
  - workload: Normal
  - steps:
      - [ ] Baixar binário Piper
      - [ ] Baixar modelos ONNX (pt_BR, es_ES, en_US)
      - [ ] Configurar variáveis de ambiente
      - [ ] Teste básico de conversão
    ```md
    **Como** desenvolvedor  
    **Quero** ter Piper TTS configurado e funcionando  
    **Para** converter texto em áudio  
    
    **Critérios de Aceitação:**
    - Binário Piper baixado e configurado
    - Modelos ONNX para pt_BR, es_ES, en_US
    - Teste básico de conversão funcionando
    - Variáveis de ambiente configuradas
    
    **Estimativa**: 45 minutos
    ```

### BACK-001: Setup do Projeto NestJS

  - due: 2024-09-14
  - tags: [backend, nestjs, setup]
  - priority: high
  - workload: Easy
  - steps:
      - [ ] Criar projeto NestJS com TypeScript
      - [ ] Organizar estrutura de módulos
      - [ ] Configurar ambiente
      - [ ] Implementar health check endpoint
      - [ ] Configurar CORS para frontend
    ```md
    **Como** desenvolvedor  
    **Quero** ter um projeto NestJS básico configurado  
    **Para** criar a API do sistema  
    
    **Critérios de Aceitação:**
    - Projeto NestJS criado com TypeScript
    - Estrutura de módulos organizada
    - Configuração de ambiente
    - Health check endpoint funcionando
    - CORS configurado para frontend
    
    **Estimativa**: 30 minutos
    ```

### BACK-002: Módulo de Upload de Arquivos

  - due: 2024-09-14
  - tags: [backend, upload, files]
  - priority: high
  - workload: Normal
  - steps:
      - [ ] Implementar POST /files endpoint
      - [ ] Implementar GET /files/:id endpoint
      - [ ] Validação de tipo MIME e assinatura
      - [ ] Sanitização de nomes de arquivo
      - [ ] Rate limiting (10 requests/15min)
      - [ ] Integração com Supabase Storage
    ```md
    **Como** desenvolvedor  
    **Quero** ter endpoints para upload e gerenciamento de arquivos  
    **Para** permitir que usuários enviem documentos  
    
    **Critérios de Aceitação:**
    - POST /files endpoint para upload
    - GET /files/:id endpoint para informações
    - Validação de tipo MIME e assinatura
    - Sanitização de nomes de arquivo
    - Rate limiting (10 requests/15min)
    - Integração com Supabase Storage
    
    **Estimativa**: 60 minutos
    ```

### BACK-003: Extração de Texto de Documentos

  - due: 2024-09-14
  - tags: [backend, extraction, pdf, epub]
  - priority: high
  - workload: Hard
  - steps:
      - [ ] Integração com Poppler (pdftotext)
      - [ ] Suporte a EPUB (extração de texto)
      - [ ] Suporte a TXT (leitura direta)
      - [ ] OCR automático para PDFs escaneados
      - [ ] Criação de índice de páginas
      - [ ] Tratamento de erros robusto
    ```md
    **Como** desenvolvedor  
    **Quero** extrair texto de PDFs, EPUBs e TXTs  
    **Para** preparar o conteúdo para conversão TTS  
    
    **Critérios de Aceitação:**
    - Integração com Poppler (pdftotext)
    - Suporte a EPUB (extração de texto)
    - Suporte a TXT (leitura direta)
    - OCR automático para PDFs escaneados
    - Criação de índice de páginas
    - Tratamento de erros robusto
    
    **Estimativa**: 90 minutos
    ```

### BACK-004: Integração com Piper TTS

  - due: 2024-09-14
  - tags: [backend, piper, tts, audio]
  - priority: high
  - workload: Hard
  - steps:
      - [ ] Wrapper para execução do Piper
      - [ ] Suporte a múltiplos idiomas (pt_BR, es_ES, en_US)
      - [ ] Processamento página por página
      - [ ] Controle de velocidade (length_scale)
      - [ ] Timeout e tratamento de erros
      - [ ] Cache de modelos para performance
    ```md
    **Como** desenvolvedor  
    **Quero** integrar Piper TTS para conversão de texto em áudio  
    **Para** gerar áudio neural de alta qualidade  
    
    **Critérios de Aceitação:**
    - Wrapper para execução do Piper
    - Suporte a múltiplos idiomas (pt_BR, es_ES, en_US)
    - Processamento página por página
    - Controle de velocidade (length_scale)
    - Timeout e tratamento de erros
    - Cache de modelos para performance
    
    **Estimativa**: 120 minutos
    ```

### BACK-005: Módulo de Leituras (Readings)

  - due: 2024-09-14
  - tags: [backend, readings, processing]
  - priority: high
  - workload: Normal
  - steps:
      - [ ] POST /readings endpoint para criar sessão
      - [ ] GET /readings/:id endpoint para status
      - [ ] Processamento assíncrono de documentos
      - [ ] Cálculo de progresso página por página
      - [ ] Persistência de status no banco
      - [ ] Tratamento de erros e retry
    ```md
    **Como** desenvolvedor  
    **Quero** gerenciar sessões de leitura e processamento  
    **Para** orquestrar a conversão de documentos  
    
    **Critérios de Aceitação:**
    - POST /readings endpoint para criar sessão
    - GET /readings/:id endpoint para status
    - Processamento assíncrono de documentos
    - Cálculo de progresso página por página
    - Persistência de status no banco
    - Tratamento de erros e retry
    
    **Estimativa**: 90 minutos
    ```

### BACK-006: Streaming de Áudio

  - due: 2024-09-14
  - tags: [backend, streaming, audio]
  - priority: medium
  - workload: Normal
  - steps:
      - [ ] GET /readings/:id/audio endpoint
      - [ ] Suporte a Range requests
      - [ ] Streaming eficiente de arquivos grandes
      - [ ] Headers apropriados (Content-Type, Content-Length)
      - [ ] Cache de áudio no Supabase Storage
      - [ ] Validação de permissões
    ```md
    **Como** desenvolvedor  
    **Quero** fornecer streaming de áudio gerado  
    **Para** permitir reprodução durante download  
    
    **Critérios de Aceitação:**
    - GET /readings/:id/audio endpoint
    - Suporte a Range requests
    - Streaming eficiente de arquivos grandes
    - Headers apropriados (Content-Type, Content-Length)
    - Cache de áudio no Supabase Storage
    - Validação de permissões
    
    **Estimativa**: 45 minutos
    ```

### BACK-007: Observabilidade Básica

  - due: 2024-09-14
  - tags: [backend, observability, logs]
  - priority: medium
  - workload: Easy
  - steps:
      - [ ] Logs estruturados com contexto
      - [ ] Métricas básicas (requests, tempo de processamento)
      - [ ] Health checks abrangentes
      - [ ] Integração com Prometheus
      - [ ] Tratamento de erros centralizado
    ```md
    **Como** desenvolvedor  
    **Quero** ter métricas e logs básicos  
    **Para** monitorar o sistema e debugar problemas  
    
    **Critérios de Aceitação:**
    - Logs estruturados com contexto
    - Métricas básicas (requests, tempo de processamento)
    - Health checks abrangentes
    - Integração com Prometheus
    - Tratamento de erros centralizado
    
    **Estimativa**: 30 minutos
    ```

### FRONT-001: Setup do Projeto Next.js

  - due: 2024-09-14
  - tags: [frontend, nextjs, setup]
  - priority: high
  - workload: Easy
  - steps:
      - [ ] Criar projeto Next.js com TypeScript
      - [ ] Configurar Tailwind CSS
      - [ ] Organizar estrutura de pastas
      - [ ] Configurar cliente HTTP para API
    ```md
    **Como** desenvolvedor  
    **Quero** ter um projeto Next.js básico configurado  
    **Para** criar a interface do usuário  
    
    **Critérios de Aceitação:**
    - Projeto Next.js criado com TypeScript
    - Tailwind CSS configurado
    - Estrutura de pastas organizada
    - Cliente HTTP configurado para API
    
    **Estimativa**: 20 minutos
    ```

### FRONT-002: Página de Upload de Arquivo

  - due: 2024-09-14
  - tags: [frontend, upload, ui]
  - priority: high
  - workload: Normal
  - steps:
      - [ ] Interface drag & drop funcional
      - [ ] Validação de tipo de arquivo (PDF, EPUB, TXT)
      - [ ] Validação de tamanho (máx 100MB)
      - [ ] Barra de progresso durante upload
      - [ ] Mensagens de erro claras
      - [ ] Feedback visual de sucesso
    ```md
    **Como** usuário  
    **Quero** poder fazer upload de um arquivo PDF/EPUB/TXT  
    **Para** convertê-lo em áudio  
    
    **Critérios de Aceitação:**
    - Interface drag & drop funcional
    - Validação de tipo de arquivo (PDF, EPUB, TXT)
    - Validação de tamanho (máx 100MB)
    - Barra de progresso durante upload
    - Mensagens de erro claras
    - Feedback visual de sucesso
    
    **Estimativa**: 60 minutos
    ```

### FRONT-003: Seleção de Idioma

  - due: 2024-09-14
  - tags: [frontend, language, ui]
  - priority: medium
  - workload: Easy
  - steps:
      - [ ] Dropdown com idiomas (Português, Espanhol, Inglês)
      - [ ] Validação de seleção obrigatória
      - [ ] Interface intuitiva e clara
      - [ ] Persistência da seleção durante sessão
    ```md
    **Como** usuário  
    **Quero** escolher o idioma para conversão  
    **Para** ter o áudio no idioma correto  
    
    **Critérios de Aceitação:**
    - Dropdown com idiomas (Português, Espanhol, Inglês)
    - Validação de seleção obrigatória
    - Interface intuitiva e clara
    - Persistência da seleção durante sessão
    
    **Estimativa**: 15 minutos
    ```

### FRONT-004: Configuração de Leitura

  - due: 2024-09-14
  - tags: [frontend, reading, config]
  - priority: high
  - workload: Normal
  - steps:
      - [ ] Seleção de ponto inicial (página, percentual, offset)
      - [ ] Controle de velocidade (0.8 - 1.3)
      - [ ] Preview do PDF durante configuração
      - [ ] Validação de parâmetros
      - [ ] Interface responsiva
    ```md
    **Como** usuário  
    **Quero** configurar onde começar a leitura e a velocidade  
    **Para** personalizar minha experiência de áudio  
    
    **Critérios de Aceitação:**
    - Seleção de ponto inicial (página, percentual, offset)
    - Controle de velocidade (0.8 - 1.3)
    - Preview do PDF durante configuração
    - Validação de parâmetros
    - Interface responsiva
    
    **Estimativa**: 45 minutos
    ```

### FRONT-005: Player de Áudio

  - due: 2024-09-14
  - tags: [frontend, player, audio]
  - priority: high
  - workload: Normal
  - steps:
      - [ ] Player básico (play/pause/seek)
      - [ ] Controle de velocidade de reprodução
      - [ ] Barra de progresso
      - [ ] Download do arquivo de áudio
      - [ ] Indicador de carregamento durante processamento
    ```md
    **Como** usuário  
    **Quero** reproduzir o áudio gerado  
    **Para** ouvir meu documento convertido  
    
    **Critérios de Aceitação:**
    - Player básico (play/pause/seek)
    - Controle de velocidade de reprodução
    - Barra de progresso
    - Download do arquivo de áudio
    - Indicador de carregamento durante processamento
    
    **Estimativa**: 45 minutos
    ```

### FRONT-006: Página de Status de Processamento

  - due: 2024-09-14
  - tags: [frontend, status, progress]
  - priority: medium
  - workload: Easy
  - steps:
      - [ ] Indicador de progresso em tempo real
      - [ ] Status atual (processando página X de Y)
      - [ ] Tempo estimado de conclusão
      - [ ] Opção de cancelar processamento
      - [ ] Redirecionamento automático quando concluído
    ```md
    **Como** usuário  
    **Quero** acompanhar o progresso da conversão  
    **Para** saber quando o áudio estará pronto  
    
    **Critérios de Aceitação:**
    - Indicador de progresso em tempo real
    - Status atual (processando página X de Y)
    - Tempo estimado de conclusão
    - Opção de cancelar processamento
    - Redirecionamento automático quando concluído
    
    **Estimativa**: 30 minutos
    ```

## 🔄 In Progress

## ✅ Done

## 🎯 Como Usar Este Quadro Kanban

## 📋 ORDEM DE IMPLEMENTAÇÃO SUGERIDA

### Fase 1: Infraestrutura Base (1h 35min)


### Fase 2: Backend Core (4h 15min)


### Fase 3: Frontend (3h 15min)


### Fase 4: Integração e Testes (1h)


## 🎯 CRITÉRIOS DE SUCESSO DO MVP

### Funcionalidades Essenciais


### Upload de PDF/EPUB/TXT funcionando


### Conversão para áudio neural com Piper TTS


### Processamento página por página implementado


### Interface web funcional e responsiva


### Player de áudio com controles básicos


### Download de áudio gerado


### Qualidade Mínima


### Tratamento de erros básico


### Logs estruturados para debug


### Performance aceitável (< 30s para documentos típicos)


### Interface intuitiva e fácil de usar


### Demonstração


### MVP demonstrável com documento de exemplo


### Fluxo completo funcionando (upload → conversão → reprodução)


### Documentação básica de uso


## 🚀 PRÓXIMOS PASSOS

