function idid {
    begin{
        #Check for $env:vars used
    }
    process{
        $targets = Import-Csv -Path $env:WINHOSTS_CSV
        $setup = @("","","","","")

        $i = 0
        $cmd, $subnet, $os = ""
        $issetup = $false

        foreach ($arg in $args) {
            $cmd += " " + $arg + " "
            if($arg -imatch "-subnet"){
                $subnet = $args[$i+1]
                $targets = $targets | Where-Object {$_.subnet -match $subnet}
                $i++
                continue
            }
            if($arg -imatch "-os"){
                $subnet = $args[$i+1]
                $targets = $targets | Where-Object {$_.os -match $os}
                $i++
                continue
            }
            if(($null -eq $paa) -and ($arg -notin @())){
                switch -Regex ($arg) {
                    "nmap" { $paa = "PAA1"; break }
                    "fping" { $paa = "PAA1"; break }
                    "nmap" { $paa = "PAA1"; break }
                    "nmap" { $paa = "PAA1"; break }
                    "nmap" { $paa = "PAA1"; break }
                    "nmap" { $paa = "PAA1"; break }
                    Default {$paa = ""; break}
                }
            }
            $i++
        }

        $out = "$(Get-Date -Format "yyyy-MM-dd @ HH:mm k") :: $($creds.Username) ran :: $cmd"
        #$seperator = "~" * $out.Length
        #$secondline = "|CMD Output|"

        Write-Output $("~"*$out.Length)            | Out-File -FilePath $env:OPERATORLOG_TXT -Append
        Write-Output $out                          | Out-File -FilePath $env:OPERATORLOG_TXT -Append
        Write-Output $("~"*$out.Length)            | Out-File -FilePath $env:OPERATORLOG_TXT -Append
        Write-Output "|CMD Output|"                | Out-File -FilePath $env:OPERATORLOG_TXT -Append
        Write-Output $("~"* "|CMD Output|".Length) | Out-File -FilePath $env:OPERATORLOG_TXT -Append

        Invoke-Expression $cmd | Tee-Object -FilePath $env:OPERATORLOG_TXT -Append

        $csv = New-Object -TypeName [PSCustomObject]@{
            dateran = if($out -match "\d\d\d\d-\d\d-\d\d"){$Matches[0]}else{$null}
            time    = if($out -match "\d\d:\d\d"){$Matches[0]}else{$null}
            user    = $creds.Username
            action  = $cmd
            paa     = $paa
            targets = $if($issetup){
                "(localhost) $((Get-NetIPAddress -InterfaceAlias eth0).IPAddress)"
            }else {
                "($subnet) $($targets.ip -join ",")"
            }
        }
        $csv | Export-Csv -Append -Path $env:OPERATORLOG_CSV
    }
}