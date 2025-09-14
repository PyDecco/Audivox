# Carta do Projeto - Audivox

## Visão do Projeto

**Audivox** é um MicroSaaS que converte documentos (PDF/EPUB/TXT) em áudio neural de alta qualidade usando tecnologia Piper TTS offline, oferecendo processamento página por página com streaming contínuo para uma experiência fluida de leitura em áudio.

## Missão

Democratizar o acesso à conversão de texto em áudio de alta qualidade, tornando a leitura acessível para todos através de uma solução simples, rápida e privada que funciona completamente offline.

## Objetivos do Projeto

### Objetivo Principal
Desenvolver um MVP funcional em tempo mínimo (dias) que demonstre a viabilidade técnica e comercial do Audivox.

### Objetivos Específicos
1. **Funcionalidade Core**: Conversão de documentos em áudio neural página por página
2. **Performance**: Streaming contínuo sem interrupções
3. **Simplicidade**: Interface intuitiva e fluxo de uso linear
4. **Privacidade**: Processamento 100% offline
5. **Escalabilidade**: Arquitetura preparada para crescimento

## Critérios de Sucesso

### Critérios Técnicos
- [ ] Upload e processamento de PDF/EPUB/TXT funcionando
- [ ] Conversão para áudio neural com qualidade aceitável
- [ ] Processamento página por página implementado
- [ ] Streaming contínuo sem interrupções
- [ ] Interface web funcional (Next.js)
- [ ] API REST documentada e testável
- [ ] Observabilidade básica implementada

### Critérios de Negócio
- [ ] MVP demonstrável para potenciais usuários
- [ ] Prova de conceito técnica validada
- [ ] Base para desenvolvimento futuro estabelecida
- [ ] Documentação técnica completa
- [ ] Arquitetura escalável definida

### Critérios de Qualidade
- [ ] Código limpo e bem documentado
- [ ] Testes básicos implementados
- [ ] Tratamento de erros robusto
- [ ] Logs estruturados para debug
- [ ] Performance aceitável (< 30s para documentos típicos)

## Escopo do Projeto

### Incluído no Escopo

#### Funcionalidades Core (MVP)
- **Seleção de idioma**: Português (pt-BR), Espanhol (es-ES), Inglês (en-US)
- **Upload de arquivo**: PDF, EPUB, TXT com validação
- **Configuração de leitura**: Ponto inicial (página/percentual/offset) e velocidade
- **Visualização do PDF**: Preview durante configuração
- **Processamento página por página**: Piper TTS com streaming contínuo
- **Download/Streaming**: Áudio gerado em formato WAV/MP3

#### Interface de Usuário
- **Web**: Next.js com interface responsiva
- **Mobile**: Flutter (futuro, não no MVP)
- **API**: Endpoints REST documentados

#### Infraestrutura
- **Backend**: NestJS com Supabase
- **Observabilidade**: OpenTelemetry + Prometheus + Grafana
- **Deploy**: Docker + Kubernetes
- **Sistema**: Linux exclusivamente

### Excluído do Escopo (MVP)

#### Funcionalidades Avançadas
- **Autenticação de usuários**: Não no MVP inicial
- **Biblioteca de leituras**: Funcionalidade futura
- **Bookmarks e anotações**: Não crítico para MVP
- **Integração com serviços externos**: Além do Supabase
- **Processamento em lote**: Foco em documentos individuais

#### Plataformas
- **Windows/Mac**: Apenas Linux no MVP
- **Mobile**: Flutter será desenvolvido após MVP web
- **Desktop**: Aplicação desktop não está no escopo

#### Recursos Avançados
- **OCR automático**: Implementação básica apenas
- **Múltiplas vozes por idioma**: Uma voz por idioma no MVP
- **Personalização avançada**: Configurações básicas apenas
- **Analytics avançados**: Métricas básicas de observabilidade

## Stakeholders

### Stakeholder Principal
- **Desenvolvedor**: Desenvolvedor único com experiência em NestJS
  - **Responsabilidades**: Desenvolvimento, arquitetura, deploy, manutenção
  - **Interesse**: MVP funcional em tempo mínimo
  - **Influência**: Alta (tomador de decisão principal)

### Stakeholders Secundários
- **Usuários finais**: Estudantes, profissionais, usuários de acessibilidade
  - **Responsabilidades**: Teste e feedback do MVP
  - **Interesse**: Funcionalidade simples e confiável
  - **Influência**: Média (feedback para melhorias)

- **Comunidade open source**: Desenvolvedores interessados em TTS
  - **Responsabilidades**: Contribuições futuras (pós-MVP)
  - **Interesse**: Código aberto e documentação
  - **Influência**: Baixa (futuro)

## Restrições do Projeto

