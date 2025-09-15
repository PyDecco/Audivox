#!/usr/bin/env node

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

// Colors for console output
const colors = {
    reset: '\x1b[0m',
    bright: '\x1b[1m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    magenta: '\x1b[35m',
    cyan: '\x1b[36m'
};

function log(color, message) {
    console.log(`${colors[color]}${message}${colors.reset}`);
}

async function createTables() {
    log('cyan', '🗄️  Creating Tables in Supabase');
    log('cyan', '==============================');

    const supabase = createClient(
        process.env.SUPABASE_URL,
        process.env.SUPABASE_SERVICE_ROLE_KEY
    );

    // SQL para criar as tabelas
    const createTablesSQL = `
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
`;

    try {
        log('blue', 'Creating tables...');
        
        // Execute SQL using Supabase RPC
        const { data, error } = await supabase.rpc('exec_sql', { 
            sql: createTablesSQL 
        });

        if (error) {
            log('red', `❌ Error creating tables: ${error.message}`);
            return false;
        }

        log('green', '✅ Tables created successfully!');

        // Verify tables were created
        log('blue', 'Verifying tables...');
        
        const { data: tables, error: tablesError } = await supabase
            .from('information_schema.tables')
            .select('table_name')
            .eq('table_schema', 'public')
            .in('table_name', ['files', 'readings', 'audio_chunks']);

        if (tablesError) {
            log('yellow', `⚠️  Could not verify tables: ${tablesError.message}`);
        } else {
            log('green', `✅ Found ${tables.length} tables:`);
            tables.forEach(table => {
                log('green', `  • ${table.table_name}`);
            });
        }

        // Insert sample data
        log('blue', 'Inserting sample data...');
        
        const { data: sampleFile, error: fileError } = await supabase
            .from('files')
            .insert({
                original_name: 'sample.pdf',
                mime_type: 'application/pdf',
                size: 1024000,
                path: '/uploads/sample.pdf',
                status: 'PROCESSED',
                metadata: {
                    pages: 10,
                    wordCount: 2500,
                    charCount: 15000,
                    language: 'pt_BR',
                    title: 'Documento de Exemplo',
                    author: 'Sistema'
                }
            })
            .select()
            .single();

        if (fileError) {
            log('yellow', `⚠️  Could not insert sample file: ${fileError.message}`);
        } else {
            log('green', '✅ Sample file inserted');

            // Insert sample reading
            const { data: sampleReading, error: readingError } = await supabase
                .from('readings')
                .insert({
                    file_id: sampleFile.id,
                    locale: 'PT_BR',
                    start_type: 'PAGE',
                    start_value: 1,
                    speed: 1.0,
                    format: 'WAV',
                    status: 'DONE',
                    progress: 1.0,
                    current_page: 10,
                    total_pages: 10,
                    audio_path: '/audio/sample.wav',
                    audio_size: 2048000,
                    duration: 120
                })
                .select()
                .single();

            if (readingError) {
                log('yellow', `⚠️  Could not insert sample reading: ${readingError.message}`);
            } else {
                log('green', '✅ Sample reading inserted');
            }
        }

        log('cyan', '\n🎉 Database setup complete!');
        log('blue', 'You can now run: npm run test:supabase');
        
        return true;

    } catch (err) {
        log('red', `❌ Unexpected error: ${err.message}`);
        return false;
    }
}

// Run the script
createTables().catch(err => {
    log('red', `❌ Script failed: ${err.message}`);
    process.exit(1);
});
