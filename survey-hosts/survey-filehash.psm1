function survey-filehash {
    param (
        [CmdletBinding]

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
        $path
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