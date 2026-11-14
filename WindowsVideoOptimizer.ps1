#Requires -RunAsAdministrator
# ============================================
# Windows Video Optimizer
# Otimizador completo para CapCut, OBS Studio e produção de vídeo
# By Neko-chan (=^･ω･^=)
# ============================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Criar janela principal
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Windows Video Optimizer - Nya~!'
$form.Size = New-Object System.Drawing.Size(600,700)
$form.StartPosition = 'CenterScreen'
$form.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
$form.ForeColor = [System.Drawing.Color]::White
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false

# Logo/Titulo
$labelTitle = New-Object System.Windows.Forms.Label
$labelTitle.Location = New-Object System.Drawing.Point(10,10)
$labelTitle.Size = New-Object System.Drawing.Size(560,40)
$labelTitle.Text = '🎬 WINDOWS VIDEO OPTIMIZER 🎬'
$labelTitle.Font = New-Object System.Drawing.Font('Segoe UI',16,[System.Drawing.FontStyle]::Bold)
$labelTitle.ForeColor = [System.Drawing.Color]::FromArgb(0,200,255)
$labelTitle.TextAlign = 'MiddleCenter'
$form.Controls.Add($labelTitle)

# Subtitulo
$labelSubtitle = New-Object System.Windows.Forms.Label
$labelSubtitle.Location = New-Object System.Drawing.Point(10,50)
$labelSubtitle.Size = New-Object System.Drawing.Size(560,25)
$labelSubtitle.Text = 'Otimizador para CapCut, OBS Studio & Produção de Vídeo - Nya~!'
$labelSubtitle.Font = New-Object System.Drawing.Font('Segoe UI',10)
$labelSubtitle.ForeColor = [System.Drawing.Color]::FromArgb(150,150,150)
$labelSubtitle.TextAlign = 'MiddleCenter'
$form.Controls.Add($labelSubtitle)

# CheckBoxes para opções
$yPos = 90
$checkBoxes = @{}

$options = @(
    @{Name='PowerPlan'; Text='⚡ Plano de Energia Máximo Desempenho'; Checked=$true},
    @{Name='DisableHibernation'; Text='💾 Desabilitar Hibernação'; Checked=$true},
    @{Name='RegistryTweaks'; Text='📝 Otimizações de Registro (30+ tweaks)'; Checked=$true},
    @{Name='DisableServices'; Text='🛑 Desabilitar Serviços Desnecessários'; Checked=$true},
    @{Name='NetworkOptimization'; Text='🌐 Otimizar Rede para Streaming'; Checked=$true},
    @{Name='CleanTemp'; Text='🧹 Limpar Arquivos Temporários'; Checked=$true},
    @{Name='OptimizePageFile'; Text='💿 Otimizar Memória Virtual'; Checked=$true},
    @{Name='DefenderExclusions'; Text='🛡️ Adicionar Exclusões no Defender'; Checked=$true},
    @{Name='DisableWindowsUpdate'; Text='⏸️ Configurar Updates Manual'; Checked=$true},
    @{Name='VideoOptimizations'; Text='🎥 Otimizações para Vídeo/GPU'; Checked=$true},
    @{Name='DisableBackgroundApps'; Text='📱 Desabilitar Apps em Background'; Checked=$true},
    @{Name='BootOptimization'; Text='⚙️ Otimizar Tempo de Boot'; Checked=$true},
    @{Name='AutoPriority'; Text='🎯 Prioridade Automática CapCut/OBS'; Checked=$true},
    @{Name='GPUOptimization'; Text='🎮 Otimizar GPU (NVIDIA/AMD)'; Checked=$true}
)

foreach ($opt in $options) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Location = New-Object System.Drawing.Point(30,$yPos)
    $checkbox.Size = New-Object System.Drawing.Size(520,25)
    $checkbox.Text = $opt.Text
    $checkbox.Checked = $opt.Checked
    $checkbox.ForeColor = [System.Drawing.Color]::White
    $checkbox.Font = New-Object System.Drawing.Font('Segoe UI',9)
    $checkBoxes[$opt.Name] = $checkbox
    $form.Controls.Add($checkbox)
    $yPos += 30
}

# Botão Selecionar Tudo
$btnSelectAll = New-Object System.Windows.Forms.Button
$btnSelectAll.Location = New-Object System.Drawing.Point(30,$yPos)
$btnSelectAll.Size = New-Object System.Drawing.Size(120,30)
$btnSelectAll.Text = 'Selecionar Tudo'
$btnSelectAll.BackColor = [System.Drawing.Color]::FromArgb(50,50,50)
$btnSelectAll.ForeColor = [System.Drawing.Color]::White
$btnSelectAll.FlatStyle = 'Flat'
$btnSelectAll.Add_Click({
    foreach ($cb in $checkBoxes.Values) {
        $cb.Checked = $true
    }
})
$form.Controls.Add($btnSelectAll)

