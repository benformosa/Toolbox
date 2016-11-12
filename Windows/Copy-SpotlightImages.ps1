<#
.SYNOPSIS 
Copies images from the Windows Spotlight hidden folder.

.DESCRIPTION
Use this script to save the Spotlight lock screen images to use as desktop wallpaper.
By default, images are saved to a folder "Spotlight" in your Pictures library. Portrait and Landscape images are sorted into subfolders.

.PARAMETER Destination
Path to copy images to.

.PARAMETER NoSubFolders
Copy all images to the festination, rather than to a "Landscape" or "Portrait" subfolder.

.PARAMETER LandscapeOnly
Only copy images which are wider than they are tall.

.PARAMETER PortraitOnly
Only copy images which are taller than they are wide.

.PARAMTER Force
Always copy images, even if they already exist in the destination.
#>

[CmdletBinding(SupportsShouldProcess)]
Param(
[string] $Destination = (Join-Path $env:USERPROFILE "Pictures\Spotlight"),
[switch] $NoSubFolders,
[Parameter(ParameterSetName='LandscapeOnly')] [switch] $LandscapeOnly,
[Parameter(ParameterSetName='PortraitOnly')] [switch] $PortraitOnly,
[switch] $Force
)

begin {
    $SpotlightPath = Join-Path $env:LocalAppData "Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets"
    $MinimumImageSize = 500
    $Landscape = "Landscape"
    $Portrait = "Portrait"

    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    Write-Verbose "Created directory $($Destination)"
    if(-not $NoSubFolders) {
        if(-not $PortraitOnly) {
            New-Item -ItemType Directory -Path (Join-Path $Destination $Landscape) -Force | Out-Null
            Write-Verbose "Created directory $(Join-Path $Destination $Landscape)"
        }
        if(-not $LandscapeOnly) {
            New-Item -ItemType Directory -Path (Join-Path $Destination $Portrait) -Force | Out-Null
            Write-Verbose "Created directory $(Join-Path $Destination $Portrait)"
        }
    }
}

process {
    foreach($File in (Get-ChildItem $SpotlightPath)) {
        try {
            # This will cause an exception for a file that isn't an image
            $Image = New-Object System.Drawing.Bitmap $File.FullName

            # Filter out images which are too small to be wallpapers
            if ($Image.width -gt $MinimumImageSize -and $Image.height -gt $MinimumImageSize) {

                if($Image.width -gt $Image.height) {
                    $Aspect = $Landscape
                } else {
                    $Aspect = $Portrait
                }

                if($NoSubFolders) {
                    $DestinationDir = $Destination
                } else {
                    $DestinationDir = Join-Path $Destination $Aspect
                }

                # Rename the file with a valid file extension
                $DestinationFile = Join-Path $DestinationDir "$($File.name).jpg"

                $Exists = -not $Force -and (Test-Path $DestinationFile)

                if(-not $Exists -and
                    ($Aspect -eq $Portrait -and -not $LandscapeOnly) -or
                    ($Aspect -eq $Landscape -and -not $PortraitOnly)
                    ) {
                    Copy-Item $File.FullName -Destination $DestinationFile
                    Write-Verbose "Copied $($Aspect) image: $($DestinationFile)"
                }
            }
        } catch {
            Write-Verbose "Not an image file: $($File.Name)"
        }
    }
}
