param (
    [string]$HostFolder
)

xml ed -u "/Configuration/MappedFolders/MappedFolder/HostFolder" -v $HostFolder .\sandbox\sandbox-template.wsb | Out-File .\sandbox\sandbox.wsb
