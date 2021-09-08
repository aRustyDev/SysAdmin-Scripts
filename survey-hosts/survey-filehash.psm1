function survey-filehash {
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
        [Parameter(Mandatory=$true)]
        [string]
        $path,

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
            Get-ChildItem -Path $using:Path | Where-Object { $_.Extension } | Select-Object Name, @{
                name="Hash"; 
                Expression={
                    (certutil.exe -hashfile $_.FullName SHA256)[1] -replace " ", ""
                }
            }
        }
    }
    
}