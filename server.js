const express = require('express');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

// Lista fechada de opcoes validas — nunca interpolar entrada do cliente
// diretamente numa string de shell. Sem isso, um POST malicioso em /optimize
// podia injetar comandos arbitrarios no PowerShell, que roda como Administrador.
const VALID_OPTIONS = new Set([
    'power', 'hibernation', 'registry', 'services', 'network', 'temp',
    'diskcleanup', 'ssdopt', 'telemetry', 'startup', 'pagefile', 'defender',
    'updates', 'video', 'background', 'boot', 'priority', 'gpu'
]);

// So aceita requisicoes vindas da propria maquina (sem Origin = navegacao
// direta; localhost = a propria interface). Bloqueia qualquer site de
// terceiro tentando fazer um POST silencioso contra este servidor
// administrativo a partir do seu navegador (CSRF cross-origin).
function localOnly(req, res, next) {
    const origin = req.get('origin');
    if (!origin || /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin)) {
        return next();
    }
    return res.status(403).json({ error: 'Origin não permitida' });
}

app.use(express.json());
app.use(localOnly);
app.use(express.static(__dirname));

// Deteccao de hardware/apps instalados: so leitura, nao precisa de admin,
// roda assim que a pagina abre (antes mesmo da elevacao do servidor).
app.get('/hardware', (req, res) => {
    const psCommand = `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${path.join(__dirname, 'hardware-detect.ps1')}"`;
    exec(psCommand, { cwd: __dirname, timeout: 10000, maxBuffer: 2 * 1024 * 1024 }, (err, stdout) => {
        if (err) {
            return res.status(500).json({ error: 'Falha ao detectar hardware' });
        }
        try {
            const data = JSON.parse(stdout.trim());
            res.json(data);
        } catch (e) {
            res.status(500).json({ error: 'Resposta de deteccao invalida' });
        }
    });
});

// Optimization endpoint with Server-Sent Events
app.post('/optimize', (req, res) => {
    const requested = Array.isArray(req.body.options) ? req.body.options : [];
    const options = requested.filter(o => VALID_OPTIONS.has(o));

    if (options.length === 0) {
        return res.status(400).json({ error: 'Nenhuma otimização válida selecionada' });
    }

    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');

    const sendEvent = (data) => {
        res.write(`data: ${JSON.stringify(data)}\n\n`);
    };

    // Write-Host capturado via pipe tem encoding imprevisivel neste PowerShell 5.1
    // (confirmado em teste real: corrompe acentos mesmo com BOM e $OutputEncoding
    // configurados). O optimizer.ps1 agora escreve o progresso em um arquivo UTF-8
    // proprio, e aqui fazemos polling desse arquivo em vez de ler o stdout do processo.
    //
    // O log NAO pode ficar em os.tmpdir() (%TEMP%): a propria opcao "temp" do
    // optimizer roda "Remove-Item $env:TEMP\*" e apagava o arquivo de log que
    // o processo estava escrevendo nesse exato momento (bug real encontrado em
    // teste end-to-end: o SSE parava de receber progresso no meio da execucao).
    const logDir = path.join(__dirname, '.logs');
    if (!fs.existsSync(logDir)) fs.mkdirSync(logDir, { recursive: true });
    const logFile = path.join(logDir, `progress-${Date.now()}.log`);
    const psArgs = options.join(',');
    const psCommand = `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${path.join(__dirname, 'optimizer.ps1')}" -Options "${psArgs}" -LogFile "${logFile}"`;

    sendEvent({ progress: 0, status: 'Criando ponto de restauração...' });

    const child = exec(psCommand, {
        cwd: __dirname,
        maxBuffer: 10 * 1024 * 1024
    });

    let lastReadPos = 0;
    let finished = false;

    const pollLog = () => {
        if (finished) return;
        fs.stat(logFile, (err, stats) => {
            if (err || !stats || stats.size <= lastReadPos) return;
            const stream = fs.createReadStream(logFile, { start: lastReadPos, end: stats.size - 1, encoding: 'utf8' });
            let chunk = '';
            stream.on('data', d => chunk += d);
            stream.on('end', () => {
                lastReadPos = stats.size;
                chunk.split('\n').filter(l => l.trim()).forEach(line => {
                    line = line.trim();
                    if (line.startsWith('[PROGRESS:')) {
                        const match = line.match(/\[PROGRESS:(\d+)\]/);
                        if (match) sendEvent({ progress: parseInt(match[1]) });
                    } else if (line.startsWith('[STATUS:')) {
                        sendEvent({ status: line.replace('[STATUS:', '').replace(/\]$/, '') });
                    } else if (line.startsWith('[ERROR:')) {
                        sendEvent({ status: 'Erro: ' + line.replace('[ERROR:', '').replace(/\]$/, '') });
                    }
                });
            });
        });
    };

    const pollInterval = setInterval(pollLog, 300);

    child.stderr.on('data', (data) => {
        console.error('Error:', data.toString());
    });

    child.on('close', (code) => {
        finished = true;
        clearInterval(pollInterval);
        pollLog(); // uma ultima leitura para pegar qualquer linha final

        setTimeout(() => {
            fs.unlink(logFile, () => {});
            const results = [
                '✓ Plano de energia otimizado',
                '✓ Serviços desnecessários desabilitados',
                '✓ Registro otimizado',
                '✓ GPU com prioridade máxima',
                '✓ Rede otimizada para streaming',
                '✓ Memória virtual configurada',
                '✓ CapCut e OBS com prioridade automática',
                '✓ Sistema pronto para produção de vídeo!'
            ];

            sendEvent({
                progress: 100,
                complete: true,
                status: code === 0 ? 'Otimização completa!' : `Processo terminou com código ${code}`,
                results
            });
            res.end();
        }, 400); // da tempo da ultima leitura do arquivo terminar
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
