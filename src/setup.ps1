#Requires -RunAsAdministrator

# powershell.exe -ExecutionPolicy Bypass -File C:\Users\WDAGUtilityAccount\Desktop\windows-setup\src\setup.ps1

$ErrorActionPreference = 'Stop'

function CenterText {
    param(
        [string]$Message
    )
    $padSize = [Math]::Truncate($Host.UI.RawUI.BufferSize.Width / 2)[0] - [Math]::Truncate($Message.Length / 2)[0]
    $extraPadSize = 1 - ($Message.Length % 2)

    for ($i = 0; $i -lt $padSize + $extraPadSize; $i++) {
        $string = $string + "-"
    }

    $string = $string + $Message

    for ($i = 0; $i -lt $padSize - 1; $i++) {
        $string = $string + "-"
    }

    Write-Host $string -ForegroundColor Cyan
}

enum LogLevel {
    Info
    Warn
    Err
}

function Write-Log {
    param(
        [string]$Message,
        [LogLevel]$Warn = [LogLevel]::Info
    )

    # Write with timestamp
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $foregroundColor = 'Green'
    
    if ($Warn -eq [LogLevel]::Warn) {
        $foregroundColor = 'Yellow'
    }
    elseif ($Warn -eq [LogLevel]::Err) {
        $foregroundColor = 'Red'
    }

    Write-Host "[$timestamp] $Message" -ForegroundColor $foregroundColor
}

function RunTask {
    param(
        [string]$taskName,
        [scriptblock]$task,
        [switch]$NoWait = $false
    )
    
    CenterText $taskName
    Write-Host
    
    if ($NoWait) {
        Start-Process powershell -ArgumentList '-NoExit', '-NoProfile', '-Command', $task
        Write-Log "Task: '$taskName' is running in another process."
    }
    else {
        Start-Process powershell -NoNewWindow -ArgumentList '-NoProfile', '-Command', $task -Wait 
        Write-Log "Task: '$taskName' is completed."
    }

    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')

    Write-Host
}

RunTask 'Change UAC' {
    Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorAdmin -Value 0 -Type DWord
    Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorUser -Value 0 -Type DWord
}

RunTask 'Change powerCfg' {
    # 충전 중 화면 끄기 해제
    powercfg /CHANGE /monitor-timeout-ac 0
    
    # 배터리 사용 중 화면 끄기 10분
    powercfg /CHANGE /monitor-timeout-dc 10
    
    # 충전 중 컴퓨터 Sleep 모드 해제
    powercfg /CHANGE /standby-timeout-ac 0

    # 배터리 사용 중 컴퓨터 Sleep 모드 30분
    powercfg /CHANGE /standby-timeout-dc 30
    
    # 충전 중 전원버튼 동작을 shutdown으로 변경
    powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 3

    # 배터리 사용 중 전원버튼 동작을 shutdown으로 변경
    powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 3

    # apply
    powercfg -SetActive SCHEME_CURRENT
}

RunTask 'Setup explorer' {
    # 시작 레이아웃에 pin을 더 많이 표시
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name Start_Layout -Value 1 -Type DWord
    # 태스크바 왼쪽 정렬
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name TaskbarAl -Value 0 -Type DWord
    # 태스크바 그룹화 비활성화
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name TaskbarGlomLevel -Value 2 -Type DWord
    # Task View 버튼 비활성화
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ShowTaskViewButton -Value 0 -Type DWord
    # Widget Button 숨기기
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name TaskbarDa -Value 0 -Type DWord
    # Start Layout에서 표시할 항목 설정
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Start' -Name VisiblePlaces -Value ([byte[]](0x00)) -Type Binary
    # Multi-Monitor에서 태스크바 그룹화 활성화
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name MMTaskbarGlomLevel -Value 0 -Type DWord
    # 숨김 파일 표시 활성화
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name Hidden -Value 1 -Type DWord
    # 확장자 숨김 비활성화
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name HideFileExt -Value 0 -Type DWord
    # 풀 경로 표시 비활성화
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name DontPrettyPath -Value 0 -Type DWord
    # 하단 상태 표시줄 표시
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ShowStatusBar -Value 1 -Type DWord
    # 시계 초 표시 활성화
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ShowSecondsInSystemClock -Value 1 -Type DWord
    # 자동 선택 비활성화
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name AutoCheckSelect -Value 0 -Type DWord
    # 코파일럿 버튼 비활성화
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ShowCopilotButton -Value 0 -Type DWord
    # 검색 버튼 비활성화
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name SearchboxTaskbarMode -Value 0 -Type DWord
    
    # Explorer 재시작
    Stop-Process -Name explorer -Force
}

