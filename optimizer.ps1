#Requires -RunAsAdministrator
param(
    [string]$Options,
    [string]$LogFile = "$env:TEMP\frameforge-progress.log"
)

$selectedOptions = $Options -split ','

# Write-Host, quando capturado via pipe redirecionado por um processo externo,
# tem encoding imprevisivel neste PowerShell 5.1 (confirmado: corrompe acentos
# mesmo com BOM no arquivo fonte e $OutputEncoding configurado). A escrita direta
# em arquivo via .NET com UTF8Encoding explicito e 100% confiavel - testado e
# confirmado byte a byte. server.js agora le este arquivo via polling.
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
# Reseta o arquivo de log no inicio desta execucao
[System.IO.File]::WriteAllText($LogFile, "", $utf8NoBom)

function Send-Progress {
    param($Percent)
    [System.IO.File]::AppendAllText($LogFile, "[PROGRESS:$Percent]`n", $utf8NoBom)
}

function Send-Status {
    param($Message)
    [System.IO.File]::AppendAllText($LogFile, "[STATUS:$Message]`n", $utf8NoBom)
}

try {
    Send-Status "Criando ponto de restauração..."
    # Checkpoint-Computer pode travar indefinidamente (VSS lento/ocupado em alguns
    # discos). Roda em Job com timeout: se nao terminar em 20s, segue a otimizacao
    # mesmo assim em vez de travar o processo inteiro por causa do restore point.
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    $restoreJob = Start-Job -ScriptBlock {
        Checkpoint-Computer -Description "FrameForge - Antes" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
    }
    $restoreDone = Wait-Job $restoreJob -Timeout 20
    if (-not $restoreDone) {
        Send-Status "Ponto de restauracao esta demorando, continuando sem esperar..."
        Stop-Job $restoreJob -ErrorAction SilentlyContinue
    }
    Remove-Job $restoreJob -Force -ErrorAction SilentlyContinue

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
                powercfg /setacvalueindex scheme_current sub_processor CPMINCORES 100 2>&1 | Out-Null
                powercfg /setacvalueindex scheme_current sub_processor IDLEDISABLE 1 2>&1 | Out-Null
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
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Value "1" -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Serialize" -Name "StartupDelayInMSec" -Value 0 -Force -ErrorAction SilentlyContinue
            }

            'services' {
                Send-Status "[$current/$total] Desabilitando Serviços Desnecessários..."
                $isSSD = $false
                try {
                    $diskNum = (Get-Partition -DriveLetter C -ErrorAction SilentlyContinue).DiskNumber
                    if ($null -ne $diskNum) {
                        $media = (Get-PhysicalDisk -ErrorAction SilentlyContinue | Where-Object { $_.DeviceId -eq $diskNum }).MediaType
                        if ($media -eq 'SSD') { $isSSD = $true }
                    }
                } catch {}

                $services = @('DiagTrack','dmwappushservice','WSearch','XblAuthManager','XblGameSave','XboxNetApiSvc','MapsBroker','Fax','WerSvc','RetailDemo','RemoteRegistry','WalletService')
                if ($isSSD) { $services += 'SysMain' }
                foreach ($svc in $services) {
                    Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
                    Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
                }
            }

            'telemetry' {
                Send-Status "[$current/$total] Reduzindo Telemetria e Rastreamento..."
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force -ErrorAction SilentlyContinue | Out-Null
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Force -ErrorAction SilentlyContinue
                New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Force -ErrorAction SilentlyContinue | Out-Null
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -Force -ErrorAction SilentlyContinue
                New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Force -ErrorAction SilentlyContinue | Out-Null
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0 -Force -ErrorAction SilentlyContinue

                $tasks = @(
                    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
                    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
                    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
                    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
                    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
                    "\Microsoft\Windows\Feedback\Siuf\DmClient",
                    "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
                )
                foreach ($t in $tasks) {
                    $name = Split-Path $t -Leaf
                    $path = Split-Path $t -Parent
                    Disable-ScheduledTask -TaskName $name -TaskPath "$path\" -ErrorAction SilentlyContinue | Out-Null
                }
            }

            'network' {
                Send-Status "[$current/$total] Otimizando Rede..."
                netsh int tcp set global autotuninglevel=normal 2>&1 | Out-Null
                netsh int tcp set global chimney=enabled 2>&1 | Out-Null
                netsh int tcp set global congestionprovider=ctcp 2>&1 | Out-Null
                netsh int tcp set global rss=enabled 2>&1 | Out-Null
                netsh int tcp set global ecncapability=enabled 2>&1 | Out-Null
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpAckFrequency" -Value 1 -Force -ErrorAction SilentlyContinue
            }

            'temp' {
                Send-Status "[$current/$total] Limpando Arquivos Temporários..."
                Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            }

            'diskcleanup' {
                Send-Status "[$current/$total] Limpando Disco (WinSxS, Update cache, Lixeira)..."
                Clear-RecycleBin -Force -ErrorAction SilentlyContinue
                Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "$env:SystemRoot\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
                Start-Service -Name wuauserv -ErrorAction SilentlyContinue
                Remove-Item -Path "$env:SystemRoot\Logs\CBS\*" -Recurse -Force -ErrorAction SilentlyContinue
                Start-Process -FilePath "Dism.exe" -ArgumentList "/online","/Cleanup-Image","/StartComponentCleanup","/Quiet" -Wait -NoNewWindow -ErrorAction SilentlyContinue
            }

            'ssdopt' {
                Send-Status "[$current/$total] Otimizando armazenamento (SSD/HDD)..."
                try {
                    $diskNum = (Get-Partition -DriveLetter C -ErrorAction SilentlyContinue).DiskNumber
                    $media = (Get-PhysicalDisk -ErrorAction SilentlyContinue | Where-Object { $_.DeviceId -eq $diskNum }).MediaType
                    if ($media -eq 'SSD') {
                        Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue
                        fsutil behavior set DisableLastAccess 1 2>&1 | Out-Null
                    } else {
                        Optimize-Volume -DriveLetter C -Defrag -ErrorAction SilentlyContinue
                    }
                } catch {
                    Send-Status "Nao foi possivel detectar o tipo de disco, pulando otimizacao de armazenamento."
                }
            }

            'pagefile' {
                Send-Status "[$current/$total] Otimizando Memória Virtual (PageFile)..."
                $ramBytes = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
                $ramMB = [math]::Round($ramBytes / 1MB)
                if ($ramMB -le 16384) {
                    $initial = [math]::Round($ramMB * 1.5)
                    $maximum = [math]::Round($ramMB * 2)
                } else {
                    $initial = 4096
                    $maximum = 8192
                }

                # Usa CIM (API moderna), nao WMI legado: Get-WmiObject/Set-WmiInstance
                # falham silenciosamente neste tipo de sistema (confirmado em teste real -
                # InitialSize/MaximumSize ficavam 0/0 mesmo sem erro reportado).
                try {
                    $cs = Get-CimInstance Win32_ComputerSystem
                    Set-CimInstance -InputObject $cs -Property @{AutomaticManagedPagefile = $false} -ErrorAction Stop

                    $pf = Get-CimInstance Win32_PageFileSetting -ErrorAction SilentlyContinue
                    if ($pf) {
                        Set-CimInstance -InputObject $pf -Property @{InitialSize = $initial; MaximumSize = $maximum} -ErrorAction Stop
                    } else {
                        New-CimInstance -ClassName Win32_PageFileSetting -Property @{Name = "C:\pagefile.sys"; InitialSize = $initial; MaximumSize = $maximum} -ErrorAction Stop | Out-Null
                    }
                    Send-Status "PageFile configurado: $initial MB - $maximum MB (baseado em $ramMB MB de RAM)"
                } catch {
                    Send-Status "Erro ao configurar PageFile: $_"
                }
            }

            'defender' {
                Send-Status "[$current/$total] Configurando Defender..."
                # Add-MpPreference pode ter "cold start" lento (observado em teste real:
                # > 100s na primeira chamada apos boot, quando o MpCmdRun ainda nao esta
                # totalmente pronto). Roda em Job com timeout para nao travar o restante
                # da otimizacao caso o servico de Defender esteja ocupado/lento.
                $defenderJob = Start-Job -ScriptBlock {
                    Add-MpPreference -ExclusionPath "C:\Program Files\CapCut" -ErrorAction SilentlyContinue
                    Add-MpPreference -ExclusionPath "C:\Program Files\obs-studio" -ErrorAction SilentlyContinue
                    Add-MpPreference -ExclusionProcess "CapCut.exe" -ErrorAction SilentlyContinue
                    Add-MpPreference -ExclusionProcess "obs64.exe" -ErrorAction SilentlyContinue
                }
                $defenderDone = Wait-Job $defenderJob -Timeout 25
                if (-not $defenderDone) {
                    Send-Status "Defender esta demorando, continuando sem esperar..."
                    Stop-Job $defenderJob -ErrorAction SilentlyContinue
                }
                Remove-Job $defenderJob -Force -ErrorAction SilentlyContinue
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

            'startup' {
                Send-Status "[$current/$total] Desabilitando itens de inicialização pesados..."
                $heavyStartup = @('Teams','Spotify','Discord','Skype','OneDrive','CCleaner Updater','Adobe Updater Startup Utility','Steam Client Bootstrapper')
                try {
                    $items = Get-CimInstance Win32_StartupCommand -ErrorAction SilentlyContinue
                    foreach ($item in $items) {
                        foreach ($h in $heavyStartup) {
                            if ($item.Name -like "*$h*") {
                                $regPath = $item.Location
                                try {
                                    Remove-ItemProperty -Path "Registry::$regPath" -Name $item.Name -ErrorAction SilentlyContinue
                                } catch {}
                            }
                        }
                    }
                } catch {}
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
                try {
                    $gpus = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue
                    foreach ($g in $gpus) {
                        if ($g.Name -match 'NVIDIA') {
                            Set-ItemProperty -Path "HKCU:\Software\NVIDIA Corporation\Global\NVTweak\Devices\D3D" -Name "PerfLevelSrc" -Value 8738 -Force -ErrorAction SilentlyContinue
                        }
                        elseif ($g.Name -match 'AMD|Radeon') {
                            New-Item -Path "HKLM:\SOFTWARE\AMD\CN" -Force -ErrorAction SilentlyContinue | Out-Null
                            Set-ItemProperty -Path "HKLM:\SOFTWARE\AMD\CN" -Name "PP_GPUPowerPlay" -Value 1 -Force -ErrorAction SilentlyContinue
                        }
                        elseif ($g.Name -match 'Intel') {
                            # Intel nao expoe tweak de registro publico/estavel; Hardware
                            # Scheduling global (ja aplicado em 'registry') cobre o ganho principal.
                        }
                    }
                } catch {}
            }
        }

        Send-Progress $percent
        Start-Sleep -Milliseconds 100
    }

    Send-Status "Otimização completa!"
    Send-Progress 100

} catch {
    [System.IO.File]::AppendAllText($LogFile, "[ERROR:$($_.Exception.Message)]`n", $utf8NoBom)
    exit 1
}
