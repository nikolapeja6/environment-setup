$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Show-ProgressBar {
    param (
        [int]$ActivityId,
        [string]$Activity,
        [string]$Status,
        [int]$PercentComplete
    )
    Write-Progress -Id $ActivityId -Activity $Activity -Status $Status -PercentComplete $PercentComplete
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$tasks = @(
    ####################
    # Windows Settings #
    ####################
    @{ Name = "Disable admin prompt on windows"; Action = { 
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0
    }},
    @{ Name = "Enable dark mode on windows"; Action = {
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Value 0
    }},
    @{ Name = "Restore old context menu on windows"; Action = {
        reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve 
    }},
    @{ Name = "File Explorer settings - hidden files"; Action = {
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1
    }},
    @{ Name = "File Explorer settings - file extensions"; Action = {
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
    }},
    @{ Name = "File Explorer settings - show full path"; Action = {
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Value 1
    }},
    @{ Name = "File Explorer settings - show status bar"; Action = {
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Statusbar" -Value 1
    }},
    @{ Name = "File Explorer settings - show file size"; Action = {
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSuperHidden" -Value 1
    }},
    @{ Name = "File Explorer settings - this PC"; Action = {
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1
    }},
    @{ Name = "Disable bing search in windows search"; Action = {
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
    }},
    @{ Name = "Windows Taskbar - hide search, task view, chat"; Action = {
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchBoxTaskbarMode" -Value 0 -Type DWord -Force
    }},
    @{ Name = "Date & time format"; Action = {
        Set-TimeZone -Id "Central Europe Standard Time"
        Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "iFirstDayOfWeek" -Value 0
        Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sShortDate" -Value "dd-MMM-yy"
        Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sLongDate" -Value "dd MMMM, yyyy"
        Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sShortTime" -Value "HH:mm"
        Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sTimeFormat" -Value "HH:mm:ss"
    }},


    ####################
    # Install Software #
    ####################
    @{ Name = "Notepad++"; Action = {
        winget install --id Notepad++.Notepad++ -e --accept-package-agreements --accept-source-agreements
        $notepadPlusPlusConfigFile = "$env:APPDATA\Notepad++\config.xml"
        $myNotepadPlusPlusConfig = "$repoRoot\app_settings\Notepad++\config.xml"
        Copy-Item -Path $myNotepadPlusPlusConfig -Destination $notepadPlusPlusConfigFile -Force
    }},
    @{ Name = "7-Zip"; Action = {
        winget install --id 7zip.7zip -e --accept-package-agreements --accept-source-agreements
    }},
    @{ Name = "VideoLAN VLC"; Action = {
        winget install --id VideoLAN.VLC -e --accept-package-agreements --accept-source-agreements
    }},
    @{ Name = "VS Code"; Action = {
        winget install --id Microsoft.VisualStudioCode -e --scope machine --accept-package-agreements --accept-source-agreements --override '/SILENT /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders"'
        $extensions = @(
            "GitHub.copilot",
            "GitHub.copilot-chat",
            "ms-vscode.cpptools",
            "ms-vscode.cpptools-extension-pack",
            "ms-vscode.cpptools-themes",
            "ms-vscode.cmake",
            "ms-vscode.cmake-tools",
            "ms-toolsai.jupyter",
            "ms-toolsai.jupyter-renderers",
            "ms-toolsai.jupyter-slideshow",
            "ms-vscode.powershell",
            "ms-python.vscode-pylance",
            "ms-python.python",
            "ms-python.debugpy"
        )
        #foreach ($extension in $extensions) {
        #    Start-Process -FilePath "C:\Program Files\Microsoft VS Code\Code.exe" -ArgumentList "--install-extension $extension --force" -NoNewWindow -Wait
        #}
    }},
    @{ Name = "Git"; Action = {
        winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements
    }},
    @{ Name = "ConEmu"; Action = {
        winget install --id Maximus5.ConEmu -e --accept-package-agreements --accept-source-agreements
        $conEmuConfigFile = "$env:APPDATA\ConEmu.xml"
        $myConEmuSettings = "$repoRoot\app_settings\ConEmu\ConEmu.xml"
        Copy-Item -Path $myConEmuSettings -Destination $conEmuConfigFile -Force
    }},
    @{ Name = "Everything"; Action = {
        winget install --id voidtools.Everything.Alpha -e --accept-package-agreements --accept-source-agreements
        $everythingConfigFile = "C:\Program Files\Everything 1.5a\Everything-1.5a.ini"
        $myEverythingSettings = "$repoRoot\app_settings\Everything\Everything.ini"
        Copy-Item -Path $myEverythingSettings -Destination $everythingConfigFile -Force
    }},
    @{ Name = "Beyond Compare"; Action = {
        winget install --id ScooterSoftware.BeyondCompare -e --accept-package-agreements --accept-source-agreements
    }},
    @{ Name = "Visual Studio 2022"; Action = {
        winget install --id Microsoft.VisualStudio.2022.Enterprise -e --accept-package-agreements --accept-source-agreements
    }},
    @{ Name = "ProcMon"; Action = {
        winget install --id Microsoft.Sysinternals.ProcessMonitor -e --accept-package-agreements --accept-source-agreements
    }},
    @{ Name = "GitHub Desktop"; Action = {
        winget install --id GitHub.GitHubDesktop -e --accept-package-agreements --accept-source-agreements
    }}
    @{ Name = "Windows App"; Action = {
        winget install --id Microsoft.WindowsApp -e --accept-package-agreements --accept-source-agreements
    }}
    
)

$totalTasks = $tasks.Count
for ($i = 0; $i -lt $totalTasks; $i++) {
    $task = $tasks[$i]
    Show-ProgressBar -ActivityId 1 -Activity "Setting up environment" -Status $task.Name -PercentComplete (($i / $totalTasks) * 100)
    & $task.Action
}
Show-ProgressBar -ActivityId 1 -Activity "Setting up environment" -Status "Completed" -PercentComplete 100

# Restart
Write-Host "Restarting in 5min..."
shutdown /r /t 300
