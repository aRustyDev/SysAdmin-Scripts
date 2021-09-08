function survey-firewall {
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
            $rules         = Get-NetFirewallRule | Where-Object { $_.Enabled }
            $portfilter    = Get-NetFirewallPortFilter
            $addressfilter = Get-NetFirewallAddressFilter

            foreach ($rule in $rules) {
                $ruleport = $portfilter | Where-Object { $_.InstanceID -eq $rule.InstanceID }
                $ruleaddress = $addressfilter | Where-Object { $_.InstanceID -eq $rule.InstanceID }
                $data = @{ #Custom Select Number 1
                    InstanceID = $rule.InstanceID.ToString()
                    Direction = $rule.Direction.ToString()
                    Action = $rule.Action.ToString()
                    LocalAddress = $ruleaddress.LocalAddress -join ","
                    RemoteAddress = $ruleaddress.RemoteAddress -join ","
                    Protocol = $ruleport.Protocol.ToString()
                    LocalPort = $ruleport.LocalPort -join ","
                    RemotePort = $ruleport.RemotePort -join ","
                }
                New-Object -TypeName psobject -Property $data
            }

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