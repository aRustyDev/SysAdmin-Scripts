########################################################################################################################
# Connect to AstraSecure Wireless
# Dependecies: $ScriptPath
Write-Host "`nConnecting to AstraSecure Wireless..." -F White -NoNewLine
# The Below line will re-create the XML file needed to configure the connection
# netsh wlan export profile name="AstraSecure" folder="C:\" key=clear
$WiFiConfigPath = $ScriptPath + "Wi-Fi-AstraSecure.xml"
If (Get-NetAdapter | Where-Object PhysicalMediaType -eq 'Native 802.11') {
	If (Test-Path $WiFiConfigPath) {
		Try {
			netsh wlan add profile filename=$WiFiConfigPath | Out-Null
		} Catch {
			Write-Host " (Failed)" -F Red
		} Finally {
			Write-Host " (Done)" -F Green
		}
	} Else {
$WifiConfigData = @'
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
	<name>AstraSecure</name>
	<SSIDConfig>
		<SSID>
			<hex>4173747261536563757265</hex>
			<name>AstraSecure</name>
		</SSID>
	</SSIDConfig>
	<connectionType>ESS</connectionType>
	<connectionMode>auto</connectionMode>
	<MSM>
		<security>
			<authEncryption>
				<authentication>WPA2PSK</authentication>
				<encryption>AES</encryption>
				<useOneX>false</useOneX>
			</authEncryption>
			<sharedKey>
				<keyType>passPhrase</keyType>
				<protected>false</protected>
				<keyMaterial>1$MczgH4</keyMaterial>
			</sharedKey>
		</security>
	</MSM>
	<MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">
		<enableRandomization>false</enableRandomization>
		<randomizationSeed>3919189925</randomizationSeed>
	</MacRandomization>
</WLANProfile>
'@
$WiFiConfigData | Out-File $WiFiConfigPath
		Try {
			netsh wlan add profile filename=$WiFiConfigPath | Out-Null
		} Catch {
			Write-Host " (Failed)" -F Red
		} Finally {
			Write-Host " (Done)" -F Green
		}

	}
} Else {
	Write-Host " (Skipped, No Wireless NIC detected)" -F Gray
}
