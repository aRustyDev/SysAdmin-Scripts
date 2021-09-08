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
        #$targets = Import-Csv -Path $env:WINHOSTS_CSV

        $i = 0
        foreach ($arg in $args) {
            if($arg -imatch "-subnet"){
                $targets = $targets | Where-Object {$_.subnet -match $args[$i+1]}
                $i++
                continue
            }
            if($arg -imatch "-os"){
                $targets = $targets | Where-Object {$_.os -match $args[$i+1]}
                $i++
                continue
            }
            $i++
        }
    }
    process {
        Invoke-Command -ComputerName $targets -Credential $creds -ScriptBlock {
            Get-wmiobject win32_useraccount | Select-Object AccountType, Name, LocalAccount, Domain, SID
        }
    }
}