### Restrições Técnicas
- **Orçamento**: Zero para infraestrutura inicial
- **Tempo**: Desenvolvimento em tempo mínimo (dias)
- **Recursos**: Desenvolvedor único
- **Sistema**: Linux exclusivamente
- **Dependências**: Piper TTS deve estar disponível e funcional

### Restrições de Negócio
- **Modelo**: MicroSaaS com foco em simplicidade
- **Mercado**: Foco inicial em usuários individuais
- **Escala**: Arquitetura deve suportar crescimento futuro
- **Concorrência**: Diferenciação por preço e privacidade

### Restrições de Qualidade
- **Performance**: Processamento deve ser aceitável (< 30s para documentos típicos)
- **Confiabilidade**: Sistema deve funcionar consistentemente
- **Usabilidade**: Interface deve ser intuitiva
- **Manutenibilidade**: Código deve ser limpo e documentado

## Riscos do Projeto

### Riscos Técnicos
- **Integração Piper**: Complexidade de integração com Piper TTS
  - **Mitigação**: Testes extensivos e fallbacks
  - **Probabilidade**: Média
  - **Impacto**: Alto

- **Performance**: Processamento lento de documentos grandes
  - **Mitigação**: Otimização página por página
  - **Probabilidade**: Média
  - **Impacto**: Médio

- **Dependências externas**: Falha de ferramentas externas (Poppler, OCR)
  - **Mitigação**: Fallbacks e tratamento de erros
  - **Probabilidade**: Baixa
  - **Impacto**: Médio

### Riscos de Negócio
- **Tempo de desenvolvimento**: MVP pode demorar mais que esperado
  - **Mitigação**: Foco em funcionalidades essenciais
  - **Probabilidade**: Média
  - **Impacto**: Alto

- **Adoção**: Baixa adoção do MVP
  - **Mitigação**: Feedback contínuo e iterações rápidas
  - **Probabilidade**: Baixa
  - **Impacto**: Médio

### Riscos de Recursos
- **Disponibilidade**: Desenvolvedor único pode ter limitações de tempo
  - **Mitigação**: Planejamento realista e priorização
  - **Probabilidade**: Baixa
  - **Impacto**: Alto

## Cronograma do Projeto

### Fase 1: Setup e Arquitetura (1-2 dias)
- [ ] Configuração do ambiente de desenvolvimento
- [ ] Estrutura do monorepo (NestJS + Next.js)
- [ ] Configuração básica do Supabase
- [ ] Setup de observabilidade (OpenTelemetry)

### Fase 2: Backend Core (2-3 dias)
- [ ] Implementação da API NestJS
- [ ] Integração com Piper TTS
- [ ] Upload e processamento de arquivos
- [ ] Processamento página por página

### Fase 3: Frontend (1-2 dias)
- [ ] Interface Next.js básica
- [ ] Integração com API
- [ ] Player de áudio
- [ ] Configurações de leitura

### Fase 4: Testes e Deploy (1 dia)
- [ ] Testes básicos
- [ ] Deploy com Docker
- [ ] Configuração de observabilidade
- [ ] Documentação final

**Total estimado**: 5-8 dias

## Métricas de Sucesso

### Métricas Técnicas
- **Tempo de processamento**: < 30 segundos para documentos de 50 páginas
- **Taxa de sucesso**: > 95% de conversões bem-sucedidas
- **Uptime**: > 99% de disponibilidade
- **Tempo de resposta**: < 2 segundos para endpoints da API

### Métricas de Negócio
- **Tempo para MVP**: < 8 dias
- **Feedback positivo**: > 80% de avaliações positivas
- **Demonstração**: MVP demonstrável para stakeholders
- **Base técnica**: Arquitetura sólida para crescimento

### Métricas de Qualidade
- **Cobertura de testes**: > 70% (básico)
- **Documentação**: 100% das funcionalidades documentadas
- **Código limpo**: Sem code smells críticos
- **Performance**: Sem gargalos identificados

## Definição de Pronto

### MVP Pronto Quando:
- [ ] Todas as funcionalidades core implementadas
- [ ] Interface web funcional e testada
- [ ] API documentada e testável
- [ ] Processamento página por página funcionando
- [ ] Observabilidade básica implementada
- [ ] Deploy funcionando em ambiente de produção
- [ ] Documentação técnica completa
- [ ] Testes básicos passando
- [ ] Performance aceitável validada

### Critérios de Aceitação:
- [ ] Usuário pode fazer upload de PDF/EPUB/TXT
- [ ] Usuário pode configurar idioma, ponto inicial e velocidade
- [ ] Sistema processa documento página por página
- [ ] Áudio é gerado com qualidade aceitável
- [ ] Usuário pode baixar ou reproduzir áudio
- [ ] Sistema funciona consistentemente
- [ ] Interface é intuitiva e responsiva
- [ ] Performance é aceitável para documentos típicos
