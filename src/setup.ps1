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
    # FIXME: 
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name TaskbarDa -Value 0 -Type DWord
    # Start Layout 하단에서 '표 시할 항목 설정
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
    # 상단 스냅바 비활성화
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name EnableSnapBar -Value 0 -Type DWord
    
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
    # FIXME: admin권한으로 실행하면 안됨
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
    Set-WinUserLanguageList -LanguageList 'ko-KR' -Force
    Set-WinSystemLocale -SystemLocale 'ko-KR'

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

RunTask 'Set context menu' {
    # set old context menu
    New-Item -Path 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' -Value '' -Force

    # TODO: Add context menu
}

RunTask 'Set XDG_CONFIG_CONFIG' {
    [Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', """$home\.config""", 'User')
}

RunTask 'Enable sandbox feature' {
    # TODO: 테스트 필요
    Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online
}

RunTask 'Reset startup apps' {
    $RegPaths = @(
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run',
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run',
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run',
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'
        
    )
    
    foreach ($RegPath in $RegPaths) {
        if (Test-Path $RegPath) {
            # 레지스트리 키 안의 모든 값을 가져옵니다.
            $values = Get-ItemProperty -Path $RegPath | Select-Object -Property *

            # 값을 하나씩 삭제합니다.
            foreach ($value in $values.PSObject.Properties.Name) {
                if ($value -ne 'PSPath' -and $value -ne 'PSParentPath' -and $value -ne 'PSChildName' -and $value -ne 'PSDrive' -and $value -ne 'PSProvider') {
                    Remove-ItemProperty -Path $RegPath -Name $value
                }
            }
        }
    }
    
    $RegPath = $RegPaths[0]
    
    New-ItemProperty -Path """$RegPath""" -Name 'Discord' -Value """$home\AppData\Local\Discord\Update.exe""" --processStart Discord.exe -PropertyType String
    New-ItemProperty -Path """$RegPath""" -Name 'KakaoTalk' -Value """C:\Program Files (x86)\Kakao\KakaoTalk\KakaoTalk.exe""" -bystartup -PropertyType String
    New-ItemProperty -Path """$RegPath""" -Name 'JetBrains Toolbox' -Value """$home\AppData\Local\JetBrains\Toolbox\bin\jetbrains-toolbox.exe""" --minimize -PropertyType String
    New-ItemProperty -Path """$RegPath""" -Name 'PasteIntoFile' -Value """C:\Program Files (x86)\PasteIntoFile\PasteIntoFile.exe""" tray -PropertyType String
    New-ItemProperty -Path """$RegPath""" -Name 'Resilio Sync' -Value """$home\AppData\Roaming\Resilio Sync\Resilio Sync.exe"""  /MINIMIZED -PropertyType String
    New-ItemProperty -Path """$RegPath""" -Name 'OneDrive' -Value """C:\Program Files\Microsoft OneDrive\OneDrive.exe""" /background -PropertyType String
    New-ItemProperty -Path """$RegPath""" -Name 'GoogleDriveFS' -Value """C:\Program Files\Google\Drive File Stream\94.0.1.0\GoogleDriveFS.exe""" --startup_mode -PropertyType String
}

RunTask 'Setup taskbar' {
    Write-Host 'Run gpedit.msc'
    Write-Host 'User Configuration > Administrative Templates > Start Menu and Taskbar'
    Write-Host 'Enable ""Start Layout"" and edit'
    Write-Host """$home\.config\windows-startlayout\Layout.xml"""
}

RunTask 'Setup quick access' {
    # Clear quick access
    ($QuickAccess.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items()) | ForEach-Object {
        $_.InvokeVerb("unpinfromhome")
    }

    $QuickAccess.Namespace("""$home""").Self.InvokeVerb('pintohome')
    $QuickAccess.Namespace("""$home\Desktop""").Self.InvokeVerb('pintohome')
    $QuickAccess.Namespace("""$home\Downloads""").Self.InvokeVerb('pintohome')
    $QuickAccess.Namespace("""$home\Documents""").Self.InvokeVerb('pintohome')
    $QuickAccess.Namespace("""$home\Pictures""").Self.InvokeVerb('pintohome')
    $QuickAccess.Namespace("""$home\Videos""").Self.InvokeVerb('pintohome')
    $QuickAccess.Namespace("""$home\Obsidian\lewohy\Home""").Self.InvokeVerb('pintohome')
}

RunTask 'KMS Auto activation' {
    Start-Process powershell -Verb RunAs -ArgumentList 'slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX'
    Start-Process powershell -Verb RunAs -ArgumentList 'slmgr /skms kms.digiboy.ir'
    Start-Process powershell -Verb RunAs -ArgumentList 'slmgr /ato'
}

# go install github.com/ewen-lbh/hyprls/cmd/hyprls@latest
#
# TODO: 우측 하단 아이콘
# TODO: gh 설정
# TODO: 기본앱 설정
# TODO: service 설정
# TODO: defender
# TODO: 고정키 해제
#
# TODO: utf-8 설정
#
# TODO: winget Windows Software Development Kit - windows 10.0.22621.2428 설치오류
# TODO: winget MySQL Shell 설치오류
# TODO: winget parsec 설치오류