RunTask 'Install git' {
    winget install --disable-interactivity --accept-package-agreements --accept-source-agreements Git.Git
}

RunTask 'Setup git config' {
    $username = 'lewohy'
    $email = 'lwh8762@gmail.com'
    
    git config --global user.name $username
    git config --global user.email $email
}

RunTask 'Sync installed packages' {
    $location = """$home\packages"""
    $targetRepository = 'https://github.com/lewohy/packages.git'
    
    if (-not (Test-Path $location)) {
        git clone $targetRepository $location
    }
    else {
        git -C $location pull
    }
}

RunTask 'Install winget packages' {
    winget settings --enable InstallerHashOverride
    winget import -i """$home\packages\winget.json""" --disable-interactivity --accept-package-agreements --accept-source-agreements
} -NoWait

RunTask 'Install scoop' {
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

RunTask 'Install scoop packages' {
    scoop import """$home\packages\scoop.json"""
} -NoWait


RunTask 'Config Keyboard' {
    Set-ItemProperty -Path 'HKCU:\Control Panel\Keyboard' -Name InitialKeyboardIndicators -Value 2
    Set-ItemProperty -Path 'HKCU:\Control Panel\Keyboard' -Name KeyboardDelay -Value 0
    Set-ItemProperty -Path 'HKCU:\Control Panel\Keyboard' -Name KeyboardSpeed -Value 31
}

RunTask 'Set language and format' {
    Add-WindowsCapability -Online -Name 'Language.Basic~~~ko-KR'
    Set-WinUILanguageOverride -Language 'en-US'
    Set-WinUserLanguageList -LanguageList "ko-KR" -Force
    Set-WinSystemLocale -SystemLocale "ko-KR"

    Set-ItemProperty -Path 'HKCU:\Control Panel\International' -Name sLongDate -Value 'yyyy-MM-dd' -Type String
    Set-ItemProperty -Path 'HKCU:\Control Panel\International' -Name sShortDate -Value 'yyyy-MM-dd' -Type String
    Set-ItemProperty -Path 'HKCU:\Control Panel\International' -Name sShortTime -Value 'HH:mm' -Type String
    Set-ItemProperty -Path 'HKCU:\Control Panel\International' -Name sTimeFormat -Value 'HH:mm:ss' -Type String
}

RunTask 'Config touchpad' {
    # three finger slide gesture를 Switch apps and show desktop으로 설정
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad' -Name ThreeFingerSlideEnabled -Value 1 -Type DWord

    # three finger tab gesture를 휠 클릭으로 설정
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad' -Name ThreeFingerTapEnabled -Value 4 -Type DWord
}

RunTask 'Set clipboard' {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Clipboard' -Name EnableClipboardHistory -Value 1 -Type DWord
    
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Clipboard' -Name CloudClipboardAutomaticUpload -Value 1 -Type DWord
}

RunTask 'Pin taskbar item' {
    # TODO: Add taskbar item
}

RunTask 'Set context menu' {
    # TODO: Add context menu
}

RunTask 'KMS Auto activation' {
    Start-Process powershell -Verb RunAs -ArgumentList 'slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX'
    Start-Process powershell -Verb RunAs -ArgumentList 'slmgr /skms kms.digiboy.ir'
    Start-Process powershell -Verb RunAs -ArgumentList 'slmgr /ato'
}
