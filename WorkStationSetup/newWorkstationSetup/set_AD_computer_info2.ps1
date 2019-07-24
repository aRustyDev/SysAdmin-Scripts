########################################################################################################################
# Adam Smith's - Snippet Script for moving an ADComputer to the correct domain and updating its AD Info.
# Dependecies: $astraAdmin
########################################################################################################################

$ComputerName = (Get-CimInstance -ClassName Win32_ComputerSystem).name
$ComputerNameGUID = (Get-ADComputer -Identity $ComputerName -credential $astraAdmin).ObjectGUID #Note: Returns an AD-Obj Param

#Move the Computer to the correct OU Path
Move-ADObject -Identity $ComputerNameGUID -TargetPath "OU=Workstations,OU=Computers,OU=Ad Astra,DC=aais,DC=com" -credential $astraAdmin

#Update Computers AD Record with Description
	$ComputerModel = (Get-CimInstance -ClassName Win32_ComputerSystem).model
	$Manufacturer = ((Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer).split(" ")[0]
	write-host "*** New User *** "
	$fname = read-host -prompt "First Name: "
	$lname = read-host -prompt "First Name: "
	$newUser = $fname + " " + $lname

	#use loop to ensure $newUser is correct
	do{
		$correct = $true
		$ans = read-host "is '${$newUser}' correct? (y/n)"
		if($ans.toupper() -eq 'N'){
			clear-host
			$correct = $false
			write-host "*** New User *** "
			$fname = read-host -prompt "First Name: "
			$lname = read-host -prompt "First Name: "
			$newUser = $fname + " " + $lname
		}
	}while($correct = $false)
	$descriptionStr = $Manufacturer + " " + $ComputerModel + " - " + $newUser
	Set-ADComputer $ComputerName -Description $descriptionStr -credential $astraAdmin
