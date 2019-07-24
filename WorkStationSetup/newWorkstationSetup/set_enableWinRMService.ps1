########################################################################################################################
# Enable Windows Remote Management Service
Write-Host "`nEnabling Windows Remote Management Service..." -F White -NoNewLine
$WinRM = Get-Service WinRM | Select-Object Name,Status,StartType
If ($WinRM.StartType -NotMatch "Automatic") {
	Try {
		Set-Service WinRM -StartupType Automatic
		Start-Service WinRM
	} Catch {
		Write-Host " (Failed)" -F Red
	} Finally {
		If (Test-WSMan) {
			Write-Host " (Done)" -F Green
		} Else {
			Write-Host " (Failed)" -F Red
		}
	}
} Else {
	If (Test-WSMan) {
		Write-Host " (Skipped, already enabled)" -F Gray
	} Else {
		Write-Host " (Failed)" -F Red
	}
}