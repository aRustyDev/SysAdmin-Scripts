function survey-filehash {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
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
            Get-ChildItem -Path $using:Path | Where-Object { $_.Extension } | Select-Object Name, @{
                name="Hash"; 
                Expression={
                    (certutil.exe -hashfile $_.FullName SHA256)[1] -replace " ", ""
                }
            }
        }
    }
    end {
        # Try returning some value
    }
    
}