# 🎙️ Piper TTS Setup Guide

## 📋 Visão Geral

O Piper TTS é um sistema de síntese de voz neural offline que será usado para converter texto em áudio de alta qualidade.

## 🚀 Instalação Rápida

### Opção 1: Instalação Local (Recomendada)

```bash
# Baixar e instalar Piper TTS
wget https://github.com/rhasspy/piper/releases/download/2023.11.14-2/piper_linux_x86_64.tar.gz
tar -xzf piper_linux_x86_64.tar.gz
sudo cp piper/piper /usr/local/bin/
sudo chmod +x /usr/local/bin/piper

# Verificar instalação
piper --version
```

### Opção 2: Docker (Para Produção)

```bash
# Construir imagem Docker
docker build -f Dockerfile.piper-simple -t audivox-piper:latest .

# Testar
docker run --rm audivox-piper:latest piper --version
```

## 📥 Download dos Modelos

### Modelos Suportados

- **Português (PT-BR)**: `pt_BR-hfc_pt-medium`
- **Espanhol (ES-ES)**: `es_ES-carlfm-medium`  
- **Inglês (EN-US)**: `en_US-ryan-medium`

### Download Automático

```bash
# Executar script de download
./scripts/download-models.sh
```

### Download Manual

```bash
# Criar diretório
mkdir -p models

# Português
wget -O models/pt_BR-hfc_pt-medium.onnx https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/pt/pt_BR/hfc_pt/medium/pt_BR-hfc_pt-medium.onnx
wget -O models/pt_BR-hfc_pt-medium.onnx.json https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/pt/pt_BR/hfc_pt/medium/pt_BR-hfc_pt-medium.onnx.json

# Espanhol
wget -O models/es_ES-carlfm-medium.onnx https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/es/es_ES/carlfm/medium/es_ES-carlfm-medium.onnx
wget -O models/es_ES-carlfm-medium.onnx.json https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/es/es_ES/carlfm/medium/es_ES-carlfm-medium.onnx.json

# Inglês
wget -O models/en_US-ryan-medium.onnx https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/ryan/medium/en_US-ryan-medium.onnx
wget -O models/en_US-ryan-medium.onnx.json https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/ryan/medium/en_US-ryan-medium.onnx.json
```

## 🧪 Testando o Piper

### Teste Básico

```bash
# Português
echo "Olá mundo! Este é um teste do Piper TTS." | piper --model models/pt_BR-hfc_pt-medium.onnx --output_file test-pt.wav

# Espanhol  
echo "Hola mundo! Este es una prueba de Piper TTS." | piper --model models/es_ES-carlfm-medium.onnx --output_file test-es.wav

# Inglês
echo "Hello world! This is a test of Piper TTS." | piper --model models/en_US-ryan-medium.onnx --output_file test-en.wav
```

### Teste com Docker

```bash
# Português
echo "Olá mundo!" | docker run --rm -i -v "$(pwd)/models:/app/models" -v "$(pwd)/audio-output:/app/output" audivox-piper:latest piper --model /app/models/pt_BR-hfc_pt-medium.onnx --output_file /app/output/test.wav
```

## ⚙️ Configuração

### Variáveis de Ambiente

Adicione ao seu `.env`:

```bash
# Piper TTS Configuration
PIPER_BIN_PATH=/usr/local/bin/piper
PIPER_MODELS_PATH=./models
PIPER_PT_MODEL=pt_BR-hfc_pt-medium.onnx
PIPER_PT_CFG=pt_BR-hfc_pt-medium.onnx.json
PIPER_ES_MODEL=es_ES-carlfm-medium.onnx
PIPER_ES_CFG=es_ES-carlfm-medium.onnx.json
PIPER_EN_MODEL=en_US-ryan-medium.onnx
PIPER_EN_CFG=en_US-ryan-medium.onnx.json
```

### Scripts Disponíveis

```bash
# Build Docker image
npm run piper:build

# Test all languages
npm run piper:test

# Generate speech
npm run piper:speak "text" "language" "output_file"

# Install locally
npm run piper:install
```

## 🎯 Uso no Projeto

### Exemplo de Integração

```javascript
const { spawn } = require('child_process');
const fs = require('fs');

async function textToSpeech(text, language = 'pt', outputFile = 'output.wav') {
    const modelMap = {
        'pt': 'pt_BR-hfc_pt-medium.onnx',
        'es': 'es_ES-carlfm-medium.onnx', 
        'en': 'en_US-ryan-medium.onnx'
    };
    
    const model = modelMap[language];
    if (!model) {
        throw new Error(`Unsupported language: ${language}`);
    }
    
    return new Promise((resolve, reject) => {
        const piper = spawn('piper', [
            '--model', `models/${model}`,
            '--output_file', outputFile
        ]);
        
        piper.stdin.write(text);
        piper.stdin.end();
        
        piper.on('close', (code) => {
            if (code === 0) {
                resolve(outputFile);
            } else {
                reject(new Error(`Piper failed with code ${code}`));
            }
        });
    });
}

// Uso
textToSpeech("Olá mundo!", "pt", "hello.wav")
    .then(file => console.log(`Audio saved: ${file}`))
    .catch(err => console.error(err));
```

## 📊 Especificações Técnicas

### Requisitos

- **CPU**: x86_64 (AMD64)
- **RAM**: Mínimo 2GB (recomendado 4GB+)
- **Armazenamento**: ~500MB por modelo
- **SO**: Linux (Ubuntu 20.04+)

### Performance

- **Latência**: ~100-500ms por frase
- **Qualidade**: Neural TTS de alta qualidade
- **Formato**: WAV (16kHz, 16-bit)
- **Tamanho**: ~1MB por minuto de áudio

## 🔧 Troubleshooting

### Problemas Comuns

**1. "piper: command not found"**
```bash
# Verificar se está no PATH
which piper
# Se não estiver, reinstalar
sudo cp piper/piper /usr/local/bin/
```

**2. "Model file not found"**
```bash
# Verificar se os modelos estão no local correto
ls -la models/
# Baixar modelos novamente
./scripts/download-models.sh
```

**3. "Permission denied"**
```bash
# Dar permissão de execução
chmod +x /usr/local/bin/piper
```

**4. Docker não funciona**
```bash
# Verificar se Docker está rodando
docker --version
# Reconstruir imagem
docker build -f Dockerfile.piper-simple -t audivox-piper:latest .
```

## 🎯 Próximos Passos

Após configurar o Piper:

1. **BACK-001**: Criar projeto NestJS
2. **FRONT-001**: Criar projeto Next.js
3. **Integração**: Conectar Piper com o backend

---

**Tempo de setup**: ~10 minutos ⏱️
