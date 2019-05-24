# Machine Enumeration
#*****************************************************

### SET FILEPATHS ###

    $Analyst 	 = ((Get-WmiObject -Class:Win32_ComputerSystem).UserName).split('\')[1]
	
    $DeskPath 	 = "C:\Users\$($Analyst)\Desktop"
        if(-not (test-path -Path $TestPath1)){
			new-item -Path "$($DeskPath)\PS_Output" -itemType "directory"
		}
		
    $FilePath 	 = "$($DeskPath)\PS_Output"
	
    $CI_FilePath = "$($FilePath)\CI_Ticket_Info.txt"
        if(-not (test-path -Path $TestPath1)){
			new-item -Path "$($FilePath)\Logs" -itemType "directory"
		}
		
    $LogFilePath = "$($FilePath)\Logs"
	
	
### Get Current Users Information ###
	$EU_UserName = (Get-WmiObject -ComputerName $Machine -Class:Win32_ComputerSystem).UserName
	$EU_alias 	 = $EU_UserName.split('\')[1]
	
	
### Get Local Machine Information ###
	$PC_Serial 	= (Get-WmiObject -ComputerName $Machine -Class:Win32_bios).SerialNumber

    $PC_Model 	= (Get-WmiObject -ComputerName $Machine -Class:Win32_ComputerSystem).Model

    $OS_Version = (Get-WmiObject -ComputerName $Machine Win32_OperatingSystem).Version

    $Network 	= Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $Machine -EA Stop | ? {$_.IPEnabled}
        $IPAddress  	= $Network.IpAddress[0]
        $SubnetMask 	= $Network.IPSubnet[0]
        $DefaultGateway = $Network.DefaultIPGateway
        $DNSServers  	= $Network.DNSServerSearchOrder
        $DNSDomain   	= $Network.DNSDomain
		
	$Redstone = $OS_Version.split('.')[2]
        if($Redstone -eq  '16299'){ $OS_Build = "RedStone 1709" }
        elseif($Redstone -eq  '15063'){ $OS_Build = "RedStone 1703" }
        elseif($Redstone -eq  '14393'){ $OS_Build = "RedStone 1607" }
        elseif($Redstone -eq  '10586'){ $OS_Build = "RedStone 1511" }

### Get Software Information ###
	Get-WmiObject -Class Win32_Product -Computer $Machine |

    Select-Object Name, Version |

    Where-Object -FilterScript {
        $_.Name -like "*Java*" -or
        $_.Name -like "*Outlook*" -or
        $_.Name -like "Citrix*" -or
        $_.Name -like "Adobe*" -or
        $_.Name -like "Intel(R)*" -or
        $_.Name -like "Tanium*" -or
        $_.Name -like "Swift*" -or
        $_.Name -like "ActivID*"} |

    Sort-Object -Property Name, Version |

    Format-Table -Property Name, Version |

    Out-File -Append -Encoding "UTF8" -FilePath $CI_FilePath -Width 80
				
				
				
				
				
				
				
				
				
				
