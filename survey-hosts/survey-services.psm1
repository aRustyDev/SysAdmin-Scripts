function survey-services {
    param (
        [CmdletBinding]
        
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
            Get-wmiobject win32_useraccount | Select-Object AccountType, Name, LocalAccount, Domain, SID
        }
    }
    
}