########################################################################################################################
# Ben Leppke's - AdAstra New Workstation Setup Script
########################################################################################################################
# Editted by Adam Smith - Can Create AD Object Now too
########################################################################################################################

$ScriptVersion = "2.0"
$ScriptName = "AdAstra New Workstation Setup Script"

########################################################################################################################

$ErrorActionPreference = "SilentlyContinue"
$LocalHost = Get-Content Env:\COMPUTERNAME
$Username = Get-Content Env:\USERNAME
$Date = Get-Date
$Timezone = [Regex]::Replace([System.TimeZoneInfo]::Local.StandardName, '([A-Z])\w+\s*', '$1')
$FriendlyDate = "$Date" + " $Timezone"
$FileNameDate = (($Date).tostring("yyyy-MM-dd_HH-mm"))
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$DriveLetter = $ScriptPath.Split(":\") | Select-Object -First 1

########################################################################################################################

write-host "Asking for Credentials to Access AD..."
sleep 5
$astraAdmin = Get-Credential
$PSHost = Get-Host
$PSWindow = $PSHost.ui.rawui
# Set BufferSize
$NewSize = $PSWindow.BufferSize
$NewSize.Height = 3000
$NewSize.Width = 120
$PSWindow.BufferSize = $NewSize
# Set WindowSize
$NewSize = $PSWindow.WindowSize
$NewSize.Height = 50
$NewSize.Width = 120
$PSWindow.WindowSize = $NewSize
# Set ForegroundColor
$NewColor = "Gray"
$PSWindow.ForegroundColor = $NewColor
# Set BackgroundColor
$NewColor = "Black"
$PSWindow.BackgroundColor = $NewColor
# Set WindowTitle
$NewTitle = "$ScriptName v$ScriptVersion"
$PSWindow.WindowTitle = $NewTitle
$verifyAssetTag = $true
while($verifyAssetTag -eq $true){
	$assetTag = read-host "Enter Asset Tag: "
	$testStr = read-host "is Asset Tag $assetTag, correct? (y/n): "
	If($testStr.toupper() -eq "Y"){
		$verifyAssetTag = $false
	}
}
Clear-Host
Clear-Host

########################################################################################################################

$LineBreak = '########################################################################################################################'

$ScriptHeader = @'
#################################
# Mini Workstation Setup Script #
#################################
'@
Write-Host "$LineBreak"
Write-Host "$LineBreak"
Write-Host $ScriptHeader -F Green
Write-Host "`nAD Credentials: " $astraAdmin.UserName -F Cyan
Write-Host "`nHostname: " $LocalHost -F Cyan
Write-Host "Script Path: " $ScriptPath -F Cyan
Write-Host "Script Version: " $ScriptVersion -F Cyan
Write-Host "Date/Time: " $FriendlyDate -F Cyan
Write-Host "Asset Tag: " $assetTag -F Cyan
Write-Host "`n$LineBreak"
Write-Host "$LineBreak"

Write-Host "`nVerifying Local Administrator rights..." -F White -NoNewLine
$wid=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$prp=new-object System.Security.Principal.WindowsPrincipal($wid)
$adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
$IsAdmin=$prp.IsInRole($adm)
If ($IsAdmin) {
	Write-Host " (Confirmed)" -F Green
} Else {
	Write-Host " (Failed)" -F Red
	Write-Host "`nRelaunch Powershell with Administrator rights!" -F Red
	Write-Host "Press any key to exit..."
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	Exit
}

########################################################################################################################
# Copy Tools folder to C:\ Drive
# Then add C:\Tools to PATH variable
# Dependecies: $DriveLetter

& $psscriptroot\set_cDashToolsInPATH.ps1

########################################################################################################################
# Connect to AstraSecure Wireless
# By re-creating the XML file needed to configure the connection
# netsh wlan export profile name="AstraSecure" folder="C:\" key=clear
# Dependecies: $ScriptPath

& $psscriptroot\set_connectToWifi.ps1

########################################################################################################################
# Activate Windows with Enterprise License Key
# Dependecies: $LocalHost

& $psscriptroot\set_activateWindowsWLicenseKey.ps1

########################################################################################################################
# Enable Windows Remote Management Service
# Dependecies:
& $psscriptroot\set_enableWinRMService.ps1

Write-Host "`nFinished with Stage 1..." -F Cyan
Write-Host "`nStarting Software Install..." -F White -NoNewLine
pause

# Install Chocolatey
# Dependecies: NONE
	# Removes Default Chocolatey Source
	# Add local AdAstra Chocolatey Repo
	# Install Programs From AdAstra Chocolatey Repo
& $psscriptroot\set_chocolateyInstalls.ps1

Write-Host "`nFinished with Stage 2..." -F Cyan
Write-Host "`nNew Workstation Setup Script is complete!" -F Green
Write-Host "`nFrom here the Script will attempt to conduct AD Ops..." -F Cyan
pause

########################################################################################################################
# Change Settings Locally for AD Integration
# Dependecies: $assetTag, $astraAdmin, $DC_OU_Path, $domainName

& $psscriptroot\set_AD_computer_info.ps1

########################################################################################################################
# Add Computer to the Domain
# Dependecies: $astraAdmin

& $psscriptroot\set_AD_computer_info2.ps1

########################################################################################################################
# Add User to AD
# Dependecies: $astraAdmin

& $psscriptroot\set_AD_newUsers.ps1

########################################################################################################################
# Change Settings Locally for Taskbar, Default Apps
# Dependecies:

& $psscriptroot\set_local_defaultSettings.ps1
