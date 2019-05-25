#Clear screen

CLS

 

#Function within function Defined - Search SCCM for user primary device

Function Get-PrimaryDevice 

 { 

   

   Get-WmiObject -ComputerName quan6911 -Namespace "root\SMS\Site_MC1" -Query "select * from SMS_UserMachineRelationship WHERE UniqueUserName like'%$User%' AND IsActive = '1' AND Types = '1'"

   Get-WmiObject -ComputerName cljn6911 -Namespace "root\SMS\Site_MC2" -Query "select * from SMS_UserMachineRelationship WHERE UniqueUserName like'%$User%' AND IsActive = '1' AND Types = '1'"

   Get-WmiObject -ComputerName pndl6911 -Namespace "root\SMS\Site_MC3" -Query "select * from SMS_UserMachineRelationship WHERE UniqueUserName like'%$User%' AND IsActive = '1' AND Types = '1'"

   Get-WmiObject -ComputerName fstr6911 -Namespace "root\SMS\Site_MC4" -Query "select * from SMS_UserMachineRelationship WHERE UniqueUserName like'%$User%' AND IsActive = '1' AND Types = '1'"

}

 

#Function 1 - Search for computers user has been active on.

Function FindComputerNames

{

Write-Host ""

Write-Host "------------------------------------------------------------------"

Write-Host "Search user's alias to find their computer name"

Write-Host "(First.Last + CTR if necessary)"

Write-Host ""

Write-Host "This will search SCCM for active devices for this user."

Write-Host "This will find every device the user has been on recently,"

Write-Host "and then narrow down results to the user's current workstation"

Write-Host ""

Write-Host "Brand new devices to the user will not be found!"

Write-Host "------------------------------------------------------------------"

Write-Host ""

 

$User = Read-Host -Prompt '*Search Username for Active Computers'

 

#Search for computers based on username

$ComputerNames = Get-PrimaryDevice $User | Select -expandProperty resourcename

 

#See current logged in users for each workstation

Write-Host "------------------------------------------------------------------"

Write-Host "----------------------List of Workstations------------------------"

Write-Host "------------------------------------------------------------------"

$CheckLoggedinUser = ForEach ($Comps in $Computernames) {

   $LoggedinUser = Invoke-Command -Computername $Comps -ScriptBlock { Get-WmiObject -Class win32_computersystem | select-object -expandProperty username }

   IF ($LoggedinUser -ne "MCDSUS\$User")

    {

    Write-Host ""

    Write-Host "------------------------------------------------------------------"

    Write-Host "CI Name: $Comps"

    Write-Host ""

    Write-Host "Logged in: $LoggedinUser"

    Write-Host ""

    Write-Host "Logged in user does not match searched user"

    Write-Host "Searched User has logged on here before, but is not currently"

    Write-Host "------------------------------------------------------------------"

    Write-Host ""

    }

       ELSE

    {

    Write-Host ""   

    Write-Host "******************************************************************"

    Write-Host -ForegroundColor Green "**CI Name: $Comps"

    Write-Host ""

    Write-Host -ForegroundColor Green "**Logged in: $LoggedinUser"

    Write-Host ""

    Write-Host -ForegroundColor Green "**Searched user currently logged in here**"

    $UserComp = $Comps 

    Write-Host "******************************************************************"

    Write-Host "" 

    }

}

#EndFunction FindComputerNames

}

 

#Function 2 - Prompt for searching Computer Info

Function ComputerInfo

{

 

$SearchComputer = Read-Host -Prompt '*Search Computer Name for Information'

Write-Host ""

 

#Device Information

$PC_Serial = (Get-WmiObject -ComputerName $SearchComputer -Class:Win32_bios).SerialNumber

$PC_Model = (Get-WmiObject -ComputerName $SearchComputer -Class:Win32_ComputerSystem).Model

$OS_Version = (Get-WmiObject -ComputerName $SearchComputer Win32_OperatingSystem).Version

$Network = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $SearchComputer -EA Stop | ? {$_.IPEnabled}

$IPAddress  = $Network.IpAddress[0]

$DefaultGateway = $Network.DefaultIPGateway

$DNSServers  = $Network.DNSServerSearchOrder

$LoggedInDC  = Invoke-Command -Computername $SearchComputer -ScriptBlock { Get-WMIObject Win32_NTDomain | select-object -ExpandProperty DomainControllerName }

Write-Host ""

Write-Host "------------------------------------------------------------------"

Write-Host "Serial Number: $PC_Serial"

Write-Host "Model: $PC_Model"

Write-Host "Windows OS Version: $OS_Version"

Write-Host "IP Address: $IPAddress"

Write-Host "Default Gateway: $DefaultGateway"

Write-Host "DNS Servers: $DNSServers"

Write-Host "Domain Controller Logged into: $LoggedInDC"

Write-Host "------------------------------------------------------------------"

Write-Host ""

 

#Get Installed software versions

Write-Host ""

Write-Host "------------------------------------------------------------------"

Write-Host "Installed Software and Versions on $SearchComputer" 

Get-WmiObject -Class Win32_Product -Computer $SearchComputer |

Select-Object Name, Version |

    Where-Object -FilterScript {

        $_.Name -like "*Java*" -or

        $_.Name -like "*Outlook*" -or

        $_.Name -like "Adobe*" -or

        $_.Name -like "Tanium*" -or

        $_.Name -like "Swift*" -or

        $_.Name -like "ActivID*"}

Write-Host "------------------------------------------------------------------"

Write-Host ""

 

#EndFunction ComputerInfo

}

 

 

 

 

