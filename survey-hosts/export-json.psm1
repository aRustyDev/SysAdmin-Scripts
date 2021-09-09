function Export-Json {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [psobject]
        $InputObject,

        # Parameter help description
        [Parameter(Mandatory=$true)]
        [ValidatePattern(".*\.json$")]
        [string]
        $FilePath,

        # Parameter help description
        [Parameter(Mandatory=$false)]
        [bool]$Append=$false,

        # Parameter help description
        [Parameter(Mandatory=$false)]
        [bool]$Compress=$false,

        # Parameter help description
        [Parameter(Mandatory=$false)]
        [bool]$Force=$false,

        # Parameter help description
        [Parameter(Mandatory=$false)]
        [bool]$WhatIf=$false,

        # Parameter help description
        [Parameter(Mandatory=$false)]
        [ValidateRange(1,100)]
        [Int32]$Depth=2,

        # Parameter help description
        [Parameter(Mandatory=$false)]
        [ValidateSet("ascii")] # "bigendianunicode","bigendianutf32","oem","unicode","utf7","utf8","utf8BOM","utf8NoBOM","utf32"
        [string]$Encoding="ascii"
    )

    # Convert to JSON
        $json = if($Compress){
            ConvertTo-Json -InputObject $InputObject -Depth $Depth -AsArray -Compress
        }else{
            ConvertTo-Json -InputObject $InputObject -Depth $Depth -AsArray
        }

    # Write to file
        if(($Encoding -ne $null) -and ($Append)){
            Out-File -InputObject $json -FilePath $FilePath -Append=$Append -Force=$Force -WhatIf=$WhatIf -Encoding $Encoding
        }else{
            Out-File -InputObject $json -FilePath $FilePath -Append=$Append -Force=$Force -WhatIf=$WhatIf
        }

}