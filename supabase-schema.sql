-- Audivox Database Schema for Supabase
-- Execute this SQL in the Supabase Dashboard > SQL Editor

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

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_files_status ON files(status);
CREATE INDEX IF NOT EXISTS idx_readings_file_id ON readings(file_id);
CREATE INDEX IF NOT EXISTS idx_readings_status ON readings(status);
CREATE INDEX IF NOT EXISTS idx_audio_chunks_reading_id ON audio_chunks(reading_id);

-- Enable Row Level Security (RLS)
ALTER TABLE files ENABLE ROW LEVEL SECURITY;
ALTER TABLE readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE audio_chunks ENABLE ROW LEVEL SECURITY;

-- Create policies for authenticated users
CREATE POLICY "Users can access own files" ON files
    FOR ALL USING (auth.uid()::text = id::text);

CREATE POLICY "Users can access own readings" ON readings
    FOR ALL USING (auth.uid()::text = id::text);

CREATE POLICY "Users can access own audio chunks" ON audio_chunks
    FOR ALL USING (auth.uid()::text = id::text);

-- Insert sample data
INSERT INTO files (original_name, mime_type, size, path, status, metadata) VALUES
('sample.pdf', 'application/pdf', 1024000, '/uploads/sample.pdf', 'PROCESSED', '{"pages": 10, "wordCount": 2500, "charCount": 15000, "language": "pt_BR", "title": "Documento de Exemplo", "author": "Sistema"}');

INSERT INTO readings (file_id, locale, start_type, start_value, speed, format, status, progress, current_page, total_pages, audio_path, audio_size, duration) VALUES
((SELECT id FROM files LIMIT 1), 'PT_BR', 'PAGE', 1, 1.0, 'WAV', 'DONE', 1.0, 10, 10, '/audio/sample.wav', 2048000, 120);

-- Insert sample audio chunks
INSERT INTO audio_chunks (reading_id, page_number, duration, size) VALUES
((SELECT id FROM readings LIMIT 1), 1, 12, 204800),
((SELECT id FROM readings LIMIT 1), 2, 12, 204800),
((SELECT id FROM readings LIMIT 1), 3, 12, 204800),
((SELECT id FROM readings LIMIT 1), 4, 12, 204800),
((SELECT id FROM readings LIMIT 1), 5, 12, 204800),
((SELECT id FROM readings LIMIT 1), 6, 12, 204800),
((SELECT id FROM readings LIMIT 1), 7, 12, 204800),
((SELECT id FROM readings LIMIT 1), 8, 12, 204800),
((SELECT id FROM readings LIMIT 1), 9, 12, 204800),
((SELECT id FROM readings LIMIT 1), 10, 12, 204800);
