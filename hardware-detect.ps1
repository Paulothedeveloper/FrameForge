# Deteccao de hardware e apps instalados, somente leitura, sem exigir admin.
# Projetado para rodar em qualquer PC: cada bloco tem fallback proprio, uma
# falha isolada (ex: sem GPU dedicada, sem apps de video) nunca derruba o
# restante da deteccao. Saida: um unico objeto JSON em stdout.

$result = [ordered]@{
    diskType  = "unknown"
    ramGB     = 0
    cpuName   = "Desconhecido"
    gpu       = [ordered]@{ vendor = "unknown"; name = "Desconhecido" }
    apps      = [ordered]@{ capcut = $false; obs = $false; davinci = $false; premiere = $false }
    isAdmin   = $false
}

# --- Disco (SSD vs HDD, mesma logica usada no optimizer.ps1) ---
try {
    $diskNum = (Get-Partition -DriveLetter C -ErrorAction Stop).DiskNumber
    $media = (Get-PhysicalDisk -ErrorAction Stop | Where-Object { $_.DeviceId -eq $diskNum }).MediaType
    if ($media -eq 'SSD') { $result.diskType = 'SSD' }
    elseif ($media -eq 'HDD') { $result.diskType = 'HDD' }
} catch {}

# --- RAM ---
try {
    $ramBytes = (Get-CimInstance Win32_ComputerSystem -ErrorAction Stop).TotalPhysicalMemory
    $result.ramGB = [math]::Round($ramBytes / 1GB)
} catch {}

# --- CPU ---
try {
    $cpu = (Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -First 1).Name
    if ($cpu) { $result.cpuName = $cpu.Trim() }
} catch {}

# --- GPU: prioriza dedicada (NVIDIA/AMD) sobre integrada (Intel) ---
try {
    $gpus = Get-CimInstance Win32_VideoController -ErrorAction Stop | Where-Object { $_.Name -and $_.Name -notmatch 'Basic Display|Remote Display' }
    $primary = $gpus | Where-Object { $_.Name -match 'NVIDIA|AMD|Radeon' } | Select-Object -First 1
    if (-not $primary) { $primary = $gpus | Select-Object -First 1 }
    if ($primary) {
        $result.gpu.name = $primary.Name.Trim()
        if ($primary.Name -match 'NVIDIA') { $result.gpu.vendor = 'NVIDIA' }
        elseif ($primary.Name -match 'AMD|Radeon') { $result.gpu.vendor = 'AMD' }
        elseif ($primary.Name -match 'Intel') { $result.gpu.vendor = 'Intel' }
    }
} catch {}

# --- Apps instalados: combina registro de desinstalacao (32/64 bit) + AppX (Store) + pastas comuns ---
function Test-AppInstalled {
    param([string[]]$NamePatterns, [string[]]$CommonPaths)

    foreach ($pattern in $NamePatterns) {
        try {
            $hit = Get-ItemProperty -Path @(
                'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
                'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
                'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
            ) -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -match $pattern } | Select-Object -First 1
            if ($hit) { return $true }
        } catch {}
    }
    try {
        foreach ($pattern in $NamePatterns) {
            $appx = Get-AppxPackage -ErrorAction SilentlyContinue | Where-Object { $_.Name -match $pattern -or $_.PackageFullName -match $pattern } | Select-Object -First 1
            if ($appx) { return $true }
        }
    } catch {}
    foreach ($p in $CommonPaths) {
        if (Test-Path $p -ErrorAction SilentlyContinue) { return $true }
    }
    return $false
}

try {
    $result.apps.capcut = Test-AppInstalled -NamePatterns @('CapCut') -CommonPaths @(
        "$env:ProgramFiles\CapCut", "$env:LOCALAPPDATA\CapCut", "${env:ProgramFiles(x86)}\CapCut"
    )
} catch {}
try {
    $result.apps.obs = Test-AppInstalled -NamePatterns @('OBS Studio') -CommonPaths @(
        "$env:ProgramFiles\obs-studio", "${env:ProgramFiles(x86)}\obs-studio"
    )
} catch {}
try {
    $result.apps.davinci = Test-AppInstalled -NamePatterns @('DaVinci Resolve') -CommonPaths @(
        "$env:ProgramFiles\Blackmagic Design\DaVinci Resolve"
    )
} catch {}
try {
    $result.apps.premiere = Test-AppInstalled -NamePatterns @('Adobe Premiere Pro') -CommonPaths @()
} catch {}

try {
    $result.isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
} catch {}

$result | ConvertTo-Json -Compress
