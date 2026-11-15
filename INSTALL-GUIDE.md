# 🚀 Guia de Instalação FrameForge

## Método Recomendado (One-Liner)

### Passo 1: Abrir PowerShell como Administrador

**Opção A - Menu Iniciar:**
1. Pressione a tecla **Windows** (⊞)
2. Digite: `PowerShell`
3. Clique com o **BOTÃO DIREITO** em "Windows PowerShell"
4. Escolha **"Executar como Administrador"**
5. Clique **"Sim"** no aviso de segurança

**Opção B - Atalho de Teclado:**
1. Pressione **Windows + X**
2. Escolha **"Windows PowerShell (Admin)"** ou **"Terminal (Admin)"**
3. Clique **"Sim"** no aviso de segurança

**Opção C - Executar (Win + R):**
1. Pressione **Windows + R**
2. Cole: `powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell -Verb RunAs"`
3. Aperte **Enter**

### Passo 2: Executar o Instalador

Cole este comando no PowerShell que abriu:

```powershell
irm "https://raw.githubusercontent.com/Paulothedeveloper/WindowsVideoOptimizer/main/quick-install.ps1?cb=$(Get-Random)" | iex
```

Aperte **Enter** e aguarde!

---

## O Que o Instalador Faz

### ✅ Verificações Automáticas
1. **Detecta se está como Admin** → Se não estiver, mostra instruções e oferece abrir automaticamente
2. **Detecta PowerShell profile** → Se você tem profile personalizado, re-executa sem ele para evitar conflitos
3. **Verifica Git** → Se não tiver, baixa e instala automaticamente
4. **Verifica Node.js** → Se não tiver, baixa e instala automaticamente

### ✅ Instalação
5. **Clona o repositório** → Em `%LOCALAPPDATA%\FrameForge`
6. **Instala dependências npm** → Express + CORS
7. **Cria atalho no Desktop** → "FrameForge.lnk"
8. **Cria ponto de restauração** → "FrameForge - Antes da instalação"

### ✅ Pergunta Final
9. **"Deseja executar agora?"** → S/N

---

## Proteções de Segurança

### 🛡️ Contra Problemas Comuns

**Problema:** PowerShell profile personalizado causa erros
- **Solução:** O instalador detecta e se re-executa automaticamente com `-NoProfile`

**Problema:** Usuário esquece de abrir como Admin
- **Solução:** O instalador detecta, mostra instruções visuais e oferece abrir automaticamente

**Problema:** Git ou Node.js não instalados
- **Solução:** O instalador baixa e instala automaticamente (versões estáveis)

**Problema:** Instalação anterior corrompida
- **Solução:** O instalador remove a pasta anterior antes de clonar

---

## Troubleshooting

### ❌ Erro: "Execution Policy"

**Sintoma:**
```
irm : O arquivo ... não pode ser carregado porque a execução de scripts está desabilitada neste sistema.
```

**Solução:**
Execute este comando primeiro:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

Depois rode o instalador normalmente.

---

### ❌ Erro: "Access Denied" ou "Acesso Negado"

**Sintoma:**
```
Access to the path '...' is denied.
```

**Causa:** PowerShell não está rodando como Administrador.

**Solução:**
Feche o PowerShell e abra novamente **como Administrador** (veja Passo 1 acima).

---

### ❌ Erro: "git.exe não reconhecido"

**Sintoma:**
```
git.exe : O termo 'git.exe' não é reconhecido...
```

**Causa:** Git não está instalado OU o instalador não conseguiu instalar.

**Solução Manual:**
1. Baixe Git: https://git-scm.com/download/win
2. Instale com opções padrão
3. **FECHE e REABRA** o PowerShell como Admin
4. Rode o instalador novamente

---

### ❌ Erro: "node não reconhecido"

**Sintoma:**
```
node : O termo 'node' não é reconhecido...
```

**Causa:** Node.js não está instalado OU o instalador não conseguiu instalar.

**Solução Manual:**
1. Baixe Node.js: https://nodejs.org (versão LTS)
2. Instale com opções padrão
3. **FECHE e REABRA** o PowerShell como Admin
4. Rode o instalador novamente

---

### ❌ Instalador fecha sozinho

**Causa:** Erro silencioso ou PowerShell fechado manualmente.

**Solução:**
Cole o comando **em uma linha só**:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -NoExit -Command "irm "https://raw.githubusercontent.com/Paulothedeveloper/WindowsVideoOptimizer/main/quick-install.ps1?cb=$(Get-Random)" | iex"
```

O `-NoExit` mantém a janela aberta mesmo com erro.

---

### ❌ Erro no PowerShell profile (linha XX)

**Sintoma:**
```
Microsoft.PowerShell_profile.ps1:69 caractere:5
+ & (Get-Command git.exe ...
```

**Causa:** Seu PowerShell profile personalizado está interferindo.

**Solução Automática:**
O novo instalador detecta isso e se re-executa automaticamente sem profile!

**Solução Manual (se não funcionar):**
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm "https://raw.githubusercontent.com/Paulothedeveloper/WindowsVideoOptimizer/main/quick-install.ps1?cb=$(Get-Random)" | iex"
```

---

## Instalação Manual (Alternativa)

Se o one-liner não funcionar, use este método:

### 1. Baixar ZIP
https://github.com/Paulothedeveloper/WindowsVideoOptimizer/archive/refs/heads/main.zip

### 2. Extrair
Extraia para qualquer pasta (ex: `C:\FrameForge`)

### 3. Instalar Node.js
https://nodejs.org (baixe e instale a versão LTS)

### 4. Abrir PowerShell como Admin
No **DENTRO** da pasta extraída:
- Segure **Shift** e clique com botão direito em área vazia
- Escolha "Abrir janela do PowerShell aqui" ou "Abrir no Terminal"

### 5. Executar comandos manualmente:
```powershell
# Instalar dependências
npm install

# Executar (mantém esta janela aberta!)
node server.js
```

### 6. Abrir navegador
Acesse: http://localhost:3000

---

## Verificar Instalação

Depois de instalar, verifique:

```powershell
# Verificar pasta
Test-Path "$env:LOCALAPPDATA\FrameForge"

# Verificar atalho
Test-Path "$env:USERPROFILE\Desktop\FrameForge.lnk"

# Verificar Node.js
node --version

# Verificar Git
git --version
```

Todos devem retornar `True` (pastas) ou versões (Node/Git).

---

## Desinstalar

```powershell
# Remover pasta
Remove-Item -Path "$env:LOCALAPPDATA\FrameForge" -Recurse -Force

# Remover atalho
Remove-Item -Path "$env:USERPROFILE\Desktop\FrameForge.lnk" -Force
```

**Nota:** Git e Node.js NÃO são removidos (podem ser úteis para outros programas).

---

## Suporte

- 🐛 **Issues:** https://github.com/Paulothedeveloper/WindowsVideoOptimizer/issues
- 📖 **Docs:** https://github.com/Paulothedeveloper/WindowsVideoOptimizer/blob/main/README.md
- 📧 **Email:** (adicionar quando tiver)

---

<div align="center">

**Made with ❤️ and 🐱 by Neko-chan**

Nya~! (=^･ω･^=)ฅ

</div>
