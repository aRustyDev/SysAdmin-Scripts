########################################################################################################################
#Change Computer Name
#Dependecies: $assetTag, $astraAdmin, $DC_OU_Path, $domainName
########################################################################################################################
Rename-Computer -NewName $assetTag

########################################################################################################################
#Check if Computer Name is already in AD
########################################################################################################################
if(Get-ADComputer $assetTag){
  Remove-ADComputer -Identity $assetTag -credential $astraAdmin -Server "aais.com"
}
#if already present, Remove the Computer Name

########################################################################################################################
#Join Computer to the Domain
########################################################################################################################
Add-Computer -DomainName $domainName -OUPath $DC_OU_Path -credential $astraAdmin
