#Requires -RunAsAdministrator
param(
    [string]$Options
)

$selectedOptions = $Options -split ','

function Send-Progress {
    param($Percent)
    Write-Host "[PROGRESS:$Percent]"
}

function Send-Status {
    param($Message)
    Write-Host "[STATUS:$Message]"
}

try {
    Send-Status "Criando ponto de restauração..."
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "Video Optimizer - Antes" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
    
    $total = $selectedOptions.Count
    $current = 0
    
    foreach ($option in $selectedOptions) {
        $current++
        $percent = [int](($current / $total) * 100)
        
        switch ($option) {
            'power' {
                Send-Status "[$current/$total] Configurando Plano de Energia..."
                powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1 | Out-Null
                powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
                powercfg -change -monitor-timeout-ac 0
                powercfg -change -disk-timeout-ac 0
                powercfg -change -standby-timeout-ac 0
                powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100
                powercfg /setactive scheme_current
            }
            
            'hibernation' {
                Send-Status "[$current/$total] Desabilitando Hibernação..."
                powercfg /hibernate off
            }
            
            'registry' {
                Send-Status "[$current/$total] Aplicando Otimizações de Registro..."
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WSearch" -Name "Start" -Value 4 -Force -ErrorAction SilentlyContinue
                New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Force -ErrorAction SilentlyContinue | Out-Null
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -Force -ErrorAction SilentlyContinue
            }
            
            'services' {
                Send-Status "[$current/$total] Desabilitando Serviços Desnecessários..."
                $services = @('DiagTrack','dmwappushservice','SysMain','WSearch','XblAuthManager','XblGameSave','XboxNetApiSvc')
                foreach ($svc in $services) {
                    Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
                    Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
                }
            }
            
            'network' {
                Send-Status "[$current/$total] Otimizando Rede..."
                netsh int tcp set global autotuninglevel=normal 2>&1 | Out-Null
                netsh int tcp set global chimney=enabled 2>&1 | Out-Null
                netsh int tcp set global congestionprovider=ctcp 2>&1 | Out-Null
            }
            
            'temp' {
                Send-Status "[$current/$total] Limpando Arquivos Temporários..."
                Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
            
            'pagefile' {
                Send-Status "[$current/$total] Otimizando Memória Virtual..."
                $cs = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
                $cs.AutomaticManagedPagefile = $false
                $cs.Put() | Out-Null
            }
            
            'defender' {
                Send-Status "[$current/$total] Configurando Defender..."
                Add-MpPreference -ExclusionPath "C:\Program Files\CapCut" -ErrorAction SilentlyContinue
                Add-MpPreference -ExclusionPath "C:\Program Files\obs-studio" -ErrorAction SilentlyContinue
                Add-MpPreference -ExclusionProcess "CapCut.exe" -ErrorAction SilentlyContinue
                Add-MpPreference -ExclusionProcess "obs64.exe" -ErrorAction SilentlyContinue
            }
            
            'updates' {
                Send-Status "[$current/$total] Configurando Windows Update..."
                Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
                Set-Service -Name "wuauserv" -StartupType Manual -ErrorAction SilentlyContinue
            }
            
            'video' {
                Send-Status "[$current/$total] Otimizando para Vídeo..."
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" -Force -ErrorAction SilentlyContinue | Out-Null
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" -Name "GPU Priority" -Value 8 -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" -Name "Priority" -Value 1 -Force -ErrorAction SilentlyContinue
            }
            
            'background' {
                Send-Status "[$current/$total] Desabilitando Apps em Background..."
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Force -ErrorAction SilentlyContinue
            }
            
            'boot' {
                Send-Status "[$current/$total] Otimizando Boot..."
                bcdedit /timeout 3 2>&1 | Out-Null
                bcdedit /set bootux disabled 2>&1 | Out-Null
            }
            
            'priority' {
                Send-Status "[$current/$total] Configurando Prioridade Automática..."
                $script = @'
$capcut = Get-Process -Name "CapCut" -ErrorAction SilentlyContinue
if ($capcut) { $capcut.PriorityClass = "High" }
$obs = Get-Process -Name "obs64" -ErrorAction SilentlyContinue
if ($obs) { $obs.PriorityClass = "High" }
'@
                $script | Out-File -FilePath "$env:APPDATA\VideoAppsPriority.ps1" -Force
                
                $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$env:APPDATA\VideoAppsPriority.ps1`""
                $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration ([TimeSpan]::MaxValue)
                $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
                Register-ScheduledTask -TaskName "VideoAppsOptimizer" -Action $action -Trigger $trigger -Principal $principal -Force -ErrorAction SilentlyContinue | Out-Null
            }
            
            'gpu' {
                Send-Status "[$current/$total] Otimizando GPU..."
                Set-ItemProperty -Path "HKCU:\Software\NVIDIA Corporation\Global\NVTweak\Devices\D3D" -Name "PerfLevelSrc" -Value 8738 -Force -ErrorAction SilentlyContinue
            }
        }
        
        Send-Progress $percent
        Start-Sleep -Milliseconds 100
    }
    
    Send-Status "Otimização completa!"
    Send-Progress 100
    
} catch {
    Write-Error $_.Exception.Message
    exit 1
}
