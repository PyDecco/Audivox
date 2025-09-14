# Arquitetura de Contexto Técnico - Audivox

## Perfil de Contexto do Projeto

**Projeto**: Audivox - Leitor de documentos com voz neural offline  
**Tipo**: MicroSaaS com desenvolvimento rápido (MVP em dias)  
**Desenvolvedor**: Desenvolvedor único com experiência em NestJS  
**Orçamento**: Zero para infraestrutura inicial  
**Ambiente**: Linux exclusivamente  
**Observabilidade**: OpenTelemetry + Prometheus + Grafana  

---

## Camada 1: Contexto Central do Projeto

### Documentação Fundamental
- **[Carta do Projeto](project_charter.md)** - Visão, objetivos, critérios de sucesso e restrições
- **[Registros de Decisões Arquiteturais](adr/)** - Decisões técnicas e trade-offs documentados
  - [ADR-001: Arquitetura Cliente-Servidor](adr/001-client-server-architecture.md)
  - [ADR-002: Stack Tecnológico](adr/002-technology-stack.md)
  - [ADR-003: Processamento Página por Página](adr/003-page-by-page-processing.md)
  - [ADR-004: Observabilidade](adr/004-observability.md)

---

## Camada 2: Arquivos de Contexto Otimizados para IA

### Guias para Desenvolvimento com IA
- **[Guia de Desenvolvimento com IA](CLAUDE.meta.md)** - Padrões de código, testes e considerações para IA
- **[Guia de Navegação da Base de Código](CODEBASE_GUIDE.md)** - Estrutura, arquivos chave e fluxos de dados

---

## Camada 3: Contexto Específico do Domínio

### Documentação Técnica Especializada
- **[Documentação da Lógica de Negócio](BUSINESS_LOGIC.md)** - Regras de negócio, workflows e casos extremos
- **[Especificações da API](API_SPECIFICATION.md)** - Endpoints, autenticação, modelos de dados e tratamento de erros

---

## Camada 4: Contexto do Fluxo de Desenvolvimento

### Guias Operacionais
- **[Guia de Fluxo de Desenvolvimento](CONTRIBUTING.md)** - Processo de desenvolvimento, testes e deploy
- **[Guia de Solução de Problemas](TROUBLESHOOTING.md)** - Problemas comuns, debug e resolução de issues
- **[Desafios Arquiteturais](ARCHITECTURE_CHALLENGES.md)** - Limitações conhecidas e melhorias futuras

---

## Stack Tecnológico

### Backend
- **Framework**: NestJS (experiência prévia do desenvolvedor)
- **TTS**: Piper TTS (processamento offline)
- **Storage**: Supabase (banco relacional + storage)
- **Extração**: Poppler (pdftotext) + OCRmyPDF + Tesseract
- **Áudio**: ffmpeg/lame (conversão MP3)

### Frontend
- **Web**: Next.js (apenas cliente, sem camada de servidor)
- **Mobile**: Flutter (não React Native/Expo)
- **Comunicação**: API REST com NestJS

### Infraestrutura
- **Containerização**: Docker + Kubernetes
- **Observabilidade**: OpenTelemetry + Prometheus + Grafana
- **Sistema**: Linux exclusivamente
- **Deploy**: A definir (foco em simplicidade)

---

## Arquitetura do Sistema

### Padrão Arquitetural
- **Tipo**: Cliente-Servidor tradicional
- **Backend**: NestJS como API única
- **Frontend**: Next.js e Flutter como clientes
- **Comunicação**: REST API direta (sem API Gateway)

### Fluxo de Dados
1. **Upload**: Cliente → NestJS → Supabase Storage
2. **Processamento**: NestJS → Piper TTS → Áudio gerado
3. **Streaming**: NestJS → Cliente (página por página)
4. **Métricas**: NestJS → OpenTelemetry → Prometheus → Grafana

---

## Decisões Arquiteturais Principais

### 1. Processamento Página por Página
- **Decisão**: Nunca permitir upload total
- **Implementação**: Piper lê página por página com streaming contínuo
- **Benefício**: Controle de memória e performance

### 2. Arquitetura Cliente-Servidor
- **Decisão**: NestJS como API única
- **Implementação**: Next.js e Flutter consomem API diretamente
- **Benefício**: Simplicidade e desenvolvimento rápido

### 3. Observabilidade Integrada
- **Decisão**: OpenTelemetry + Prometheus + Grafana
- **Implementação**: Docker/Kubernetes para coleta automática
- **Benefício**: Monitoramento sem dor de cabeça

### 4. Stack Simplificado
- **Decisão**: Tecnologias conhecidas pelo desenvolvedor
- **Implementação**: NestJS + Next.js + Flutter
- **Benefício**: Desenvolvimento rápido e confiável

---

## Estrutura de Arquivos

```
audivox/
├── README.md                                  # Documentação principal do projeto
└── docs/
    ├── business/                              # Documentação empresarial
    │   ├── index.md                           # Índice empresarial
    │   ├── CUSTOMER_PERSONAS.md              # Personas detalhadas
    │   ├── CUSTOMER_JOURNEY.md               # Jornada do cliente
    │   ├── VOICE_OF_CUSTOMER.md              # Feedback e comunicação
    │   ├── PRODUCT_STRATEGY.md               # Estratégia do produto
    │   ├── PRODUCT_METRICS.md                # Métricas e KPIs
    │   ├── COMPETITIVE_LANDSCAPE.md          # Análise competitiva
    │   ├── INDUSTRY_TRENDS.md                # Tendências de mercado
    │   ├── MESSAGING_FRAMEWORK.md            # Framework de mensagens
    │   ├── CUSTOMER_COMMUNICATION.md         # Diretrizes de comunicação
    │   └── features/                         # Catálogo de recursos
    └── technical/                             # Documentação técnica
        ├── index.md                           # Este arquivo - índice técnico
        ├── project_charter.md                 # Carta do projeto
        ├── CLAUDE.meta.md                     # Guia para IA
        ├── CODEBASE_GUIDE.md                  # Guia da base de código
        ├── BUSINESS_LOGIC.md                  # Lógica de negócio
        ├── API_SPECIFICATION.md               # Especificação da API
        ├── CONTRIBUTING.md                    # Guia de desenvolvimento
        ├── TROUBLESHOOTING.md                 # Solução de problemas
        ├── ARCHITECTURE_CHALLENGES.md         # Desafios arquiteturais
        └── adr/                               # Decisões arquiteturais
            ├── 001-client-server-architecture.md
            ├── 002-technology-stack.md
            ├── 003-page-by-page-processing.md
            └── 004-observability.md
```

---

## Objetivos da Documentação Técnica

Esta documentação técnica foi criada para permitir:

1. **Desenvolvimento rápido**: Compreensão imediata da arquitetura e decisões
2. **Assistência de IA**: Contexto completo para sistemas de IA auxiliarem no desenvolvimento
3. **Manutenção eficiente**: Guias claros para debug e solução de problemas
4. **Escalabilidade**: Base sólida para crescimento futuro do projeto
5. **Onboarding**: Novos desenvolvedores podem contribuir rapidamente

---

## Atualizações

- **Criado em**: 2024
- **Última atualização**: 2024
- **Próxima revisão**: Após implementação do MVP
- **Responsável**: Desenvolvedor principal
