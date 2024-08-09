Write-Host "Installing Windows Package Manager (winget)..." -ForegroundColor Green
$progressPreference = 'silentlyContinue'
Add-AppxPackage C:\Users\WDAGUtilityAccount\Desktop\windows-setup\sandbox\Apps\Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage C:\Users\WDAGUtilityAccount\Desktop\windows-setup\sandbox\Apps\Microsoft.UI.Xaml.2.8.x64.appx
Add-AppxPackage C:\Users\WDAGUtilityAccount\Desktop\windows-setup\sandbox\Apps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
