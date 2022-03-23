<######################################################################
#                                                                     #
#                                                                     #
#                                                                     #
#   Herausgeber: Wallmeyer & Wallmeyer GbR                            #
#   Website: https://www.coswa.de                                     #
#   Telefon: 05921-3083753                                            #
#   E-Mail: info@coswa.de                                             #
#                                                                     #
#                                                                     #
#                                                                     #
#                                                                     #
#######################################################################>
#
# Parameter für manuelle Tests ("<" am Anfang entfernen)
<#
$detect ="Kaspersky" #Searchstring
$detectAction = 2 # 1 = Fehler 2 = Warnung
#>


$script_name = "AV Search and Detect Community"
$script_version = "1.0"
$script_cr = "Wallmeyer & Wallmeyer GbR"
$scriptstand = "23.03.2022 - 10:43 Uhr"




######################## Feste Parameter ###########################
$ErrorActionPreference = "stop"
$wrapzeichen = 90 # Automatischer Zeilenumbruch nach x Zeichen
[int32]$fehler = 0
[string]$global:ausgabe = ""
[string]$global:Fehlerausgabe = ""
$computer = $env:COMPUTERNAME

######################## Variable Parameter ###########################

######################### IMPORT der benötigten Module########################

######################### Funktionen für die Ausgabe #########################
function snormal {
    param ($vt, [int]$AnzAbsatz = 1)
    if (!$global:ausgabe) {
        $global:ausgabe += "######### Erfolgreiche Job Informationen ######### `n`n"
    }

    $global:ausgabe += ("$vt " + ("`n" * $AnzAbsatz))
}

function sfehler {
    param ($vt, [int]$AnzAbsatz = 1)
    if (!$global:Fehlerausgabe) {
        $global:Fehlerausgabe += "######### Fehler und Warnung Informationen ######### `n`n"
    }

    $global:Fehlerausgabe += ("$vt " + ("`n" * $AnzAbsatz))
    $global:fehler ++
}


Function Concat {
    Param ([switch]$Newlines, $Wrap, $Begin = '', $End = '', $Join = '')
    Begin {
        if ($Newlines) {
            $Join = [System.Environment]::NewLine
        }
        $output = New-Object System.Text.StringBuilder
        $deliniate = $False

        if (!$Wrap) {
            $output.Append($Begin) | Out-Null
        }
        elseif ($Wrap -is [string]) {
            $output.Append(($End = $Wrap)) | Out-Null
        }
        else {
            $output.Append($Wrap[0]) | Out-Null
            $End = $Wrap[1]
        }
    }
    Process {
        if (!($_ = [string]$_).length) {
        }
        elseif ($deliniate) {
            $output.Append($deliniate) | Out-Null
            $output.Append($_) | Out-Null
        }
        else {
            $deliniate = $Join
            $output.Append($_) | Out-Null
        }
    }
    End {
        $output.Append($End).ToString()
    }
}

$_WRAP = @{'' = "`$1$([System.Environment]::NewLine)" }
Function _Wrap {
    Param ($Length, $Step, $Force)

    $wrap = $Force -join '' -replace '\\|]|-', '\$0'
    $chars = "^\n\r$wrap"
    $preExtra = "[$chars\S]*"
    $postExtra = "[^\s$wrap]"

    $chars = "[$chars]"
    $postChars = "$preExtra$postExtra"
    if ($wrap) {
        $wrap = "[$wrap]"
        $wrap
        $wrap = "$wrap(?=\S)"
        $chars = "$chars|$wrap"
        $postChars = "$postChars|$preExtra$wrap"
    }

    for (
        ($extra = 0), ($next = $NULL), ($prev = $NULL);
        ($next = $Length - $Step) -gt 0 -and ($prev = $extra + $Step);
        ($Length = $next), ($extra = $prev)
    ) {
        "(?:$chars){$next,$Length}(?=(?:$postChars){$extra,$prev})"
    }
}

