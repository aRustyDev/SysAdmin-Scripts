### GLOBAL Variables (LOCAL ONLY) ###
  #Local File Path Variables
      $scriptList_path = $PSScriptRoot + "\script\"
      $serverList = Get-Content $PSScriptRoot\resources\Servers\prod_servers.txt
      $installPath = "C:\temp\"      #Install Location
  #Credentials for accessing the servers
      $aaiscloudCred = Get-Credential -Credential Domain\Account
###############################################################################

$scriptDict = @()
foreach($item in Get-ChildItem -Path $PSScriptRoot\scripts\* -Include *.ps1 -File -Recurse -ErrorAction SilentlyContinue){
    $scriptDict += $item.name
}
$doneChoosingScripts = $false

#Choose from the Options List, add to the Scripts to Move list
    while(!$doneChoosingScripts){
      clear-Variable $option,$y,$scriptChoice,$addAnother,$targetList
      $ct, $ar  = 0, @()

#Message to the User
    clear-host
    write-host "Script Source: " + $PSScriptRoot + "\scripts\"

#Dynamically Built Menu
    clear-host
    write-host "- - - Choose a script to run - - -"
    Foreach ($option in $scriptDict){
        $ct        += 1
        $ar        += $ct
        write-host "`t$ct) $option"
    }
    $scriptChoice = read-host "`nOption: "

#User Defined Option Verification
    foreach ($script_key in $ar){#check if given key is valid
        if ($scriptChoice -eq $script_key){#map key to value, set path to script w/ value
            $script_val = $scriptDict[$script_key-1]
            $script_path = $PSScriptRoot + "\scripts\$script_val"
            $doneChoosingScripts = $true
            #Output Value to a CSV
            $script_val | out-file -filepath $PSScriptRoot\resources\scriptList_toMove.csv -append
            break
        }
    }
    if (!$doneChoosingScripts){#if key is not valid
        Write-Host "`n`tI cannot do that Dave...`n"
        pause
    }

#Clear the Screen, & list the current scripts the user has selected.
#No method of removing target scripts from cart. user would need to directly edit the CSV
#User given option to add another script. Default set to NO.
    clear-host
    $targetList = get-content $PSScriptRoot\resources\scriptList_toMove.csv
    $ct = 1
    write-host "- - - Selected Scripts - - -"
    Foreach ($script in $targetList){
        write-host "`t$ct) $script"
        $ct += 1
    }
    $addAnother = read-host "Add Another Script? : (y/n) : "
    if($addAnother.toupper() -eq 'Y'){
        $doneChoosingScripts = $false
    }
  }
  clear-host

      $I = 0
  #Splat Variables, for Write-Progress
      $outerParams = @{
        Activity = "updating"
        Status = "Current Server: $server"
        PercentComplete = (($I/$serverList.count)*100)
      }
  #Begin looping through the process
      foreach ($server in $serverList){
          Write-Progress -Activity "Installing Scripts" @outerParams -CurrentOperation "Testing Connection "
          #See if Target server is responsive
              if(Test-Connection -ComputerName $server -Quiet){

              #Declare PSSession Variable, need to manually enter PW
                  Write-Progress -Activity "Installing Scripts" @outerParams -CurrentOperation "Testing Connection => Est. PSSession"
                  $s = New-PSSession -ComputerName $server -Credential $aaiscloudCred
                  start-sleep -s .5

              #Verify & Edit FilePaths
                  Write-Progress -Activity "Installing Scripts" @outerParams -CurrentOperation "Testing Connection => Est. PSSession => Verify DestPath"
                  Invoke-Command -Session $s -ScriptBlock {

                  #PSSession Variables
                      $server = HostName
                      $installPath = "C:\temp\"      #Install Location

                      start-sleep -s .5

                      try{
                        $ErrorActionPreference = "SilentlyContinue"
                        New-Item -Path $installPath -ItemType Directory
                      }catch{
                        #write-host $_.exception.message -foregroundcolor "Green"
                      }Finally{
                        write-host "Path verified - $server"
                      }
                    }

              #Copy neccessary Scripts to the target server, & Write-Progress while doing so
                  $J = 0
                  Foreach ($script in $targetList){
                      write-progress -id 1 -Activity "Copying Target Scripts to \\$server\C:\temp\" -Status "Current Server: $server" -PercentComplete (($J/$serverList.count)*100) -CurrentOperation $currentOperation_inner
                      $localSourcePath = $PSScriptRoot + "\scripts\" + $script
                      $DestPath = $installPath + $script
                      Copy-Item $localSourcePath -Destination $DestPath -ToSession $s
                      $J += 1
                  }write-progress -id 1 -Activity "Copying Target Scripts to \\$server\C:\temp\" -Status "Completed" -Completed

              #Re-Enter PSSession, Run Scripts Locally, & then Delete them.
                  Write-Progress -Activity "Installing Scripts" @outerParams -CurrentOperation "Testing Connection => Est. PSSession => Verify DestPath => robocopy Files => Run Scripts"
                  Invoke-Command -Session $s -ScriptBlock {
                      Foreach ($script in get-ChildItem $installPath){ #Run Every Script in ScriptList
                          cd $installPath
                          & .\$script
                      }
                      start-sleep -s 5
                      Remove-Item -Path $installPath -Recurse #Clear the C:\Temp Folder
                      Write-host "Session Completed - $server"
                  }
                  Write-Progress -Activity "Installing Scripts" @outerParams -CurrentOperation "Testing Connection => Est. PSSession => Verify DestPath => robocopy Files => Run Scripts => Exit & Remove PSSession"
                  start-sleep -s .5
                  Exit-PSSession $s
                  Remove-PSSession $s
            }
            else{
                write-host "- - - - - "
                write-host "The Target Server $server was not reachable"
                write-host "This may be due to a policy setting or a naming error, or the server is down"
                write-host "- - - - - "
            }
            $I += 1
      }
  remove-item -Path $PSScriptRoot\resources\scriptList_toMove.csv