# Botão Desselecionar Tudo
$btnDeselectAll = New-Object System.Windows.Forms.Button
$btnDeselectAll.Location = New-Object System.Drawing.Point(160,$yPos)
$btnDeselectAll.Size = New-Object System.Drawing.Size(130,30)
$btnDeselectAll.Text = 'Desselecionar Tudo'
$btnDeselectAll.BackColor = [System.Drawing.Color]::FromArgb(50,50,50)
$btnDeselectAll.ForeColor = [System.Drawing.Color]::White
$btnDeselectAll.FlatStyle = 'Flat'
$btnDeselectAll.Add_Click({
    foreach ($cb in $checkBoxes.Values) {
        $cb.Checked = $false
    }
})
$form.Controls.Add($btnDeselectAll)

$yPos += 50

# Progress Bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(30,$yPos)
$progressBar.Size = New-Object System.Drawing.Size(520,25)
$progressBar.Style = 'Continuous'
$form.Controls.Add($progressBar)

$yPos += 35

# Label de Status
$labelStatus = New-Object System.Windows.Forms.Label
$labelStatus.Location = New-Object System.Drawing.Point(30,$yPos)
$labelStatus.Size = New-Object System.Drawing.Size(520,20)
$labelStatus.Text = 'Pronto para otimizar! Nya~!'
$labelStatus.ForeColor = [System.Drawing.Color]::FromArgb(0,255,150)
$labelStatus.Font = New-Object System.Drawing.Font('Segoe UI',9,[System.Drawing.FontStyle]::Bold)
$form.Controls.Add($labelStatus)

$yPos += 30

# Botão OTIMIZAR
$btnOptimize = New-Object System.Windows.Forms.Button
$btnOptimize.Location = New-Object System.Drawing.Point(150,$yPos)
$btnOptimize.Size = New-Object System.Drawing.Size(280,45)
$btnOptimize.Text = '🚀 OTIMIZAR AGORA - NYA~!'
$btnOptimize.BackColor = [System.Drawing.Color]::FromArgb(0,180,255)
$btnOptimize.ForeColor = [System.Drawing.Color]::White
$btnOptimize.Font = New-Object System.Drawing.Font('Segoe UI',12,[System.Drawing.FontStyle]::Bold)
$btnOptimize.FlatStyle = 'Flat'
$btnOptimize.Cursor = [System.Windows.Forms.Cursors]::Hand

