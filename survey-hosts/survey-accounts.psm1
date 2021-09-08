function survey-accounts {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter()]
        [System.Object[]]
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
            Get-wmiobject win32_useraccount | Select-Object AccountType, Name, LocalAccount, Domain, SID
        }
    }
}