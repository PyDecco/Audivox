# ADR-001: Arquitetura Cliente-Servidor

## Status
Aceito

## Contexto
O Audivox precisa de uma arquitetura que permita desenvolvimento rápido (MVP em dias) com um desenvolvedor único, mantendo simplicidade e facilitando manutenção futura.

## Decisão
Adotar arquitetura cliente-servidor tradicional com NestJS como API única, comunicando-se diretamente com clientes Next.js (web) e Flutter (mobile futuro).

## Alternativas Consideradas

### 1. Microserviços
- **Prós**: Escalabilidade, isolamento de responsabilidades
- **Contras**: Complexidade desnecessária para MVP, overhead de comunicação, mais infraestrutura
- **Decisão**: Rejeitado - complexidade excessiva para desenvolvimento rápido

### 2. Serverless (AWS Lambda, Vercel Functions)
- **Prós**: Escalabilidade automática, sem gerenciamento de servidor
- **Contras**: Limitações de tempo de execução, cold starts, complexidade com Piper TTS
- **Decisão**: Rejeitado - Piper TTS requer processamento longo e estado persistente

### 3. Monolito com Next.js API Routes
- **Prós**: Simplicidade, deploy único
- **Contras**: Limitações de Next.js para processamento pesado, dificuldade com Piper TTS
- **Decisão**: Rejeitado - Next.js não é ideal para processamento de áudio pesado

### 4. Arquitetura Cliente-Servidor (Escolhida)
- **Prós**: Simplicidade, desenvolvimento rápido, controle total sobre processamento
- **Contras**: Ponto único de falha, escalabilidade manual
- **Decisão**: Aceito - adequado para MVP e desenvolvimento rápido

## Consequências

### Positivas
- **Simplicidade**: Arquitetura direta e fácil de entender
- **Desenvolvimento rápido**: Foco em uma API única
- **Controle total**: Processamento de áudio sob controle direto
- **Debugging**: Mais fácil de debugar e monitorar
- **Deploy**: Deploy único simplificado

### Negativas
- **Escalabilidade**: Ponto único de falha, escalabilidade manual
- **Manutenção**: Toda lógica concentrada em um serviço
- **Flexibilidade**: Menos flexibilidade para mudanças futuras

## Implementação

### Estrutura
```
Cliente (Next.js/Flutter) ←→ API REST ←→ NestJS ←→ Supabase
                                    ↓
                              Piper TTS + Ferramentas
```

### Comunicação
- **Protocolo**: HTTP/REST
- **Formato**: JSON
- **Autenticação**: Futuro (não no MVP)
- **Rate Limiting**: Implementado no NestJS

### Responsabilidades
- **NestJS**: Processamento de áudio, lógica de negócio, API
- **Next.js**: Interface web, upload de arquivos, player
- **Flutter**: Interface mobile (futuro)
- **Supabase**: Storage de arquivos, banco de dados

## Monitoramento
- **Métricas**: OpenTelemetry + Prometheus + Grafana
- **Logs**: Estruturados com requestId/readingId
- **Health Checks**: Endpoints de saúde da API
- **Performance**: Tempo de processamento, taxa de sucesso

## Revisão
Esta decisão será revisada quando:
- Projeto atingir escala que justifique microserviços
- Necessidade de alta disponibilidade crítica
- Crescimento da equipe de desenvolvimento
- Requisitos de performance que exijam arquitetura distribuída
