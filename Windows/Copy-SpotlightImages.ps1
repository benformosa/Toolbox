$SpotlightPath = Join-Path $env:LocalAppData "Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets"
$DestinationPath = Join-Path $env:USERPROFILE "Pictures\Spotlight"

$Landscape = "Landscape"
$Portrait = "Portrait"

New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $DestinationPath $Landscape) -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $DestinationPath $Portrait) -Force | Out-Null

foreach($file in (gci $SpotlightPath)) {
    try {
        $Image = New-Object System.Drawing.Bitmap $File.FullName
        if ($Image.width -gt 500 -and $Image.height -gt 500) {
            if($Image.width -gt $Image.height) {
                $Subfolder = $Landscape
            } else {
                $Subfolder = $Portrait
            }
            $DestinationFile = (Join-Path "$($DestinationPath)\$($Subfolder)" "$($File.name).jpg")
            Copy-Item $File.FullName -Destination $DestinationFile
            Write-Verbose "Saved file $DestinationFile"
        }
    } catch {
        Write-Verbose "Invalid file $File.FullName"
    }
}