#Function 3 - Account and Exchange information

Function AccountInfo

{

 

Write-Host "------------------------------------------------------------------"

Write-Host "*Search Username for Account information"

Write-Host "------------------------------------------------------------------"

$User = Read-Host -Prompt 'Enter User Alias'

Write-Host ""

 

$EU_edipi = ((get-aduser -identity $User).UserPrincipalName)

$EmailAdd = (get-aduser -identity $User -Properties Mail).Mail

$AccountStatus = ((get-aduser -identity $User).Enabled)

$Accountlock = (get-aduser -identity $User -Properties LockedOut).LockedOut

$AccountExpiration = (get-aduser -identity $User -Properties AccountExpirationDate).AccountExpirationDate

 

 

$HDriveFolder = (get-aduser -identity $User -Properties HomeDirectory).HomeDirectory

 

$ExchStr = (get-aduser -identity $User -Properties msExchHomeServerName).msExchHomeServerName

$HomeMDB = (get-aduser -identity $User -Properties homeMDB).homeMDB

$0365return = Get-ADuser -Identity $User -Properties  msExchRemoteRecipientType | Select-Object -expandproperty msExchRemoteRecipientType

 

 

if ($ExchStr -ne $null)

{ $EXCServerName = "`t$($ExchStr.split('=')[5])"}

else {}

if ($HomeMDB -ne $null)

{$EXCDBName = "`t$($HomeMDB.split('=,')[1])" }

else {}

 

Write-Host ""

Write-Host "------------------------------------------------------------------"

Write-Host "Account and Exchange Information"

Write-Host "------------------------------------------------------------------"

Write-Host ""

Write-Host "Username: $User"

Write-Host "Email: $EmailAdd"

Write-Host "EDIPI: $EU_edipi"

if ($AccountStatus -eq "True") {Write-Host "Account Enabled"} else {}

if ($AccountStatus -ne "true") {Write-Host -ForegroundColor Yellow "Account DISABLED"} else {}

if ($Accountlock -eq "True") {Write-Host -ForegroundColor Yellow "Account LOCKED"} else {}

if ($Accountlock -ne "true") {Write-Host "Account Unlocked"} else {}

Write-Host "Expires on: $AccountExpiration"

Write-Host ""

Write-Host "H: Drive Path: $HDriveFolder"

Write-Host ""

if ($EXCServerName -eq $null) {Write-Host "Exchange Server: Not Found"} else {Write-Host "Exchange Server: $EXCServerName"}

Write-Host ""

if ($EXCDBName -eq $null) {Write-Host "Exchange Database: Not found"} else {Write-Host "Exchange Database: $EXCServerName"}

Write-Host ""

If ($0365return -gt 3) { Write-Host -ForegroundColor Green "User is on an 0ffice 365 Mailbox." }  Else { Write-Host "Not on an Office 0365 Mailbox. " }

 

Write-Host "------------------------------------------------------------------"

Write-Host ""

#EndFunction AccountInfo

}

 

 

 

#Function - Menu options

function Show-Menu

{

    param (

        [string]$Title = 'Info Tools'

    )

    Write-Host "================ $Title ================"

    Write-Host ""  

    Write-Host "1: Press '1' Search SCCM for User primary workstations"

    Write-Host ""

    Write-Host "2: Press '2' Get Computer Information."

    Write-Host ""

    Write-Host "3: Press '3' Get User Account information"

    Write-Host ""

    Write-Host "4: Press '4' Clear the Screen"

    Write-Host ""

    Write-Host "Q: Press 'Q' to quit."

    Write-Host ""

}

 

do

{

     Show-Menu

     $selection = Read-Host "Please make a selection"

     switch ($selection)

     {

         '1' {

             FindComputerNames

         }

         '2' {

             ComputerInfo

         }

         '3' {

             AccountInfo

         }

         '4' {

             CLS

         }

         default

             {

             'No Menu Option selected.'

         }

     }

     pause

}

until ($selection -eq 'q')