Function Wrap {
    Param (
        [int]$Length = 80,
        [int]$Step = 5,
        [char[]]$Force,
        [parameter(Position = 0)][string]$Text
    )
    $key = "$Length $Step $Force"
    $wrap = $_WRAP[$key]
    if (!$wrap) {
        $wrap = $_WRAP[$key] = _Wrap `
            -Length $Length `
            -Step $Step `
            -Force ($Force -join '') `
        | Concat -Join '|' -Wrap '(', ')(?:[^\n\r\S])+'
    }
    return $Text -replace $wrap, $_WRAP['']
}

$global:errorcode = 0
$global:exitvalue = 0
function serrorcode ($errorcode_new) {
    if ($global:errorcode -eq 1) {
        return $global:errorcode
    }
    else {

        if ($errorcode_new -eq $global:errorcode -and $global:errorcode -eq 0) {
        }
        elseif ($errorcode_new -eq 1) {
            $global:errorcode = $errorcode_new
        }
        elseif ($errorcode_new -eq 2) {
            $global:errorcode = $errorcode_new        
        }
        elseif ($errorcode_new -eq 3 -and $global:errorcode -lt 2) {
            $global:errorcode = $errorcode_new        
        }

        return $global:errorcode
    }
}

function sresult() {
    if ($global:errorcode -eq 1) {
        $resultstring = "Notfall9999 - Der Status ist nicht optimal!"
        $global:exitvalue = 1001 
    }
    elseif ($global:errorcode -eq 2) {
        $resultstring = "Mittel8888 - Der Status ist nicht optimal!"
        $global:exitvalue = 1002         
    }
    elseif ($global:errorcode -eq 3) {
        $resultstring = "Info7777 - Der Status ist nicht optimal!"
        $global:exitvalue = 1002
    }
    elseif ($global:errorcode -eq 0) {
        $resultstring = "OK - Der Status ist optimal."
        $global:exitvalue = 0
    }
    return $resultstring
}

######################### Skript #########################
snormal "`n`n"
snormal "############################# Version Informationen #############################"
snormal "$script_name"
snormal "Skriptstand: $scriptstand"
snormal "Version: $script_version"
snormal "Copyright: $script_cr"
 
    $fehler = 0
    serrorcode 0 | Out-Null


   
    $SearchTerm = "*"+$detect+"*"
    $wmiQuery = "SELECT * FROM AntiVirusProduct"
    try{
    $AntivirusProduct = Get-WmiObject -Namespace "root\SecurityCenter2" -Query $wmiQuery  @psboundparameters -ErrorAction Stop   
    $AV = $AntivirusProduct.displayName         
    if($AV -like $SearchTerm) { 
       
        $fehler = 1
        if ($detectAction -eq 1){
            sfehler "---------- Fehler AV: $detect  gefunden ----------"
            serrorcode 1 | Out-Null
        }else{
            sfehler "---------- Warnung AV: $detect  gefunden ----------"
            serrorcode 3 | Out-Null
        }
        sfehler "$AV ist auf $computer installiert"
        

    } 
    else{ 
        snormal "---------- AV: $detect nicht gefunden Alles OK ----------"
        snormal "$AV ist auf $computer installiert"
        $fehler = 0
        serrorcode 0 | Out-Null

    }
}catch{
    sfehler "---------- Warnung KEIN AV gefunden ----------"
    sfehler "Es ist KEIN AV auf dem $computer installiert"
    sfehler "Bitte überprüfen"
    $fehler = 1
    serrorcode 3 | Out-Null
}

 
######################### Finale Ausgabe #########################

if ($fehler -gt 0) {
    # Bei Fehler
    wrap -Length $wrapzeichen $Fehlerausgabe
    wrap -Length $wrapzeichen $ausgabe
    $resultstring = sresult
    $exitcode = $global:exitvalue

}

else {
    wrap -Length $wrapzeichen $ausgabe
    
    $resultstring = sresult
    $exitcode = $global:exitvalue
}


$result = $exitcode
$bpalert = $exitcode
write-host $exitcode
write-host $resultstring
exit $exitcode