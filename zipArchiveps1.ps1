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


param($pfad = "",
$zipname =""
)

$script_name = "Order als ZipArchiv"
$script_version = "1.0"
Write-Host $script_name
Write-Host "Skriptstand: 17.02.2021 08:00"
Write-Host "Version: $script_version"

try {
	if ($pfad -eq "" ) {
		$pfad = read-host "Ordnerpfad welcher gepackt werden soll eingeben"
        $zipname = read-host "Archivname eingeben"
	}
	compress-archive -path $pfad -destinationPath "$pfad\$zipname.zip"
	write-host -foregroundColor green "Fertig: $($zipname).zip wurde erfolgreich nach $pfad gepackt"
	exit 0
} catch {
	write-error "ERROR: line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	exit 1
}