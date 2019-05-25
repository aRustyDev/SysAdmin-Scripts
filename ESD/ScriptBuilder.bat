c:\

 

::Get Analyst Name as Str Var

whoami > tmpfile.txt

set /p tmpfile=<tmpfile.txt

echo %tmpfile:~7% > tmpfile.txt

set /p Analyst=<tmpfile.txt

del tmpfile.txt

 

cd C:\Users\%Analyst%\Desktop\

 

PowerShell.exe -ExecutionPolicy Bypass -File "Get_CI_Info__WorkingCopy.ps1"
