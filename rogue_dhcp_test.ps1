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
<#
#>
$script_name = "Nicht erlaubte DHCP Server"
$script_version = "1.0"
Write-Host $script_name
Write-Host "Skriptstand: 12.01.2021 08:00"
Write-Host "Version: $script_version"
$ErlaubteDHCPServer = @("192.168.178.1")
 
#Replace the Download URL to where you've uploaded the DHCPTest file yourself. We will only download this file once. 
$DownloadURL = "https://coswa.de/downloads/dhcptest-0.7-win64.exe"
$DownloadPfad = "c:\DHCPTest"
$Filename = "\DHCPTest.exe"
try {
    $TestDownloadPfad = Test-Path $DownloadPfad
    if (!$TestDownloadPfad) { new-item $DownloadPfad -ItemType Directory -force }
    $TestDownloadPfadZip = Test-Path "$DownloadPfad $Filename "
    if (!$TestDownloadPfadZip) { Invoke-WebRequest -UseBasicParsing -Uri $DownloadURL -OutFile "$($DownloadPfad)\DHCPTest.exe" }
}
catch {
    write-host "Der Download oder das erstellen von DHCPTest ist fehlgeschlagen. Error: $($_.Exception.Message)"
    exit 1
}
$Tests = 0
$GefundeneDHCPServer = do {
    & "$DownloadPfad\DHCPTest.exe" --quiet --query --print-only 54 --wait --timeout 3
    $Tests ++
} while ($Tests -lt 2)
 
foreach ($DHCPSERVER in $GefundeneDHCPServer) {
    if ($DHCPSERVER -notin $ErlaubteDHCPServer) { 
   $Status= "Nicht erlaubter DHCP Server gefunden. IP des Servers: $DHCPSERVER"
   $Fehler = 1
    
     }
}
 
if (!$Status) { 
$Status = "Alles in Ordnung. Keine weiteren DHCP Server gefunden."
$Fehler = 0
}
if ($fehler -gt 0) { # Bei Fehler
    write-host $Status
    $exitcode = 2001
    $result = 1
    $bpalert = 1
    $resultstring = "Fehler"
}
else {
    write-host $Status
    $exitcode = 0
    $result = 0
    $bpalert = 0
    $resultstring = "Alles in Ordnung"
}
