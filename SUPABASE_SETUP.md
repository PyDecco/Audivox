# 🗄️ Supabase Setup Guide

## 📋 Pré-requisitos

1. **Projeto Supabase criado** em [supabase.com](https://supabase.com)
2. **Variáveis de ambiente configuradas** no `.env`
3. **Storage bucket criado** no Supabase Dashboard

## 🔧 Configuração

### 1. Criar Projeto no Supabase

1. Acesse [supabase.com](https://supabase.com)
2. Clique em "New Project"
3. Escolha sua organização
4. Configure:
   - **Name**: `audivox`
   - **Database Password**: (anote esta senha!)
   - **Region**: escolha a mais próxima

### 2. Configurar Storage Bucket

1. No Dashboard do Supabase, vá para **Storage**
2. Clique em **"New bucket"**
3. Configure:
   - **Name**: `audivox-files`
   - **Public**: ✅ (para acesso direto aos arquivos)
   - **File size limit**: `100MB`
   - **Allowed MIME types**: `application/pdf,text/plain,application/epub+zip`

### 3. Obter Chaves de API

1. No Dashboard, vá para **Settings** → **API**
2. Copie as seguintes informações:
   - **Project URL** (ex: `https://abc123.supabase.co`)
   - **anon public** key
   - **service_role** key

### 4. Configurar Variáveis de Ambiente

Edite o arquivo `.env`:

```bash
# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
SUPABASE_STORAGE_BUCKET=audivox-files

# Supabase Database (para produção)
SUPABASE_DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.your-project.supabase.co:5432/postgres
```

## 🚀 Setup Automatizado

### Opção 1: Script Automatizado

```bash
# Executar setup do Supabase
npm run setup:supabase
```

### Opção 2: Manual

```bash
# 1. Instalar dependências
npm install

# 2. Testar conexão
npm run test:supabase

# 3. Executar migrações
npm run db:migrate

# 4. Popular banco com dados de exemplo
npm run db:seed
```

## 🧪 Testando a Configuração

### Teste Completo

```bash
npm run test:supabase
```

**Resultado esperado:**
```
🧪 Testing Supabase Connection
=============================

📋 Checking Environment Variables...
✅ SUPABASE_URL configured
✅ SUPABASE_ANON_KEY configured
✅ SUPABASE_SERVICE_ROLE_KEY configured

🗄️  Testing Database Connection...
✅ Database connection successful
✅ Tables found: 3/3

📦 Testing Storage Connection...
✅ Storage connection successful
✅ Storage bucket "audivox-files" found
✅ Bucket access successful

🔐 Testing Authentication...
✅ Authentication system accessible

📊 Test Summary
===============
✅ Supabase configuration complete
📡 API URL: https://your-project.supabase.co
📦 Storage Bucket: audivox-files
🔑 Anon Key: eyJhbGciOiJIUzI1NiIs...
🔑 Service Key: eyJhbGciOiJIUzI1NiIs...

🎉 Supabase is ready for development!
```

### Testes Individuais

```bash
# Testar apenas banco de dados
npx prisma db push

# Testar apenas storage
node -e "
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);
supabase.storage.listBuckets().then(console.log);
"
```

## 📊 Estrutura do Banco

O Prisma criará automaticamente as seguintes tabelas:

- **files**: Arquivos enviados pelos usuários
- **readings**: Sessões de leitura
- **audio_chunks**: Chunks de áudio por página

## 🔐 Políticas de Segurança (RLS)

### Storage Policies

Configure as seguintes políticas no Supabase Dashboard:

```sql
-- Permitir upload de arquivos para usuários autenticados
CREATE POLICY "Users can upload files" ON storage.objects
FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Permitir download de arquivos próprios
CREATE POLICY "Users can download own files" ON storage.objects
FOR SELECT USING (auth.uid()::text = (storage.foldername(name))[1]);

-- Permitir exclusão de arquivos próprios
CREATE POLICY "Users can delete own files" ON storage.objects
FOR DELETE USING (auth.uid()::text = (storage.foldername(name))[1]);
```

### Database Policies

```sql
-- Permitir acesso aos próprios arquivos
CREATE POLICY "Users can access own files" ON files
FOR ALL USING (auth.uid()::text = user_id);

-- Permitir acesso às próprias leituras
CREATE POLICY "Users can access own readings" ON readings
FOR ALL USING (auth.uid()::text = user_id);
```

## 🚨 Troubleshooting

### Erro: "Invalid API key"

- Verifique se as chaves estão corretas no `.env`
- Certifique-se de que não há espaços extras
- Teste com `npm run test:supabase`

### Erro: "Bucket not found"

- Crie o bucket `audivox-files` no Dashboard
- Verifique se o nome está correto no `.env`

### Erro: "Database connection failed"

- Verifique a `SUPABASE_DATABASE_URL`
- Certifique-se de que o projeto está ativo
- Teste a conexão no Dashboard

### Erro: "Permission denied"

- Verifique as políticas RLS
- Certifique-se de que o usuário tem permissões adequadas

## 📚 Próximos Passos

Após configurar o Supabase:

1. **INFRA-003**: Setup do Piper TTS
2. **BACK-001**: Criar projeto NestJS
3. **FRONT-001**: Criar projeto Next.js

## 🔗 Links Úteis

- [Supabase Dashboard](https://supabase.com/dashboard)
- [Supabase Docs](https://supabase.com/docs)
- [Storage API](https://supabase.com/docs/guides/storage)
- [Database API](https://supabase.com/docs/guides/database)
