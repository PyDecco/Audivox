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

async function testSupabaseConnection() {
    log('cyan', '🧪 Testing Supabase Connection');
    log('cyan', '=============================');

    const supabaseUrl = process.env.SUPABASE_URL;
    const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
    const bucketName = process.env.SUPABASE_STORAGE_BUCKET || 'audivox-files';

    // Check environment variables
    log('blue', '\n📋 Checking Environment Variables...');
    
    if (!supabaseUrl || supabaseUrl.includes('your-project')) {
        log('red', '❌ SUPABASE_URL not configured');
        return false;
    }
    log('green', '✅ SUPABASE_URL configured');

    if (!supabaseAnonKey || supabaseAnonKey.includes('your-anon-key')) {
        log('red', '❌ SUPABASE_ANON_KEY not configured');
        return false;
    }
    log('green', '✅ SUPABASE_ANON_KEY configured');

    if (!supabaseServiceKey || supabaseServiceKey.includes('your-service-role-key')) {
        log('red', '❌ SUPABASE_SERVICE_ROLE_KEY not configured');
        return false;
    }
    log('green', '✅ SUPABASE_SERVICE_ROLE_KEY configured');

    // Test database connection
    log('blue', '\n🗄️  Testing Database Connection...');
    
    try {
        const supabase = createClient(supabaseUrl, supabaseAnonKey);
        
        // Test basic query
        const { data, error } = await supabase.from('files').select('count').limit(1);
        
        if (error) {
            log('red', `❌ Database connection failed: ${error.message}`);
            return false;
        }
        
        log('green', '✅ Database connection successful');
        
        // Test table existence
        const { data: tables, error: tableError } = await supabase.rpc('get_table_names');
        
        if (!tableError && tables) {
            log('green', `✅ Tables found: ${tables.length}`);
        } else {
            // Fallback: try to query each table
            const tableTests = ['files', 'readings', 'audio_chunks'];
            let existingTables = 0;
            
            for (const table of tableTests) {
                try {
                    const { error } = await supabase.from(table).select('*').limit(1);
                    if (!error) {
                        existingTables++;
                    }
                } catch (e) {
                    // Table doesn't exist
                }
            }
            
            log('green', `✅ Tables found: ${existingTables}/3`);
        }
        
    } catch (err) {
        log('red', `❌ Database test failed: ${err.message}`);
        return false;
    }

    // Test storage connection
    log('blue', '\n📦 Testing Storage Connection...');
    
    try {
        const supabase = createClient(supabaseUrl, supabaseServiceKey);
        
        // List buckets
        const { data: buckets, error: bucketError } = await supabase.storage.listBuckets();
        
        if (bucketError) {
            log('red', `❌ Storage access failed: ${bucketError.message}`);
            return false;
        }
        
        log('green', '✅ Storage connection successful');
        
        // Check for audivox-files bucket
        const audivoxBucket = buckets.find(bucket => bucket.name === bucketName);
        
        if (audivoxBucket) {
            log('green', `✅ Storage bucket "${bucketName}" found`);
            
            // Test bucket access
            const { data: files, error: filesError } = await supabase.storage
                .from(bucketName)
                .list('', { limit: 1 });
            
            if (filesError) {
                log('yellow', `⚠️  Bucket access test failed: ${filesError.message}`);
            } else {
                log('green', `✅ Bucket access successful (${files.length} files found)`);
            }
            
        } else {
            log('yellow', `⚠️  Storage bucket "${bucketName}" not found`);
            log('blue', 'Available buckets:');
            buckets.forEach(bucket => {
                log('blue', `  • ${bucket.name}`);
            });
        }
        
    } catch (err) {
        log('red', `❌ Storage test failed: ${err.message}`);
        return false;
    }

    // Test authentication
    log('blue', '\n🔐 Testing Authentication...');
    
    try {
        const supabase = createClient(supabaseUrl, supabaseAnonKey);
        
        // Test auth state
        const { data: { session }, error: authError } = await supabase.auth.getSession();
        
        if (authError) {
            log('yellow', `⚠️  Auth test warning: ${authError.message}`);
        } else {
            log('green', '✅ Authentication system accessible');
        }
        
    } catch (err) {
        log('yellow', `⚠️  Auth test warning: ${err.message}`);
    }

    // Summary
    log('cyan', '\n📊 Test Summary');
    log('cyan', '===============');
    log('green', '✅ Supabase configuration complete');
    log('blue', `📡 API URL: ${supabaseUrl}`);
    log('blue', `📦 Storage Bucket: ${bucketName}`);
    log('blue', `🔑 Anon Key: ${supabaseAnonKey.substring(0, 20)}...`);
    log('blue', `🔑 Service Key: ${supabaseServiceKey.substring(0, 20)}...`);
    
    log('green', '\n🎉 Supabase is ready for development!');
    
    return true;
}

// Run the test
testSupabaseConnection().catch(err => {
    log('red', `❌ Test failed: ${err.message}`);
    process.exit(1);
});