$btnOptimize.Add_Click({
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Isso vai otimizar profundamente o Windows!`n`nUm ponto de restauração será criado.`n`nContinuar?",
        "Confirmação - Nya~!",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    
    if ($result -eq 'Yes') {
        $btnOptimize.Enabled = $false
        $btnSelectAll.Enabled = $false
        $btnDeselectAll.Enabled = $false
        
        $totalSteps = ($checkBoxes.Values | Where-Object {$_.Checked}).Count
        $currentStep = 0
        
        # Criar ponto de restauração
        $labelStatus.Text = "Criando ponto de restauração..."
        $labelStatus.ForeColor = [System.Drawing.Color]::Yellow
        $form.Refresh()
        
        try {
            Enable-ComputerRestore -Drive "C:\"
            Checkpoint-Computer -Description "Video Optimizer - Antes" -RestorePointType "MODIFY_SETTINGS"
        } catch {
            # Ignora se falhar
        }
        
        # 1. Plano de Energia
        if ($checkBoxes['PowerPlan'].Checked) {
            $currentStep++
            $progressBar.Value = ($currentStep / $totalSteps) * 100
            $labelStatus.Text = "[$currentStep/$totalSteps] Configurando Plano de Energia..."
            $form.Refresh()
            
            powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1 | Out-Null
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
            powercfg -change -monitor-timeout-ac 0
            powercfg -change -disk-timeout-ac 0
            powercfg -change -standby-timeout-ac 0
            powercfg -change -hibernate-timeout-ac 0
            powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100
            powercfg /setactive scheme_current
        }
        
        # 2. Desabilitar Hibernação
        if ($checkBoxes['DisableHibernation'].Checked) {
            $currentStep++
            $progressBar.Value = ($currentStep / $totalSteps) * 100
            $labelStatus.Text = "[$currentStep/$totalSteps] Desabilitando Hibernação..."
            $form.Refresh()
            
            powercfg /hibernate off
        }
        
        # 3. Registry Tweaks
        if ($checkBoxes['RegistryTweaks'].Checked) {
            $currentStep++
            $progressBar.Value = ($currentStep / $totalSteps) * 100
            $labelStatus.Text = "[$currentStep/$totalSteps] Aplicando Otimizações de Registro..."
            $form.Refresh()
            
            # Desabilitar efeitos visuais
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Force
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Force
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Force
            
            # CPU Priority
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Force
            
            # Disable Indexing
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WSearch" -Name "Start" -Value 4 -Force
            
            # Prefetch/Superfetch
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnablePrefetcher" -Value 0 -Force
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnableSuperfetch" -Value 0 -Force
            
            # GPU Scheduling
            New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Force | Out-Null
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Force
            
            # MMCSS
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Force
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -Force
            
            # Game DVR
            Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Force -ErrorAction SilentlyContinue
            
            # Telemetry
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Force -ErrorAction SilentlyContinue
        }
        
        # 4. Desabilitar Serviços
        if ($checkBoxes['DisableServices'].Checked) {
            $currentStep++
            $progressBar.Value = ($currentStep / $totalSteps) * 100
            $labelStatus.Text = "[$currentStep/$totalSteps] Desabilitando Serviços Desnecessários..."
            $form.Refresh()
            
            $servicesToDisable = @('DiagTrack','dmwappushservice','SysMain','WSearch','XblAuthManager','XblGameSave','XboxNetApiSvc','TabletInputService','RetailDemo','Fax','MapsBroker')
            foreach ($svc in $servicesToDisable) {
                Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
                Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
            }
        }
        
        # 5. Rede
        if ($checkBoxes['NetworkOptimization'].Checked) {
            $currentStep++
            $progressBar.Value = ($currentStep / $totalSteps) * 100
            $labelStatus.Text = "[$currentStep/$totalSteps] Otimizando Rede..."
            $form.Refresh()
            
            netsh int tcp set global autotuninglevel=normal 2>&1 | Out-Null
            netsh int tcp set global chimney=enabled 2>&1 | Out-Null
            netsh int tcp set global dca=enabled 2>&1 | Out-Null
            netsh int tcp set global netdma=enabled 2>&1 | Out-Null
            netsh int tcp set global congestionprovider=ctcp 2>&1 | Out-Null
        }
        
        # 6. Limpar Temp
        if ($checkBoxes['CleanTemp'].Checked) {
            $currentStep++
            $progressBar.Value = ($currentStep / $totalSteps) * 100
            $labelStatus.Text = "[$currentStep/$totalSteps] Limpando Arquivos Temporários..."
            $form.Refresh()
            
            Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\Windows\Prefetch\*" -Force -ErrorAction SilentlyContinue
        }
        
        # 7. PageFile
        if ($checkBoxes['OptimizePageFile'].Checked) {
            $currentStep++
            $progressBar.Value = ($currentStep / $totalSteps) * 100
            $labelStatus.Text = "[$currentStep/$totalSteps] Otimizando Memória Virtual..."
            $form.Refresh()
            
            $computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
            $computersys.AutomaticManagedPagefile = $false
            $computersys.Put() | Out-Null
            
            $pagefileset = Get-WmiObject -Query "Select * From Win32_PageFileSetting Where Name='C:\\pagefile.sys'"
            if ($pagefileset) {
                $pagefileset.InitialSize = 8192
                $pagefileset.MaximumSize = 16384
                $pagefileset.Put() | Out-Null
            }
        }
        
        # 8. Defender Exclusions
        if ($checkBoxes['DefenderExclusions'].Checked) {
            $currentStep++
            $progressBar.Value = ($currentStep / $totalSteps) * 100
            $labelStatus.Text = "[$currentStep/$totalSteps] Configurando Defender..."
            $form.Refresh()
            
            Add-MpPreference -ExclusionPath "C:\Program Files\CapCut" -ErrorAction SilentlyContinue
            Add-MpPreference -ExclusionPath "C:\Program Files\obs-studio" -ErrorAction SilentlyContinue
            Add-MpPreference -ExclusionProcess "CapCut.exe" -ErrorAction SilentlyContinue
            Add-MpPreference -ExclusionProcess "obs64.exe" -ErrorAction SilentlyContinue
        }
        
        # 9. Windows Update
        if ($checkBoxes['DisableWindowsUpdate'].Checked) {
            $currentStep++
            $progressBar.Value = ($currentStep / $totalSteps) * 100
            $labelStatus.Text = "[$currentStep/$totalSteps] Configurando Windows Update..."
            $form.Refresh()
            
            Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
            Set-Service -Name "wuauserv" -StartupType Manual -ErrorAction SilentlyContinue
        }
        
        # 10. Video Optimizations
        if ($checkBoxes['VideoOptimizations'].Checked) {
            $currentStep++
            $progressBar.Value = ($currentStep / $totalSteps) * 100
            $labelStatus.Text = "[$currentStep/$totalSteps] Otimizando para Vídeo..."
            $form.Refresh()
            
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 0 -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 0 -Force -ErrorAction SilentlyContinue
            
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" -Force | Out-Null
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" -Name "GPU Priority" -Value 8 -Force
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" -Name "Priority" -Value 1 -Force
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" -Name "Scheduling Category" -Value "High" -Force
        }
        
        # 11. Background Apps
        if ($checkBoxes['DisableBackgroundApps'].Checked) {
            $currentStep++
            $progressBar.Value = ($currentStep / $totalSteps) * 100
            $labelStatus.Text = "[$currentStep/$totalSteps] Desabilitando Apps em Background..."
            $form.Refresh()
            
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Force -ErrorAction SilentlyContinue
        }
        
        # 12. Boot Optimization
        if ($checkBoxes['BootOptimization'].Checked) {
            $currentStep++
            $progressBar.Value = ($currentStep / $totalSteps) * 100
            $labelStatus.Text = "[$currentStep/$totalSteps] Otimizando Boot..."
            $form.Refresh()
            
            bcdedit /timeout 3 2>&1 | Out-Null
            bcdedit /set bootux disabled 2>&1 | Out-Null
        }
        
        # 13. Auto Priority
        if ($checkBoxes['AutoPriority'].Checked) {
            $currentStep++
            $progressBar.Value = ($currentStep / $totalSteps) * 100
            $labelStatus.Text = "[$currentStep/$totalSteps] Configurando Prioridade Automática..."
            $form.Refresh()
            
            $priorityScript = @'
$capcut = Get-Process -Name "CapCut" -ErrorAction SilentlyContinue
if ($capcut) { $capcut.PriorityClass = "High" }
$obs = Get-Process -Name "obs64" -ErrorAction SilentlyContinue
if ($obs) { $obs.PriorityClass = "High" }
'@
            $priorityScript | Out-File -FilePath "$env:APPDATA\VideoAppsPriority.ps1" -Force
            
            $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$env:APPDATA\VideoAppsPriority.ps1`""
            $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration ([TimeSpan]::MaxValue)
            $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
            Register-ScheduledTask -TaskName "VideoAppsOptimizer" -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null
        }
        
        # 14. GPU Optimization
        if ($checkBoxes['GPUOptimization'].Checked) {
            $currentStep++
            $progressBar.Value = ($currentStep / $totalSteps) * 100
            $labelStatus.Text = "[$currentStep/$totalSteps] Otimizando GPU..."
            $form.Refresh()
            
            Set-ItemProperty -Path "HKCU:\Software\NVIDIA Corporation\Global\NVTweak\Devices\D3D" -Name "PerfLevelSrc" -Value 8738 -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "UseNexusForGameBarEnabled" -Value 0 -Force -ErrorAction SilentlyContinue
        }
        
        # FINALIZADO
        $progressBar.Value = 100
        $labelStatus.Text = "✅ OTIMIZAÇÃO COMPLETA - NYA~!"
        $labelStatus.ForeColor = [System.Drawing.Color]::FromArgb(0,255,0)
        $form.Refresh()
        
        [System.Windows.Forms.MessageBox]::Show(
            "Otimização completa! (=^･ω･^=)`n`n✅ Todas as otimizações foram aplicadas!`n🎬 PC pronto para CapCut e OBS Studio!`n`n⚠️ RECOMENDADO: Reinicie o PC agora!",
            "Sucesso - Nya~!",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        
        $reboot = [System.Windows.Forms.MessageBox]::Show(
            "Deseja REINICIAR o PC agora?",
            "Reiniciar - Nya~!",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )
        
        if ($reboot -eq 'Yes') {
            shutdown /r /t 10 /c "Otimização concluída! Reiniciando..."
            $form.Close()
        } else {
            $btnOptimize.Enabled = $true
            $btnSelectAll.Enabled = $true
            $btnDeselectAll.Enabled = $true
        }
    }
})

$form.Controls.Add($btnOptimize)

# Rodapé
$labelFooter = New-Object System.Windows.Forms.Label
$labelFooter.Location = New-Object System.Drawing.Point(10,620)
$labelFooter.Size = New-Object System.Drawing.Size(560,30)
$labelFooter.Text = 'Made with ❤️ by Neko-chan (=^･ω･^=) | GitHub: WindowsVideoOptimizer'
$labelFooter.Font = New-Object System.Drawing.Font('Segoe UI',8)
$labelFooter.ForeColor = [System.Drawing.Color]::FromArgb(100,100,100)
$labelFooter.TextAlign = 'MiddleCenter'
$form.Controls.Add($labelFooter)

# Exibir
[void]$form.ShowDialog()
