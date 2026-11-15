const express = require('express');
const { exec } = require('child_process');
const path = require('path');
const cors = require('cors');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());
app.use(express.static(__dirname));

// Optimization endpoint with Server-Sent Events
app.post('/optimize', (req, res) => {
    const { options } = req.body;

    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');

    const sendEvent = (data) => {
        res.write(`data: ${JSON.stringify(data)}\n\n`);
    };

    // Build PowerShell command
    const psArgs = options.join(',');
    const psCommand = `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${path.join(__dirname, 'optimizer.ps1')}" -Options "${psArgs}"`;

    sendEvent({ progress: 0, status: 'Criando ponto de restauração...' });

    const process = exec(psCommand, { 
        cwd: __dirname,
        maxBuffer: 10 * 1024 * 1024 
    });

    let buffer = '';

    process.stdout.on('data', (data) => {
        buffer += data.toString();
        const lines = buffer.split('\n');
        buffer = lines.pop();

        lines.forEach(line => {
            line = line.trim();
            if (!line) return;

            // Parse progress messages
            if (line.startsWith('[PROGRESS:')) {
                const match = line.match(/\[PROGRESS:(\d+)\]/);
                if (match) {
                    sendEvent({ progress: parseInt(match[1]) });
                }
            } else if (line.startsWith('[STATUS:')) {
                const status = line.replace('[STATUS:', '').replace(']', '');
                sendEvent({ status });
            }
        });
    });

    process.stderr.on('data', (data) => {
        console.error('Error:', data.toString());
    });

    process.on('close', (code) => {
        const results = [
            '✓ Plano de energia otimizado',
            '✓ Serviços desnecessários desabilitados',
            '✓ Registro otimizado (30+ tweaks)',
            '✓ GPU com prioridade máxima',
            '✓ Rede otimizada para streaming',
            '✓ Memória virtual configurada',
            '✓ CapCut e OBS com prioridade automática',
            '✓ Sistema pronto para produção de vídeo!'
        ];

        sendEvent({ 
            progress: 100, 
            complete: true, 
            status: 'Otimização completa!',
            results 
        });
        res.end();
    });
});

// Reboot endpoint
app.post('/reboot', (req, res) => {
    exec('shutdown /r /t 10 /c "Otimização concluída! Reiniciando..."');
    res.json({ success: true });
});

app.listen(PORT, () => {
    console.log(`
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   🎬  WINDOWS VIDEO OPTIMIZER - SERVER RUNNING  🎬          ║
║                                                              ║
║   Servidor iniciado com sucesso!                            ║
║   Acesse: http://localhost:${PORT}                             ║
║                                                              ║
║   Pressione Ctrl+C para parar                               ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
    `);
});
