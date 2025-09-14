# ADR-002: Stack Tecnológico

## Status
Aceito

## Contexto
O Audivox precisa de um stack tecnológico que permita desenvolvimento rápido (MVP em dias) com um desenvolvedor único, focando em tecnologias conhecidas e ferramentas adequadas para processamento de áudio offline.

## Decisão
Adotar stack tecnológico baseado em NestJS (backend), Next.js (web), Flutter (mobile), Supabase (storage/banco), Piper TTS (processamento de áudio) e OpenTelemetry (observabilidade).

## Alternativas Consideradas

### Backend Framework

#### 1. Express.js
- **Prós**: Simples, flexível, grande comunidade
- **Contras**: Menos estrutura, mais código boilerplate
- **Decisão**: Rejeitado - NestJS oferece mais estrutura e produtividade

#### 2. Fastify
- **Prós**: Performance alta, TypeScript nativo
- **Contras**: Menos recursos built-in, curva de aprendizado
- **Decisão**: Rejeitado - NestJS tem mais recursos prontos

#### 3. NestJS (Escolhido)
- **Prós**: Estrutura robusta, TypeScript nativo, experiência prévia do desenvolvedor
- **Contras**: Overhead de abstrações
- **Decisão**: Aceito - experiência prévia e produtividade

### Frontend Web

#### 1. React + Vite
- **Prós**: Simples, rápido, flexível
- **Contras**: Mais configuração manual
- **Decisão**: Rejeitado - Next.js oferece mais recursos prontos

#### 2. Vue.js + Nuxt
- **Prós**: Simples, boa performance
- **Contras**: Menos experiência do desenvolvedor
- **Decisão**: Rejeitado - falta de experiência

#### 3. Next.js (Escolhido)
- **Prós**: SSR/SSG, roteamento, otimizações, grande comunidade
- **Contras**: Complexidade desnecessária para SPA
- **Decisão**: Aceito - recursos prontos e comunidade

### Mobile

#### 1. React Native + Expo
- **Prós**: Compartilhamento de código com web, desenvolvimento rápido
- **Contras**: Limitações de performance, dependência do Expo
- **Decisão**: Rejeitado - Flutter oferece melhor performance

#### 2. Flutter (Escolhido)
- **Prós**: Performance nativa, UI consistente, desenvolvimento rápido
- **Contras**: Curva de aprendizado, não compartilha código com web
- **Decisão**: Aceito - melhor performance e UI

### Storage e Banco

#### 1. PostgreSQL + AWS S3
- **Prós**: Controle total, performance alta
- **Contras**: Mais configuração, custos
- **Decisão**: Rejeitado - Supabase oferece simplicidade

#### 2. MongoDB + GridFS
- **Prós**: Flexibilidade de schema, armazenamento de arquivos
- **Contras**: Menos experiência, complexidade de queries
- **Decisão**: Rejeitado - PostgreSQL é mais adequado para métricas

#### 3. Supabase (Escolhido)
- **Prós**: PostgreSQL + Storage integrado, API automática, gratuito
- **Contras**: Vendor lock-in, limitações de customização
- **Decisão**: Aceito - simplicidade e custo zero

### TTS (Text-to-Speech)

#### 1. Google Cloud TTS
- **Prós**: Qualidade alta, múltiplas vozes
- **Contras**: Dependência de internet, custos, privacidade
- **Decisão**: Rejeitado - viola requisito de privacidade

#### 2. Azure Speech
- **Prós**: Qualidade alta, recursos avançados
- **Contras**: Dependência de internet, custos, privacidade
- **Decisão**: Rejeitado - viola requisito de privacidade

#### 3. Piper TTS (Escolhido)
- **Prós**: Offline, open source, qualidade neural, testado
- **Contras**: Limitações de vozes, configuração manual
- **Decisão**: Aceito - atende requisitos de privacidade e qualidade

### Observabilidade

#### 1. Logs simples + Filebeat
- **Prós**: Simples, barato
- **Contras**: Limitado, difícil de escalar
- **Decisão**: Rejeitado - insuficiente para monitoramento

#### 2. ELK Stack
- **Prós**: Completo, flexível
- **Contras**: Complexo, recursos intensivos
- **Decisão**: Rejeitado - complexidade excessiva

#### 3. OpenTelemetry + Prometheus + Grafana (Escolhido)
- **Prós**: Padrão da indústria, integração com Kubernetes, gratuito
- **Contras**: Curva de aprendizado inicial
- **Decisão**: Aceito - adequado para observabilidade completa

## Stack Final

### Backend
- **Framework**: NestJS
- **Runtime**: Node.js
- **Language**: TypeScript
- **Database**: PostgreSQL (via Supabase)
- **Storage**: Supabase Storage
- **TTS**: Piper TTS
- **Extração**: Poppler (pdftotext) + OCRmyPDF + Tesseract
- **Áudio**: ffmpeg/lame

### Frontend
- **Web**: Next.js + React + TypeScript
- **Mobile**: Flutter + Dart
- **Styling**: Tailwind CSS (web)
- **State**: React Query (web)

### Infraestrutura
- **Containerização**: Docker + Kubernetes
- **Observabilidade**: OpenTelemetry + Prometheus + Grafana
- **CI/CD**: GitHub Actions (futuro)
- **Sistema**: Linux exclusivamente

## Consequências

### Positivas
- **Desenvolvimento rápido**: Stack conhecido pelo desenvolvedor
- **Qualidade**: Tecnologias maduras e bem suportadas
- **Produtividade**: Ferramentas que aceleram desenvolvimento
- **Observabilidade**: Monitoramento completo desde o início
- **Custo**: Stack gratuito para desenvolvimento inicial

### Negativas
- **Vendor lock-in**: Dependência do Supabase
- **Complexidade**: Múltiplas tecnologias para gerenciar
- **Curva de aprendizado**: Flutter e OpenTelemetry são novos
- **Recursos**: Stack pode ser pesado para MVP simples

## Implementação

### Fases de Implementação
1. **Setup**: NestJS + Supabase + Piper TTS
2. **Core**: API básica + processamento de áudio
3. **Frontend**: Next.js + interface básica
4. **Observabilidade**: OpenTelemetry + Prometheus + Grafana
5. **Mobile**: Flutter (futuro)

### Configuração
- **Ambiente**: Linux exclusivamente
- **Deploy**: Docker containers
- **Monitoramento**: Métricas automáticas via OpenTelemetry
- **Logs**: Estruturados com contexto de request

## Revisão
Esta decisão será revisada quando:
- Necessidade de mudança de banco de dados
- Requisitos de performance que exijam tecnologias diferentes
- Crescimento que justifique tecnologias mais robustas
- Feedback negativo sobre tecnologias escolhidas
