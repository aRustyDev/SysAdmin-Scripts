New-ADOrganizationalUnit -Name "KC" -Path "DC=MyDomain,DC=AD"
    New-ADOrganizationalUnit -Name "Users" -Path "OU=KC,DC=MyDomain,DC=AD"
    New-ADOrganizationalUnit -Name "Groups" -Path "OU=KC,DC=MyDomain,DC=AD"
    New-ADOrganizationalUnit -Name "Devices" -Path "OU=KC,DC=MyDomain,DC=AD"
        New-ADOrganizationalUnit -Name "Laptops" -Path "OU=Devices,OU=KC,DC=MyDomain,DC=AD"
        New-ADOrganizationalUnit -Name "Servers" -Path "OU=Devices,OU=KC,DC=MyDomain,DC=AD"
        New-ADOrganizationalUnit -Name "Workstations" -Path "OU=Devices,OU=KC,DC=MyDomain,DC=AD"

New-ADOrganizationalUnit -Name "LA" -Path "DC=MyDomain,DC=AD"
    New-ADOrganizationalUnit -Name "Users" -Path "OU=LA,DC=MyDomain,DC=AD"
    New-ADOrganizationalUnit -Name "Groups" -Path "OU=LA,DC=MyDomain,DC=AD"
    New-ADOrganizationalUnit -Name "Devices" -Path "OU=LA,DC=MyDomain,DC=AD"
        New-ADOrganizationalUnit -Name "Laptops" -Path "OU=Devices,OU=LA,DC=MyDomain,DC=AD"
        New-ADOrganizationalUnit -Name "Servers" -Path "OU=Devices,OU=LA,DC=MyDomain,DC=AD"
        New-ADOrganizationalUnit -Name "Workstations" -Path "OU=Devices,OU=LA,DC=MyDomain,DC=AD"

New-ADGroup
    -Name "LAUsers"
    -GroupCategory Security
    -GroupScope Global
    -DisplayName "LA Users"
    -Path "OU=Groups,OU=LA,DC=MyDomain,DC=AD"
    -Description "Members of this group have Global access to Cr@zyC0ff33 LA"

New-ADGroup
    -Name "LAShared-RW-Global"
    -GroupCategory Security
    -GroupScope Global
    -DisplayName "LA Share-RW"
    -Path "OU=Groups,OU=LA,DC=MyDomain,DC=AD"
    -Description "Members of this group have Global Read/Write access permissions to Cr@zyC0ff33 LA Shares"
        -
New-ADGroup
    -Name "LAShared-RO-Global"
    -GroupCategory Security
    -GroupScope Global
    -DisplayName "LA Share-RO"
    -Path "OU=Groups,OU=LA,DC=MyDomain,DC=AD"
    -Description "Members of this group have Global Read-Only access permissions to Cr@zyC0ff33 LA Shares"

New-ADGroup
    -Name "KCUsers"
    -GroupCategory Security
    -GroupScope Global
    -DisplayName "KC Users"
    -Path "OU=Groups,OU=KC,DC=MyDomain,DC=AD"
    -Description "Members of this group have Global access to Cr@zyC0ff33 KC"

New-ADGroup
    -Name "KCShared-RW-Global"
    -GroupCategory Security
    -GroupScope Global
    -DisplayName "KC Share-RW"
    -Path "OU=Groups,OU=KC,DC=MyDomain,DC=AD"
    -Description "Members of this group have Global Read/Write access permissions to Cr@zyC0ff33 KC Shares"

New-ADGroup
    -Name "KCShared-RO-Global"
    -GroupCategory Security
    -GroupScope Global
    -DisplayName "KC Share-RO"
    -Path "OU=Groups,OU=KC,DC=MyDomain,DC=AD"
    -Description "Members of this group have Global Read/Write access permissions to Cr@zyC0ff33 KC Shares"

New-ADGroup
    -Name "LAShared-RW-Local"
    -GroupCategory Security
    -GroupScope DomainLocal
    -DisplayName "LA Local Share-RW"
    -Path "OU=Groups,OU=LA,DC=MyDomain,DC=AD"
    -Description "Members of this group have Domain Local Read/Write access permissions to Cr@zyC0ff33 LA Shares"

