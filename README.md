# Audivox
# Audivox

Leitor de livros/documentos com **voz neural offline** (Piper) em **três plataformas**:
**server (NestJS)** para processamento/stream de áudio, **web** (Next/React) como front, e **mobile** (Expo/React Native).

> **Ideia inicial**
> O usuário escolhe o **idioma** (pt-BR / es-ES / en-US), **envia um arquivo** (PDF/EPUB/TXT), define **onde começar** (página/percentual/offset) e a **velocidade** da fala. O Audivox converte o texto em **áudio natural** (WAV/MP3), permitindo **download** ou **streaming** por trechos.

---

## 👁️ Visão Geral

* **Open source friendly**: usa **Piper** (TTS neural offline) + modelos ONNX locais.
* **Monorepo**: `apps/server` (Nest), `apps/web` (Next), `apps/mobile` (Expo).
* **Processamento robusto**: extração de texto (PDF/EPUB/TXT), **OCR** automático para PDFs escaneados.
* **Controle fino**: idioma, velocidade (`length_scale`), ponto de início por **página / percentual / offset**.
* **Escalável**: fila (BullMQ/Redis) opcional para textos longos, chunking, retomada.

---

## 🧱 Arquitetura do Monorepo

```
audivox/
├── README.md                    # Este arquivo - documentação principal
├── docs/                        # Documentação completa
│   ├── business/                # Documentação empresarial
│   │   ├── index.md            # Índice empresarial
│   │   ├── CUSTOMER_PERSONAS.md
│   │   ├── CUSTOMER_JOURNEY.md
│   │   ├── PRODUCT_STRATEGY.md
│   │   └── features/           # Catálogo de recursos
│   └── technical/              # Documentação técnica
│       ├── index.md            # Índice técnico
│       ├── project_charter.md  # Carta do projeto
│       ├── API_SPECIFICATION.md # Especificação da API
│       ├── CODEBASE_GUIDE.md   # Guia da base de código
│       ├── CONTRIBUTING.md     # Guia de desenvolvimento
│       └── adr/                # Decisões arquiteturais
├── apps/                       # Aplicações
│   ├── server/                # NestJS (API, Piper runner, extração, storage)
│   ├── web/                   # Next.js (UI, upload, player, controles)
│   └── mobile/                # Flutter (upload, player)
├── packages/                   # Pacotes compartilhados
│   └── shared/                # DTOs/Types compartilhados
├── tools/                     # Scripts DevOps
├── .env.example
├── package.json               # npm / turbo
└── turbo.json                 # ou nx.json (se Nx)
```

**Gerenciador de workspace:** **npm + Turborepo** (ou Nx, se preferir).

---

## 📚 Documentação

O projeto possui documentação completa organizada em duas categorias:

### 🏢 Documentação Empresarial (`docs/business/`)
- **[Índice Empresarial](docs/business/index.md)** - Visão geral da documentação empresarial
- **[Personas do Cliente](docs/business/CUSTOMER_PERSONAS.md)** - Estudantes, profissionais ocupados, usuários de acessibilidade
- **[Jornada do Cliente](docs/business/CUSTOMER_JOURNEY.md)** - Fluxo completo do usuário
- **[Estratégia do Produto](docs/business/PRODUCT_STRATEGY.md)** - Visão, missão e posicionamento
- **[Métricas do Produto](docs/business/PRODUCT_METRICS.md)** - KPIs e indicadores de sucesso
- **[Análise Competitiva](docs/business/COMPETITIVE_LANDSCAPE.md)** - Concorrentes e diferenciação
- **[Tendências da Indústria](docs/business/INDUSTRY_TRENDS.md)** - Evolução do mercado TTS
- **[Framework de Mensagens](docs/business/MESSAGING_FRAMEWORK.md)** - Voz da marca e comunicação
- **[Recursos do Produto](docs/business/features/)** - Catálogo detalhado de funcionalidades

