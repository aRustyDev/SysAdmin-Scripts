########################################################################################################################
# Originated from Ben Leppke's NewWorkstationSetup_noAppX.ps1 Script
# Modified to be called as 'Function' style scripts.
# Dependecies: $DriveLetter
########################################################################################################################
# Copy Tools folder to C:\ Drive
$ToolsPath = $DriveLetter + ":\Tools"
If ($DriveLetter -NotMatch "C") {
	If (Test-Path $ToolsPath) {
		Write-Host "`nUpdating C:\Tools with a copy from $ToolsPath..." -F White -NoNewLine
		If (!(Test-Path C:\Tools)) {
			New-Item -Path C:\Tools -ItemType Directory | Out-Null
		}
		Try {
			Copy-Item $ToolsPath "C:\" -Recurse -Force | Out-Null
		} Catch {
			Write-Host " (Failed)" -F Red
		} Finally {
			Write-Host " (Done)" -F Green
		}
	}
}

########################################################################################################################
# Add C:\Tools to PATH variable
Write-Host "`nAdding C:\Tools & C:\Scripts to PATH variable..." -F White -NoNewLine
$PathVar = $Env:Path
If ($PathVar -Match 'C:\\Tools;C:\\Scripts') {
	Write-Host " (Skipped, Already Set)" -F Gray
} ElseIf (($PathVar.SubString($PathVar.Length -1)) -Eq ';') {
	# If PATH ends with a semicolon, don't add another
	$Env:Path += "C:\Tools;C:\Scripts;"
	Write-Host " (Done)" -F Green
} Else {
	$Env:Path += "C:\Tools;C:\Scripts;"
	Write-Host " (Done)" -F Green
}

#	: 	Alternative Method - PowerShell Script - Will save Tools to PATH as Global Var not Session Var
#	:	_______________________________
#	:	#Get PATH Variables, @ the Global Level, shove into an "Old Variable" so we can append it.
#	:	$oldPATH = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
#	:	$newPATH = "$oldpath;C:\Tools\"
#	:	#May want to add in a admin sign-off/checkpoint to ensure the PATH Var is correct
#	:	Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
