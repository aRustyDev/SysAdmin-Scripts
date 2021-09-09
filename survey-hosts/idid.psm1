function idid {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [Switch]$whatif,

        [Parameter(Mandatory=$false)]
        [Switch]$showconfigs,

        [Parameter(Mandatory=$false)]
        [string]$oplogdir,

        [Parameter(Mandatory=$false)]
        [validateSet("csv","txt"<#,"json"#>)] #JSON object handling still in testing
        [string[]]$logFormat="csv",

        [Parameter(Mandatory=$false)]
        [string]$hosts_csv
    )

    begin{
        $envirovars = @{ #These link the Function Params ex:( $env:VARNAME = "`$paramVar" )
            HOSTS_CSV = "`$hosts_csv"
            OPERATORLOG_DIR = "`$oplogdir"
        }
        foreach ($key in $envirovars.Keys){
            try{#IF $env:var not set AND param is not given THEN see if the user wants to set it
                # Key !Set && $null -> Prompt to set
                # Key Set && Not $null -> Update
                # Key !Set & Not $null -> Update
                # Key set && $null -> Proceed
                if((![System.Environment]::GetEnvironmentVariable($key)) -and ($null -eq (Invoke-Expression $envirovars.$key))){ 
                    throw varnotfound 
                }elseif($null -ne (Invoke-Expression $envirovars.$key)) { # If the $Param isnt $null
                    if([System.Environment]::GetEnvironmentVariable($key) -ne (Invoke-Expression $envirovars.$key)){ # Update $env:Var if Param doesnt match
                        [System.Environment]::SetEnvironmentVariable($var, (Invoke-Expression $envirovars.$key))
                    }
                }else { # Sets local param with $env:VARNAME
                    $envirovars.$key = [System.Environment]::GetEnvironmentVariable($key)
                }

            }catch [varnotfound]{
                $update = Read-Host -Prompt "`$env:$var not found : Do you want to set? (y/n)"
                if($update.ToLower() -eq "y"){# the user wants to 
                    $newvar = Read-Host -Prompt "`$env:$var="
                    [System.Environment]::SetEnvironmentVariable($var, $newvar)
                }else{
                    Write-Output "`$env:$var must be set to run '$($MyInvocation.MyCommand)'"
                    exit
                }
            }catch{
                Write-Host "Something broke in '$($MyInvocation.MyCommand)' 'Begin' block"
            }
        }
    }

    process{
        $targets = Import-Csv -Path $hosts_csv
        #$setup = @("","","","","")

        $i = 0
        $cmd, $subnet, $os = ""
        $issetup = $false

        foreach ($arg in $args) {
            $cmd += " " + $arg + " "
            if($arg -imatch "-subnet"){
                $subnet = $args[$i+1]
                $targets = $targets | Where-Object {$_.subnet -match $subnet}
                $i++
                continue
            }
            if($arg -imatch "-os"){
                $subnet = $args[$i+1]
                $targets = $targets | Where-Object {$_.os -match $os}
                $i++
                continue
            }
            if(($null -eq $paa) -and ($arg -notin @())){
                switch -Regex ($arg) {
                    "nmap" { $paa = "PAA1"; break }
                    "fping" { $paa = "PAA1"; break }
                    "nmap" { $paa = "PAA1"; break }
                    "nmap" { $paa = "PAA1"; break }
                    "nmap" { $paa = "PAA1"; break }
                    "nmap" { $paa = "PAA1"; break }
                    Default {$paa = ""; break}
                }
            }
            $i++
        }
    }

    end {
        if(!$whatif){
            
            # Write Header info for each commands output
            $out = "$(Get-Date -Format "yyyy-MM-dd @ HH:mm k") :: $($creds.Username) ran :: $cmd"
            $header = "$("~"*$out.Length)`n$out`n$("~"*$out.Length)`n|CMD Output|`n$("~"* "|CMD Output|".Length)" 

            $cmd_obj = New-Object -TypeName [PSCustomObject]@{
                dateran = if($out -match "\d\d\d\d-\d\d-\d\d"){ $Matches[0] }else{ $null }
                time    = if($out -match "\d\d:\d\d"){ $Matches[0] }else{ $null }
                user    = $creds.Username
                action  = $cmd
                paa     = $paa
                targets = $if($issetup){
                    "(localhost) $((Get-NetIPAddress -InterfaceAlias eth0).IPAddress)"
                }else {
                    "($subnet) $($targets.ip -join ",")"
                }
            }

            # Write to files
            Invoke-Expression $cmd | Tee-Object -OutVariable $cmd_output;
            foreach ($filetype in $logFormat) {
                switch ($filetype) {
                    "csv"  { 
                        $cmd_obj | Export-Csv -Append -Path "$oplogdir\opnotes.csv"
                        break
                    }
                    "txt"  { 
                        Out-File -InputObject $header -FilePath "$oplogdir\opnotes.txt" -Append;
                        Out-File -InputObject $cmd_output -FilePath "$oplogdir\opnotes.txt" -Append;
                        break
                    }
                    <#
                    "json" { # Still in testing
                        if(Test-Path -Path "$oplogdir\opnotes.json"){ #If the file exists, grab it, add to it, and write it back
                            $json_obj = Get-Content -Path "$oplogdir\opnotes.json" -Raw | ConvertFrom-Json
                            $json_obj += $cmd_obj
                            ConvertTo-Json -InputObject $json_obj -Compress | Out-File -FilePath "$oplogdir\opnotes.json" -Encoding ascii
                        }else{ # Otherwise, make a new file
                            ConvertTo-Json -InputObject $json_obj -Compress | Out-File -FilePath "$oplogdir\opnotes.json" -Encoding ascii
                        }
                        break
                    }
                    #>
                    Default {}
                }
            }            

            # Annotate action in Operator CSV
                 

        }else{ return $targets }
    }
}