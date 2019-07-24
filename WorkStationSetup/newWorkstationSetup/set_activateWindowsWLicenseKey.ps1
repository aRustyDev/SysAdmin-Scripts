########################################################################################################################
# Activate Windows with Enterprise License Key
# Dependecies: $LocalHost
Write-Host "`nActivating Windows with Enterprise License Key..." -F White -NoNewLine
Try {
	$LicenseKey = "JPHNB-HTRC9-4TRT4-3H68C-76DF4"
	$Service = get-wmiObject -query "select * from SoftwareLicensingService" -ComputerName $LocalHost
	$Service.InstallProductKey($LicenseKey) | Out-Null
	$Service.RefreshLicenseStatus() | Out-Null
} Catch {
	Write-Host " (Failed)" -F Red
} Finally {
	Write-Host " (Done)" -F Green
}
