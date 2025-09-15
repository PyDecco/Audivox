# 🗄️ Setup Manual do Supabase

## 📋 Problema Identificado

O Prisma não consegue conectar diretamente ao Supabase devido a configurações de rede. Vamos criar as tabelas manualmente no Dashboard.

## 🚀 Passos para Criar as Tabelas

### 1. Acesse o Supabase Dashboard

1. Vá para [supabase.com/dashboard](https://supabase.com/dashboard)
2. Selecione seu projeto `audivox`
3. Vá para **SQL Editor** no menu lateral

### 2. Execute o SQL

1. Clique em **"New query"**
2. Copie e cole o conteúdo do arquivo `supabase-schema.sql`
3. Clique em **"Run"** para executar

### 3. Verificar as Tabelas

Após executar o SQL, vá para **Table Editor** e verifique se as tabelas foram criadas:

- ✅ `files`
- ✅ `readings` 
- ✅ `audio_chunks`

## 🧪 Testar a Configuração

Após criar as tabelas, execute:

```bash
npm run test:supabase
```

**Resultado esperado:**
```
✅ Database connection successful
✅ Tables found: 3/3
✅ Storage bucket "audivox-files" found
🎉 Supabase is ready for development!
```

## 🔧 Configuração Final

Após criar as tabelas, você pode usar o Prisma normalmente:

```bash
# Gerar cliente Prisma
npm run db:generate

# Executar seed (opcional)
npm run db:seed
```

## 📊 Estrutura Criada

O SQL criará:

- **3 tabelas** com relacionamentos
- **Índices** para performance
- **RLS policies** para segurança
- **Dados de exemplo** para teste

## 🎯 Próximo Passo

Após criar as tabelas:

1. **Teste**: `npm run test:supabase`
2. **Continue**: INFRA-003 (Setup do Piper TTS)

---

**Nota**: Este é um workaround temporário. Em produção, use migrações do Prisma.
