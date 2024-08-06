# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

$ErrorActionPreference = "Stop"

function RunTask {
    param(
        [string]$taskName,
        [scriptblock]$task
    )
    
    Write-Host "############################# $taskName"
    $task.Invoke()
}


RunTask "ChangeUAC" {
    Start-Process powershell -Verb RunAs -ArgumentList "Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorAdmin -Value 0"
    Start-Process powershell -Verb RunAs -ArgumentList "Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorUser -Value 0"
}

RunTask "ChangePowerCfg" {
    # 충전 중 화면 끄기 해제
    powercfg /CHANGE /monitor-timeout-ac 0
    
    # 배터리 사용 중 화면 끄기 10분
    powercfg /CHANGE /monitor-timeout-dc 10
    
    # 충전 중 컴퓨터 Sleep 모드 해제
    powercfg /CHANGE /standby-timeout-ac 0

    # 배터리 사용 중 컴퓨터 Sleep 모드 30분
    powercfg /CHANGE /standby-timeout-dc 30
}

RunTask "SetupExplorer" {
    # 시작 레이아웃에 pin을 더 많이 표시
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name Start_Layout -Value 1 -Type DWord
    # 태스크바 왼쪽 정렬
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarAl -Value 0 -Type DWord
    # 태스크바 그룹화 비활성화
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarGlomLevel -Value 2 -Type DWord
    # Task View 버튼 비활성화
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowTaskViewButton -Value 0 -Type DWord
    # Widget Button 숨기기
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarDa -Value 0 -Type DWord
    # Start Layout에서 표시할 항목 설정
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Start" -Name VisiblePlaces -Value ([byte[]](0x00)) -Type Binary
    # Multi-Monitor에서 태스크바 그룹화 활성화
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name MMTaskbarGlomLevel -Value 0 -Type DWord







    # 숨김 파일 표시 활성화
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name Hidden -Value 1 -Type DWord
    # 확장자 숨김 비활성화
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideFileExt -Value 0 -Type DWord
    # 풀 경로 표시 비활성화
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name DontPrettyPath -Value 0 -Type DWord
    # 하단 상태 표시줄 표시
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowStatusBar -Value 1 -Type DWord

    # 시계 초 표시 활성화
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowSecondsInSystemClock -Value 1 -Type DWord
    # 자동 선택 비활성화
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name AutoCheckSelect -Value 0 -Type DWord
    # 코파일럿 버튼 비활성화
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowCopilotButton -Value 0 -Type DWord
    # 검색 버튼 비활성화
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -Value 0 -Type DWord

    # Hide TaskBar Thumbnails
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name IconsOnly -Value 0 -Type DWord
    # Hide Desktop Icons
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideIcons -Value 0 -Type DWord
}

function SetupContextMenu {

}

RunTask "SetupGit" {
    winget install --disable-interactivity Git.Git
    git config --global user.name "lewohy"
    git config --global user.email "lwh8762@gmail.com"
}

RunTask "SetupPackages" {
    git clone https://github.com/lewohy/packages.git $home/packages

    RunTask "SetupWinget" {
        winget settings --enable InstallerHashOverride
        winget import -i "C:\Users\lewohy\packages\winget.json" --accept-package-agreements --accept-source-agreements
    }

    RunTask "SetupScoop" {
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        scoop import "C:\Users\lewohy\packages\scoop.json"
    }
}


RunTask "SetupKeyboard" {
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name InitialKeyboardIndicators -Value 2
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name KeyboardDelay -Value 0
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name KeyboardSpeed -Value 31
}

RunTask "SetTimeFormat" {
    Start-Process powershell -Verb RunAs -ArgumentList "Add-WindowsCapability -Online -Name Language.Basic~~~ko-KR"
    Start-Process powershell -Verb RunAs -ArgumentList "Set-WinUILanguageOverride -Language 'ko-KR'"

    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sLongDate -Value "yyyy-MM-dd" -Type String
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortDate -Value "yyyy-MM-dd" -Type String
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortTime -Value "HH:mm" -Type String
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sTimeFormat -Value "HH:mm:ss" -Type String
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sYearMonth -Value "MMMM yyyy" -Type String
}

RunTask "SetTouchpad" {
    # three finger slide gesture를 휠 클릭으로 설정
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name ThreeFingerSlideEnabled -Value 1 -Type DWord
    # three finger tab gesture를 휠 클릭으로 설정
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name ThreeFingerTapEnabled -Value 4 -Type DWord
}

RunTask "SetupClipboard" {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name EnableClipboardHistory -Value 1 -Type DWord
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name CloudClipboardAutomaticUpload -Value 1 -Type DWord
}

RunTask "KMS Auto Activation" {
    Start-Process powershell -Verb RunAs -ArgumentList "slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX"
    Start-Process powershell -Verb RunAs -ArgumentList "slmgr /skms kms.digiboy.ir"
    Start-Process powershell -Verb RunAs -ArgumentList "slmgr /ato"
}
