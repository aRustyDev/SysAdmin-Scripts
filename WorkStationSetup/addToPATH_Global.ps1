#Get PATH Variables, @ the Global Level, shove into an "Old Variable" so we can append it.
$oldPATH = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
$newPATH = "$oldpath;c:\path\to\folder"
#May want to add in a admin sign-off/checkpoint to ensure the PATH Var is correct
#Try -- ($env:path).split(";")
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath


#Easy way to read the PATH Variables
#($env:path).split(";")
