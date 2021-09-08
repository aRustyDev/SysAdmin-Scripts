function survey-processes {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter()]
        [string[]]
        $targets,

        # Parameter help description
        [Parameter()]
        [pscredential]
        $creds,

        # Parameter help description
        [Parameter()]
        [ValidateSet("2012R2","Win10","Win7","vista","XP")]
        [string[]]
        $os,

        # Parameter help description
        [Parameter()]
        [ValidateSet("Vault","Shield","Rep","C2")] # Need to find way to pull this from config File
        [string[]]
        $subnet
    )
    begin {
        if(!$creds){ $creds = Get-Credential}
    }
    process {
        Invoke-Command -ComputerName $targets -Credential $creds -ScriptBlock {
            Get-wmiobject win32_process | Select-Object Name, ProcessID, Path, Commandline, `
                @{ #Custom Select Number 1
                    Name="Hash"; 
                    Expression={
                        if($_.path){
                            (certutil.exe -hashfile $_.FullName SHA256)[1] -replace " ", ""
                        }else { "" }
                    }
                }, `
                @{ #Custom Select Number 2
                    Name="Process_Owner"; 
                    Expression={
                        $_.getowner().domain + "\" + $_.getowner().user
                    }     
                } 
        }
    }
    
}