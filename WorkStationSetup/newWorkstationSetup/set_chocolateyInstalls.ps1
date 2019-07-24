########################################################################################################################
# Install Chocolatey
# Dependecies: NONE
########################################################################################################################
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
# Remove Default Chocolatey Source
# choco source remove --name=chocolatey
# Add local AdAstra Chocolatey Repo
$astraCholocate = "http://softserv.aais.com/nuget/AdAstraChocolatey/"
choco source add --name=adastra --source=$astraCholocate

########################################################################################################################
#array of Astra Repo Names.
########################################################################################################################
$astraRepo = @(
  "7zip",
  "jre8",
  "googlechrome",
  "firefox",
  "office365proplus"
)

########################################################################################################################
# Install from AdAstra PkgMngr
########################################################################################################################
foreach($pkg in $astraRepo){
  choco install $pkg -y --source $astraCholocate
  sleep 5
}


########################################################################################################################
#Additional **USER** Pkgs
########################################################################################################################
#    notepadplusplus
#    gimp
#    vlc
#    flashplayeractivex
#    flashplayerplugin
#    adobereader
#    GET Typora (for Markdown Edittor/Reader)

########################################################################################################################
#Additional **ADMIN** Pkgs
########################################################################################################################
#    chocolatey
#    putty
#    putty
#    openssh
#    nmap
#    winpcap
#    python3 --pre
#    kubernetes-cli
#    minikube
