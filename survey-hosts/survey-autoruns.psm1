function survey-autoruns {
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
        [Parameter()]
        [string[]]
        $RegistryAutoRunLoc,

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
            $autorundirs = `
                "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\startup",`
                "$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs\startup"

            foreach ($dir in $autorundirs) {
                foreach ($file in Get-ChildItem -Path $dir -Recurse | Where-Object { $_.Extension }){
                    $data = @{
                        Type     = "AutoRun Directory"
                        File     = $file.FullName
                        Hash     = (certutil.exe -hashfile $_.FullName SHA256)[1] -replace " ", ""
                        Location = $dir
                        Command  = $null
                    }
                    New-Object -TypeName psobject -Property $data
                }
            }

            foreach ($location in $using:RegistryAutoRunLoc) {
                if(!(Test-Path $location)){ continue }else{
                    $reg = Get-Item -Path $location -ErrorAction SilentlyContinue
                    foreach ($key in $reg.GetValueNames()){
                        $command = $reg.getvalue($key)
                        $file    = $command -replace '\"', "" -replace "\.exe.*", ".exe"
                        $data    = @{
                            Type     = "AutoRun Registry"
                            File     = $file
                            Hash     = (certutil.exe -hashfile $_.FullName SHA256)[1] -replace " ", ""
                            Location = "$location\$key"
                            Command  = $command
                        }
                        New-Object -TypeName psobject -Property $data
                    }
                }
            }
        }
    }
    end {
        # Try returning some value
    }
}