New-ADGroup
    -Name "LAShared-RO-Local"
    -GroupCategory Security
    -GroupScope DomainLocal
    -DisplayName "LA Local Share-RO"
    -Path "OU=Groups,OU=LA,DC=MyDomain,DC=AD"
    -Description "Members of this group have Domain Local Read-Only access permissions to Cr@zyC0ff33 LA Shares"

New-ADGroup
    -Name "KCShared-RW-Local"
    -GroupCategory Security
    -GroupScope DomainLocal
    -DisplayName "KC Local Share-RW"
    -Path "OU=Groups,OU=KC,DC=MyDomain,DC=AD"
    -Description "Members of this group have Domain Local Read/Write access permissions to Cr@zyC0ff33 KC Shares"

New-ADGroup
    -Name "KCShared-RO-Local"
    -GroupCategory Security
    -GroupScope DomainLocal
    -DisplayName "KC Local Share-RO"
    -Path "OU=Groups,OU=KC,DC=MyDomain,DC=AD"
    -Description "Members of this group have Domain Local Read-Only access permissions to Cr@zyC0ff33 KC Shares"

#Directory Creation in C:\ Drive
    md c:\Data
    md c:\Data\KCShare
    md c:\Data\LAShare

#LAUsers -> LA-LocalRW & KC-LocalRO
    Add-ADGroupMember -Members "CN=LAUsers,OU=Groups,OU=LA,DC=MyDomain,DC=AD" -Identity "CN=LAShared-RW-Local,OU=Groups,OU=LA,DC=MyDomain,DC=AD"
    Add-ADGroupMember -Members "CN=LAUsers,OU=Groups,OU=LA,DC=MyDomain,DC=AD" -Identity "CN=KCShared-RO-Local,OU=Groups,OU=KC,DC=MyDomain,DC=AD"

#KCUsers -> KC-LocalRW & LA-LocalRO
    Add-ADGroupMember -Members "CN=KCUsers,OU=Groups,OU=KC,DC=MyDomain,DC=AD" -Identity "CN=KCShared-RW-Local,OU=Groups,OU=KC,DC=MyDomain,DC=AD"
    Add-ADGroupMember -Members "CN=KCUsers,OU=Groups,OU=KC,DC=MyDomain,DC=AD" -Identity "CN=LAShared-RO-Local,OU=Groups,OU=LA,DC=MyDomain,DC=AD"

#User AD Acct Creation Script
    foreach ($User in $UserList){

        $UserToAdd = Get-ADUser ("CN=" + $User.First + " " + $User.Last + ",OU=" + $User.OU1 + ",OU=" + $User.OU2 + ",DC=" + $User.DC1 + ",DC=" + $User.DC2 )

        if($User.OU2 == KC){
            $DestGroup = Get-ADGroup ("CN=KCUsers,OU=Groups,OU=KC,DC=MyDomain,DC=AD")
        }
        else{
            $DestGroup = Get-ADGroup ("CN=LAUsers,OU=Groups,OU=LA,DC=MyDomain,DC=AD")
        }



        $Params = @{

            AccountExpirationDate = (Get-Date).AddYears(1)
            AccountPassword = $User.Password
            ChangePasswordAtLogon = $true
            City = $User.City
            Company = "Cr@zyC0ff33 " + $User.OU2
            Country = "United States"
            Department = $User.Dept
            DisplayName = $User.Last + " " + $User.First
            EmailAddress = $User.First + "." + $User.Last + "@" + $User.DC1 + "." + $User.DC2
            EmployeeID = $User.Last + "." + $User.First
            EmployeeNumber = $User.EmployNum
            Enabled = $true
            GivenName = $User.First
            LogonWorkstations = $User.WS
            Manager = $User.Manager
            Name = $User.First + " " + $User.Last
            OfficePhone = $User.Phone
            Organization = "Cr@zyC0ff33"
            Path = "OU=" + $User.OU1 + ",OU=" + $User.OU2 + ",DC=" + $User.DC1 + ",DC=" + $User.DC2
            PostalCode = $User.Zip
            State = $User.State
            Surname = $User.Last
            UserPrincipalName = $User.First + "." + $User.Last + "@MyDomain.AD"

            } #End of Params

        New-ADUser @Params

        Add-ADGroupMember $DestGroup -Members $UserToAdd

    }