### 🔧 Documentação Técnica (`docs/technical/`)
- **[Índice Técnico](docs/technical/index.md)** - Visão geral da documentação técnica
- **[Carta do Projeto](docs/technical/project_charter.md)** - Visão, objetivos e critérios de sucesso
- **[Especificação da API](docs/technical/API_SPECIFICATION.md)** - Endpoints, modelos e exemplos
- **[Guia da Base de Código](docs/technical/CODEBASE_GUIDE.md)** - Estrutura e navegação do código
- **[Guia de Desenvolvimento](docs/technical/CONTRIBUTING.md)** - Fluxo de desenvolvimento e testes
- **[Solução de Problemas](docs/technical/TROUBLESHOOTING.md)** - Debug e resolução de issues
- **[Desafios Arquiteturais](docs/technical/ARCHITECTURE_CHALLENGES.md)** - Limitações e melhorias futuras
- **[Decisões Arquiteturais](docs/technical/adr/)** - ADRs documentando escolhas técnicas
- **[Guia para IA](docs/technical/CLAUDE.meta.md)** - Padrões de código e considerações para IA

---

## ⚙️ Tecnologias

* **Server**: NestJS, Piper (binário), Poppler (`pdftotext`), OCRmyPDF + Tesseract (fallback), ffmpeg/lame (MP3 opcional), BullMQ/Redis (fila opcional).
* **Web**: Next.js/React, Upload (multipart), player com controle de velocidade.
* **Mobile**: Expo/React Native, upload + player (URL assinada ou stream).

---

## 🔐 Variáveis de Ambiente (exemplo)

Crie um `.env` na raiz (ou específico em `apps/server/.env`):

```
# Piper bin e modelos
PIPER_BIN=/home/app/piper-bin/piper/piper
PIPER_PT_MODEL=/models/pt_BR-faber-medium.onnx
PIPER_PT_CFG=/models/pt_BR-faber-medium.onnx.json
PIPER_ES_MODEL=/models/es_ES-<voice>-medium.onnx
PIPER_ES_CFG=/models/es_ES-<voice>-medium.onnx.json
PIPER_EN_MODEL=/models/en_US-<voice>-medium.onnx
PIPER_EN_CFG=/models/en_US-<voice>-medium.onnx.json

# Armazenamento de áudios
STORAGE_DRIVER=local    # local|s3|supabase
STORAGE_LOCAL_PATH=./data/audio

# OCR / Extras
ENABLE_OCR=true
REDIS_URL=redis://localhost:6379

# API
PORT=3000
```

> **Observação**: Os modelos ONNX devem existir nos caminhos configurados.

---

## 📡 API (Server – NestJS)

### Rotas principais

#### `POST /files`

**Upload** de arquivo para leitura.
`multipart/form-data` com campo `file`.

**Resposta**

```json
{ "fileId": "uuid" }
```

#### `POST /readings`

Cria **sessão de leitura** a partir de um arquivo já enviado.

**Body**

```json
{
  "fileId": "uuid",
  "locale": "pt_BR",            // pt_BR | es_ES | en_US
  "start": { "type": "page", "value": 10 }, // page|percent|offset
  "speed": 1.0,                 // 0.8..1.3 (Piper length_scale)
  "format": "wav",              // wav|mp3
  "stream": false               // se true, pode retornar chunked (futuro)
}
```

**Resposta**

```json
{ "readingId": "uuid", "status": "queued" }
```

#### `GET /readings/:id`

Status da sessão (e progresso se chunking estiver ativo).

```json
{
  "id": "uuid",
  "status": "procegssing",  // queued|processing|done|error
  "progress": 0.42,
  "pages": { "start": 10, "end": 25 }
}
```

#### `GET /readings/:id/audio`

Retorna **stream** do áudio final (WAV/MP3) **ou** redireciona para **URL assinada** (Supabase).

**Query opcional**

* `range` (suporte a HTTP Range no driver local)

#### `GET /voices`

Lista vozes/idiomas disponíveis (valida se modelos existem).

---

### Exemplos (cURL)

**Upload**

```bash
curl -F "file=@/caminho/livro.pdf" http://localhost:3000/files
```

**Criar leitura**

```bash
curl -X POST http://localhost:3000/readings \
  -H "Content-Type: application/json" \
  -d '{
    "fileId": "UUID",
    "locale": "pt_BR",
    "start": { "type": "page", "value": 25 },
    "speed": 0.95,
    "format": "wav"
  }'
```

**Baixar áudio**

```bash
curl -L http://localhost:3000/readings/UUID/audio -o leitura.wav
```

---

## 🧩 Fluxo de Processamento (Server)

1. **Upload** → salva arquivo (Supabase).
2. **Detecção** → PDF/EPUB/TXT (mimetype + extensão).
3. **Extração de texto**

   * PDF: `pdftotext -layout -enc UTF-8 -nopgbrk`
   * **OCR** (se necessário): `ocrmypdf` + `pdftotext`
   * EPUB: parser simples (unzip + agregação XHTML)
   * TXT: leitura direta
   * **Índice de páginas**: `{ page, startOffset, endOffset }` para saltar por página.
