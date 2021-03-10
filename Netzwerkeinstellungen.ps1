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
$script_name = "Network Settings"
$script_version = "0.1"
Write-Host $script_name
Write-Host "Skriptstand: 09.03.2021 14:00"
Write-Host "Version: $script_version"
#Changelog
#
#
#
#
<#
Version:0.1
Initiale Version Netzwerk Interface Einstellungen
#>
# Parameter für manuelle Tests ("<" am Anfang entfernen)
#
#
#
#
#
#
#

<#
$ip ="192.168.0.33"
$strMask = "255.255.255.0"
$gateway ="192.168.0.1"
$dns1 ="192.168.0.1"
$dns2 ="192.168.0.1"
$networkInterface = "WLAN"
$ssid=""
$key=''
$profile =""

$setInterfaceStatic = "Nein"
$setInterfaceDisabled = "Nein"
$setInterfaceEnabled = "Nein"
$setInterfaceDhcpc = "Nein"
$setInterGetWlanProfiles = "Nein"
$setWlanConnect = "Nein"
$setDeleteWlanProfile = "Nein"
$resetIpStack = "Nein"

#>

Get-NetAdapter | Select Name

function set-interface-static ($networkInterface, $ip, $strMask, $gateway, $dns1 ,$dns2 )  {
	netsh interface ipv4 set address name=$networkInterface static $ip $strMask $gateway  1
	netsh interface ipv4 delete dnsservers name=$networkInterface all validate=no
	netsh interface ipv4 set dns name=$networkInterface static addr=$dns1 validate=no
	netsh interface ipv4 add dnsservers name=$networkInterface addr=$dns2 index=2 validate=no
}

function set-interface-disabled($networkInterface) {
	netsh interface set interface $networkInterface disabled
}

function set-interface-enabled($networkInterface) {
	netsh interface set interface $networkInterface enabled
}

function set-interface-dhcp($networkInterface) {
   Set-NetIPInterface -InterfaceAlias $networkInterface -Dhcp Enabled
   Set-DnsClientServerAddress -InterfaceAlias $networkInterface -ResetServerAddresses
}
function set-wlan-connect ($ssid, $key){
$WirelessNetworkSSID = $ssid
$WirelessNetworkPassword = $key

write $WirelessNetworkSSID
write $WirelessNetworkPassword

$Authentication = 'WPA2PSK' # Could be WPA2
$Encryption = 'AES'
$random = Get-Random –Minimum 1111 –Maximum 99999999
$tempProfileXML = "$env:TEMP\tempProfile$random.xml"

# Create the WiFi profile, set the profile to auto connect
$SSIDHEX=($SSID.ToCharArray() |foreach-object {'{0:X}' -f ([int]$_)}) -join''
$xmlfile="<?xml version=""1.0""?>
<WLANProfile xmlns=""http://www.microsoft.com/networking/WLAN/profile/v1"">
    <name>$SSID</name>
    <SSIDConfig>
        <SSID>
            <hex>$SSIDHEX</hex>
            <name>$WirelessNetworkSSID</name>
        </SSID>
    </SSIDConfig>
    <connectionType>ESS</connectionType>
    <connectionMode>auto</connectionMode>
    <MSM>
        <security>
            <authEncryption>
                <authentication>WPA2PSK</authentication>
                <encryption>AES</encryption>
                <useOneX>false</useOneX>
            </authEncryption>
            <sharedKey>
                <keyType>passPhrase</keyType>
                <protected>false</protected>
                <keyMaterial>$WirelessNetworkPassword</keyMaterial>
            </sharedKey>
        </security>
    </MSM>
</WLANProfile>
"

$XMLFILE > ($tempProfileXML)

netsh wlan add profile filename="$($tempProfileXML)"
netsh wlan show profiles $WirelessNetworkSSID key=clear
netsh wlan connect name=$WirelessNetworkSSID

}

function get-wlan-profiles{
$array = netsh wlan show profiles |
    ForEach-Object {
        if ($_ -match "\s*Profil fr alle Benutzer\s*:\s*(.*)") { $($matches[1]) }
    }
$array

foreach ($wn in $array) {
    netsh wlan show profile name=$wn key=clear
}
netsh wlan show interfaces | select-string SSID
}


function delete_wlan_profile($profile){
netsh wlan delete profile name=$profile
}

function Reset-IpStack {
	netsh int ip reset
	Restart-Computer
}


if ($setInterfaceStatic -eq "Ja"){set-interface-static $networkInterface $ip $strMask $gateway $dns1 $dns2 }
if ($setInterfaceDisabled -eq "Ja"){set-interface-disabled $networkInterface}
if ($setInterfaceEnabled -eq "Ja"){set-interface-enabled $networkInterface}
if ($setInterfaceDhcpc -eq "Ja"){set-interface-dhcp $networkInterface}
if ($setInterGetWlanProfiles -eq "Ja"){get-wlan-profiles}
if ($setWlanConnect -eq "Ja"){set-wlan-connect $ssid $key}
if ($setDeleteWlanProfile -eq "Ja"){delete_wlan_profile $profile}
if ($resetIpStack -eq "Ja"){Reset-IpStack}

