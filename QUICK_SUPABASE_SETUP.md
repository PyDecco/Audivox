# 🚀 Setup Rápido do Supabase

## ⚡ Solução em 2 minutos

### 1. Acesse o Supabase Dashboard
- Vá para: https://supabase.com/dashboard
- Selecione seu projeto `audivox`
- Clique em **"SQL Editor"** no menu lateral

### 2. Execute este SQL
Copie e cole este código no SQL Editor:

```sql
-- Create files table
CREATE TABLE IF NOT EXISTS files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    original_name VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    size BIGINT NOT NULL,
    path VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'UPLOADED',
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create readings table
CREATE TABLE IF NOT EXISTS readings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    file_id UUID NOT NULL REFERENCES files(id) ON DELETE CASCADE,
    locale VARCHAR(10) NOT NULL,
    start_type VARCHAR(20) NOT NULL,
    start_value INTEGER NOT NULL,
    speed DECIMAL(3,1) NOT NULL,
    format VARCHAR(10) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'QUEUED',
    progress DECIMAL(3,2) DEFAULT 0.0,
    current_page INTEGER DEFAULT 0,
    total_pages INTEGER DEFAULT 0,
    audio_path VARCHAR(255),
    audio_size BIGINT,
    duration INTEGER,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create audio_chunks table
CREATE TABLE IF NOT EXISTS audio_chunks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reading_id UUID NOT NULL REFERENCES readings(id) ON DELETE CASCADE,
    page_number INTEGER NOT NULL,
    audio_data BYTEA,
    duration INTEGER,
    size BIGINT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_files_status ON files(status);
CREATE INDEX IF NOT EXISTS idx_readings_file_id ON readings(file_id);
CREATE INDEX IF NOT EXISTS idx_readings_status ON readings(status);
CREATE INDEX IF NOT EXISTS idx_audio_chunks_reading_id ON audio_chunks(reading_id);
```

### 3. Clique em "Run" ✅

### 4. Teste a configuração
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

## 🎯 Próximo Passo

Após criar as tabelas:
- **INFRA-003**: Setup do Piper TTS

---

**Tempo total: 2 minutos** ⏱️