4. **Start** → resolve **offset** conforme `page/percent/offset`.
5. **Segmentação** → blocos \~2–5k chars (normaliza \f, hífens, espaços).
6. **TTS Piper** → gera WAV por bloco; concatena (ou stream chunked).
7. **(Opcional) MP3** → `ffmpeg`/`lame`.
8. **Storage** → grava áudio final e metadados (duração, páginas cobertas).
9. **Entrega** → stream/URL assinada; status/progresso disponível.
10. **(Opcional) Fila** → BullMQ/Redis para jobs longos e paralelismo controlado.

---

## 🖥️ Web (Next.js)

MVP de UI:

* **Upload** com barra de progresso.
* Select de **idioma** (pt-BR/es-ES/en-US).
* Campo **início** (página/percentual/offset) e **velocidade** (slider).
* Tela de **status** (polling em `/readings/:id`).
* **Player** com botão de download (WAV/MP3), checkpoints de página.

---

## 📱 Mobile (Expo)

MVP:

* Selecionar arquivo (DocumentPicker).
* Enviar/acompanhar status.
* Player simples (seek/pausa), download local.
* Preferências persistidas (idioma/velocidade).

---

## 🚀 Como rodar (dev)

```bash
pnpm i
# Piper e modelos precisam estar instalados/configurados (.env)
pnpm -C apps/server start:dev
pnpm -C apps/web dev
pnpm -C apps/mobile start
```

> Dica: use **Turborepo** para pipelines (build/test/lint) no monorepo.

---

## 🧪 Testes

* **Server (Nest)**

  * Unit: `piper.runner` (spawn + timeouts), `pdf.extractor` (texto/OCR), cálculo de offset (`page/percent/offset`).
  * E2E: fluxo `POST /files` → `POST /readings` → `GET /readings/:id/audio`.
* **Web/Mobile**

  * Testes de integração de formulários e player (básico).

---

## 🛡️ Segurança & Limites

* Limite de upload (p.ex. 50–100 MB).
* Validação de mimetype/assinatura mágica.
* Sanitização de nomes e paths.
* Rate limit e CORS configuráveis.
* Logs estruturados (requestId/readingId), Sentry (opcional).
* Observabilidade: métricas de tempo TTS, fila, erros, memória.

---

## 🗺️ Roadmap

* **MVP**: PDF/TXT (sem OCR), PT-BR, WAV, download → DONE
* **v0.2**: ES/EN, MP3, página/intervalo, velocidade por UI
* **v0.3**: OCR automático, chunked streaming, retomada por marcador
* **v0.4**: Fila BullMQ/Redis, cache por hash (texto+params), multi-workers
* **v1.0**: Auth + biblioteca de leituras, bookmarks, anotações, player melhorado

---

## 🤝 Contribuição

* Padronize com ESLint/Prettier.
* Commits semânticos (convencional).
* PRs com descrição do fluxo (antes/depois), testes cobrindo paths críticos.

---

## 📄 Licença

A definir (sugestão: **MIT**, compatível com o Piper).

---

## 📎 Anexos úteis (server)

**Mapeamento de vozes** (`apps/server/src/modules/tts/voices.map.ts`):

```ts
export const VOICES = {
  pt_BR: { model: process.env.PIPER_PT_MODEL!, cfg: process.env.PIPER_PT_CFG! },
  es_ES: { model: process.env.PIPER_ES_MODEL!, cfg: process.env.PIPER_ES_CFG! },
  en_US:{ model: process.env.PIPER_EN_MODEL!, cfg: process.env.PIPER_EN_CFG! },
} as const;
```

**Spawn do Piper (conceito)**:

```ts
spawn(PIPER_BIN, [
  '--model', modelPath,
  '--config', cfgPath,
  '--length_scale', String(speed ?? 1.0),
  '--output_file', outPath,
], { stdio: ['pipe', 'inherit', 'pipe'] });
/* escrever texto no stdin; aguardar exit code == 0; validar arquivo */
```

---

Se quiser, eu já te entrego um **boilerplate de README + .env.example + estrutura de pastas e scripts de workspace (pnpm + turbo)**, tudo pronto pra abrir no Cursor e começar o `apps/server`.

