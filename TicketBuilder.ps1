#NOTES:

#Program Runs in two Loops

#             1) The Outer loop - Keeps the program running until you enter 'Exit'

#             2) The Check for Ticket Complete Loop

#                             * If you hit 'y' the current loop will complete

#                               which will then automatically clear the content

#                               created Ticket.

 

### SET FILEPATHS ###

                $Analyst = ((Get-WmiObject -Class:Win32_ComputerSystem).UserName).split('\')[1]

                $DeskPath = "C:\Users\$($Analyst)\Desktop"

                if(-not (test-path -Path $TestPath1)){new-item -Path "$($DeskPath)\PS_Output" -itemType "directory"}

                $FilePath = "$($DeskPath)\PS_Output"

                $CI_FilePath = "$($FilePath)\CI_Ticket_Info.txt"

                if(-not (test-path -Path $TestPath1)){new-item -Path "$($FilePath)\Logs" -itemType "directory"}

                $LogFilePath = "$($FilePath)\Logs"

 

### START OF PROGRAM ###

                $Infinite_Loop = $true

                while($Infinite_Loop -eq $true){

 

### CLEAR VARIABLES AS PRECAUTION ###

                $EU_Name = ""

                $PC_Serial = ""

                $PC_Model = ""

                $OS_Build = ""

                $OS_Version = ""

                $IPAddress  = ""

                $SubnetMask  = ""

                $DefaultGateway = ""

                $DNSServers  = ""

 

### CLEAR CONSOLE WINDOW ###

                [System.Console]::Clear()

 

echo "*****************************************************"

echo "*** ENSURE POWERSHELL IS RUNNING AS ADMINISTRATOR *** "

echo "*****************************************************"

echo "*****************************************************"

echo "*** SCRIPT DOESNT WORK IF MACHINE ISNT ON NETWORK *** "

echo "*****************************************************"

 

### INPUT SECTION ###

### START INPUT LOOP ###

                do{#Check Machine Name

                               

                                $CN_loop = $true

                                $Machine = Read-Host -Prompt 'CN'

                                try{

                                                Get-ADComputer -identity $Machine | out-null

                                }catch{

                                                [System.Console]::Clear()

                                                $CN_loop = $false

                                                echo "*****************************************************"

                                                echo "*** ENSURE POWERSHELL IS RUNNING AS ADMINISTRATOR *** "

                                                echo "*****************************************************"

                                                write-host "************* " -NoNewLine

                                                write-host "ERROR: CN NAME NOT FOUND " -ForegroundColor Red -NoNewLine

                                                write-host "************** "

                                                echo "*****************************************************"

                                }

                }while($CN_loop -eq $false)

 

### CLEAR CURRENT FILE CONTENTS ###

                Clear-Content -Path $CI_FilePath

 

### VARIABLES SECTION ###

                $EU_UserName = (Get-WmiObject -ComputerName $Machine -Class:Win32_ComputerSystem).UserName

                $EU_alias = $EU_UserName.split('\')[1]

                $EU_OU = ((get-aduser -identity $EU_alias).DistinguishedName).split(',')[1..4]

                $EU_DC = ((get-aduser -identity $EU_alias).DistinguishedName).split(',')[5..7]

                $EU_edipi = ((get-aduser -identity $EU_alias).UserPrincipalName).split('@')[0]

                $EU_FName = (get-aduser -identity $EU_alias).GivenName

                $EU_LName = (get-aduser -identity $EU_alias).Surname

                $EU_Name = "$($EU_FName ) $($EU_LName)"

                $PC_Serial = (Get-WmiObject -ComputerName $Machine -Class:Win32_bios).SerialNumber

                $PC_Model = (Get-WmiObject -ComputerName $Machine -Class:Win32_ComputerSystem).Model

                $OS_Version = (Get-WmiObject -ComputerName $Machine Win32_OperatingSystem).Version

                $Network = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $Machine -EA Stop | ? {$_.IPEnabled}

                                $IPAddress  = $Network.IpAddress[0]

                                $SubnetMask  = $Network.IPSubnet[0]

                                $DefaultGateway = $Network.DefaultIPGateway

                                $DNSServers  = $Network.DNSServerSearchOrder

                                $DNSDomain   =  $Network.DNSDomain

                $User = $EU_UserName.split('\')[1]

                $ExchStr = (get-aduser -identity $User -Properties msExchHomeServerName).msExchHomeServerName

                $HomeMDB = (get-aduser -identity $User -Properties homeMDB).homeMDB

                $Redstone = $OS_Version.split('.')[2]

                                if($Redstone -eq  '16299'){ $OS_Build = "RedStone 1709" }

                                elseif($Redstone -eq  '15063'){ $OS_Build = "RedStone 1703" }

                                elseif($Redstone -eq  '14393'){ $OS_Build = "RedStone 1607" }

                                elseif($Redstone -eq  '10586'){ $OS_Build = "RedStone 1511" }

 

### OUTPUT SECTION ###

                Add-Content $CI_FilePath " "

                Add-Content $CI_FilePath "Domain (MCEN-N/S/L):           N"

                Add-Content $CI_FilePath " "

                Add-Content $CI_FilePath "************* CUSTOMER DETAILS *************"

                Add-Content $CI_FilePath " "

                Add-Content $CI_FilePath "`tEU Name: `t$($EU_Name)"

                Add-Content $CI_FilePath "`tRank: `t`t"

                Add-Content $CI_FilePath "`tBase: `t`t"

                Add-Content $CI_FilePath "`tBLDG: `t`t"

                Add-Content $CI_FilePath "`tRoom: `t`t"

                Add-Content $CI_FilePath "`tMajor Cmd: `t"

                Add-Content $CI_FilePath "`tDept/Section: `t"

                Add-Content $CI_FilePath "`tPhone#: `t"

                Add-Content $CI_FilePath "`tEmail: `t`t"

                Add-Content $CI_FilePath " "

                Add-Content $CI_FilePath "`tContact Email: "

                Add-Content $CI_FilePath "`tContact Phone#: "

                Add-Content $CI_FilePath " "

                Add-Content $CI_FilePath "************* CI DETAILS *************"

                Add-Content $CI_FilePath "`n---Machine Details---"

                Add-Content $CI_FilePath "`tComputerName: `t$($Machine.ToUpper())"

                Add-Content $CI_FilePath "`n`tIPv4: `t`t$($IPAddress)"  

                Add-Content $CI_FilePath "`tSerial Number: `t$($PC_Serial)"

                Add-Content $CI_FilePath "`tAsset Tag: `t "

                Add-Content $CI_FilePath "`n`tDomain: `t$($DNSDomain)"

                Add-Content $CI_FilePath "`tPC Model: `t$($PC_Model)"

                Add-Content $CI_FilePath "`tOS Version: `tWIN$($OS_Version)"

                Add-Content $CI_FilePath "`tOS Build: `t$($OS_Build)"

                Add-Content $CI_FilePath "`tPort Number: `t "

                Add-Content $CI_FilePath "`n---Network Details---"

                Add-Content $CI_FilePath "`n`tIPv4: `t`t$($IPAddress)"

                Add-Content $CI_FilePath "`tSubnet Mask: `t$($SubnetMask)"

                Add-Content $CI_FilePath "`tDef Gateway: `t$($DefaultGateway)"

                $ct = 1

                foreach($DNSServer in $DNSServers){

                                Add-Content $CI_FilePath "`tDNS Server $($ct): `t$($DNSServer)"

                                $ct += 1}

 

                Add-Content $CI_FilePath "`n---EU AD Details---"

                Add-Content $CI_FilePath "`tUserName: `t$($EU_UserName)"

                Add-Content $CI_FilePath "`tOU: `t`t" -NoNewLine

                foreach($OU in $EU_OU){

                                Add-Content $CI_FilePath "\$($OU.split('=')[1])" -NoNewLine}

                Add-Content $CI_FilePath "`r`n`tDC: `t`t" -NoNewLine

                foreach($DC in $EU_DC){

                                Add-Content $CI_FilePath "\$($DC.split('=')[1])" -NoNewLine}

                Add-Content $CI_FilePath "`r`n`n---Exchange Details---"

                Add-Content $CI_FilePath "`tExch Server:`t$($ExchStr.split('=')[5])"

                Add-Content $CI_FilePath "`tMailBox DB:`t$($HomeMDB.split('=,')[1])"

                Add-Content $CI_FilePath "`tDisplay Name:`t$($User)"

 

echo "`n--- PING STATISTICS ---"

                ping $Machine /n 1

 

                Add-Content $CI_FilePath " "

                Add-Content $CI_FilePath " "

                Add-Content $CI_FilePath "************* SOFTWARE VERSION DETAILS *************"

 

### GET COMMON ISSUE SOFTWARE VERSIONING ###

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

 

                Add-Content $CI_FilePath "************Description of Problem*******************"

                Add-Content $CI_FilePath " "

                Add-Content $CI_FilePath " "

                Add-Content $CI_FilePath " "

                Add-Content $CI_FilePath "************Troubleshooting**************************"

                Add-Content $CI_FilePath " "

                Add-Content $CI_FilePath " "

                Add-Content $CI_FilePath " "

                Add-Content $CI_FilePath "************Additional Information*******************"

                Add-Content $CI_FilePath " "

                Add-Content $CI_FilePath " "

                Add-Content $CI_FilePath " "

 

### GET LOG FILES OFF EU MACHINE \ LOGS FOR THE PAST WEEK ###

 

echo "`n`n"

echo "****************************************************************"

echo "*** TICKET IS COMPLETE, IF YOU HIT 'Y' THE TICKET WILL CLEAR ***"

echo "****************************************************************"

 

### CHECK W/ USER TO START NEXT TICKET ###

                do{#Check w/ user if they would like to start a new file

                                $Ready = Read-Host -Prompt "`nWould You Like to Start the Next Ticket? y/n"

                                if($Ready.ToUpper() -eq 'Y'){

                                                $Ready_to_Proceed = $true

                                }elseif($Ready.ToUpper() -eq 'N'){

                                                $Ready_to_Proceed = $false

                                }elseif($Ready.ToUpper() -eq 'EXIT'){

                                                $Infinite_Loop = $false

                                }else{

                                                echo "`n*** ERROR: Invalid Input ***"

                                                $Ready_to_Proceed = $false

                                }

                }while($Ready_to_Proceed -eq $false)

 

}

### ^^ END OF WHILE LOOP ^^ ###
