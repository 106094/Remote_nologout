
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force;

<#
#region general functions

function Test-Admin {
param([switch]$Elevated)
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process $PsHome\powershell.exe -Verb RunAs -ArgumentList ('-noprofile -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

#endregion
#>

#region setting remote control

Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -name "fDenyTSConnections" -value 0
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -name "fSingleSessionPerUser" -value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "Shadow" -Value 2 -Type "DWORD"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Wds\rdpwd\Tds\tcp" -Name "Shadow" -Value 2 -Type "DWORD"
# Get the Security Identifier (SID) for the current user
$currentUser = New-Object System.Security.Principal.NTAccount($env:USERDOMAIN, $env:USERNAME)
$currentUserSid = $currentUser.Translate([System.Security.Principal.SecurityIdentifier]).Value
$remoteControlSDDL = "O:BAG:BAD:(A;;0xf0007;;;$currentUserSid)"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Wds\rdpwd\Tds\tcp" -Name "SecurityDescriptor" -Value $remoteControlSDDL
gpupdate /force

Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -name "LimitBlankPasswordUse" -value 0

$remotegn="Remote Desktop"
$filesharing="File and Printer Sharing (SMB-In)"
$remoteshadow="Remote Desktop - Shadow (TCP-In)"
 if((Get-WinSystemLocale).name -match "jp"){
$remotegn="リモート デスクトップ"
$filesharing="ファイルとプリンターの共有 (SMB 受信)"
$remoteshadow="リモート デスクトップ - シャドウ (TCP 受信)"
 }

Enable-NetFirewallRule -DisplayGroup $remotegn
Enable-NetFirewallRule -DisplayName $filesharing
Enable-NetFirewallRule -DisplayName $remoteshadow

New-NetFirewallRule -DisplayName "Session Shadowing Ports" -Direction Inbound -Protocol TCP -LocalPort 139,445,49152-65535 -Action Allow

#endregion

<#
#region setting WinRM

$checkrm=(Get-Service -Name "*WinRM*" | select status).status
if($checkrm -ne "running"){
winrm qc -force
#Enable-PSRemoting -Force
Enable-PSRemoting -SkipNetworkProfileCheck -Force
}

Set-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)" -RemoteAddress Any
Enable-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)"

#endregion
#>