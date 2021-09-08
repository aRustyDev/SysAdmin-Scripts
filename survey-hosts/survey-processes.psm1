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
        $creds
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