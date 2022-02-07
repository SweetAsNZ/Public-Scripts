function RIGHT {

    # Right <"string"> -Length 20

    [CmdletBinding()]
    Param (
        [Parameter(Position=0, Mandatory=$True,HelpMessage="Enter a string of text")]
        [String]$text,
        [Parameter(Mandatory=$True)]
        [Int]$Length
    )

    $startchar = [math]::min($text.length - $Length,$text.length)
    $startchar = [math]::max(0, $startchar)
    $right     = $text.SubString($startchar ,[math]::min($text.length, $Length))
    $right
}

function LEFT {
    
    # Left <"string"> -Length 20

    [CmdletBinding()]
    Param (
        [Parameter(Position=0, Mandatory=$True,HelpMessage="Enter a string of text")]
        [String]$text,
        [Parameter(Mandatory=$True)]
        [Int]$Length
   )

    $left = $text.SubString(0, [math]::min($Length,$text.length))
    $left
}
