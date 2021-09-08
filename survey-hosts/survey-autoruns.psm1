function survey-autoruns {
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
        [string[]]
        $RegistryAutoRunLoc
    )
    begin {
        if(!$creds){ $creds = Get-Credential}
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
}