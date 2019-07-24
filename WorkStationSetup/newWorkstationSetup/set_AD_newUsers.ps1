
#Crawls the Excel Sheet -> CSV for the Target user.
& $psscriptroot\excelhandling.ps1

$group = read-host "which group does '$user' belong in? `n`t1)End Users`n`t2)Admins`n`t3)Super Users`n`t4)Test`n`nGroup:"

switch ($group)
{
	"2" {$DestGroup = "OU=Admins,OU=Users,OU=Ad Astra,DC=aais,DC=com"}
	"3" {$DestGroup = "OU=Super Users,OU=Users,OU=Ad Astra,DC=aais,DC=com"}
	"4" {$DestGroup = "OU=Test,OU=Users,OU=Ad Astra,DC=aais,DC=com"}
	Default {$DestGroup = "OU=End Users,OU=Users,OU=Ad Astra,DC=aais,DC=com"}
}

    $Params = @{
			#############################################
			#Get User Location/Company Info
			#############################################
			if($User.Contractor -or $User.Remote){
				City = $User.City
				Company = Office = physicalDeliveryOfficeName = $User.Company
				Country = $User.Country
				PostalCode = $User.Zipcode
				State = $User.State
				StreetAddress = $User.StreetAddr
				POBox = $User.POBox
			}else{
				City = "Overland Park"
				Company = "Ad Astra"
				Country = "United States"
				PostalCode = "66204"
				State = "Kansas"
				StreetAddress = "6900 W 80th St # 300"
			}
			#############################################
			AccountExpirationDate = (Get-Date).AddYears(1)
			AccountPassword = $User.TempPassword
			ChangePasswordAtLogon = Enabled = $true
			CN = Name = DisplayName = $User.FirstName + " " + $User.LastName
			Department = $User.Department
			Title = $User.Title
			#Description =
			GivenName = $User.FirstName
			Initials = $Initial
			Surname = $User.LastName
			SamAccountName = ($User.FirstName).split()[0] + $User.LastName
			EmailAddress = UserPrincipalName = $User.EmailAddress
			EmployeeID = EmployeeNumber = $User.Badge
			Manager = (Get-ADUser $User.Manager).distinguishedName
			MobilePhone = $User.CellPhone
			OfficePhone = telephoneNumber = $User.OfficePhone
			PasswordNeverExpires = PasswordNotRequired = $false

			if($User.title -eq "Intern"){
				AccountExpirationDate = (Get-Date).AddMonths(4)
			}
		} #End of Params

    New-ADUser @Params -credential $astraAdmin

    Add-ADGroupMember $DestGroup -Members $UserToAdd -credential $astraAdmin
