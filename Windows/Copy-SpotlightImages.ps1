<#
.SYNOPSIS 
Copies images from the Windows Spotlight hidden folder.

.DESCRIPTION
Use this script to save the Spotlight lock screen images to use as desktop wallpaper.
By default, images are saved to a folder "Spotlight" in your Pictures library. Portrait and Landscape images are sorted into subfolders.

.PARAMETER Destination
Path to copy images to.

.PARAMETER NoSubFolders
Copy all images to the destination, rather than to a "Landscape" or "Portrait" subfolder.

.PARAMETER NoLandscape
Don't copy images which are wider than they are tall.

.PARAMETER NoPortrait
Don't copy images which are taller than they are wide.

.PARAMETER Force
Always copy images, even if they already exist in the destination.

.EXAMPLE
C:\PS> Copy-SpotlightImages.ps1 C:\Wallpapers -NoPortrait -NoSubFolders
#>

[CmdletBinding()]
Param(
[Parameter(Position=1)] [string] $Destination = (Join-Path $env:USERPROFILE "Pictures\Spotlight"),
[switch] $NoSubFolders,
[switch] $NoLandscape,
[switch] $NoPortrait,
[switch] $Force
)

begin {
    $SpotlightPath = Join-Path $env:LocalAppData "Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets"
    $MinimumImageSize = 500
    $Landscape = "Landscape"
    $Portrait = "Portrait"
    $LandscapePath = (Join-Path $Destination $Landscape)
    $PortraitPath = (Join-Path $Destination $Portrait)
    $PSBoundParameters.Confirm = $false
    $Hashes = Get-ChildItem -Path $Destination -Recurse | Get-FileHash | Select-Object -ExpandProperty Hash
}

process {
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    Write-Verbose "Created directory $($Destination)"
    if(-not $NoSubFolders) {
        if(-not $NoLandscape) {
            New-Item -ItemType Directory -Path $LandscapePath -Force | Out-Null
            Write-Verbose "Created directory $($LandscapePath)"
        }
        if(-not $NoPortrait) {
            New-Item -ItemType Directory -Path $PortraitPath -Force | Out-Null
            Write-Verbose "Created directory $($PortraitPath)"
        }
    }

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
                
                # Test if a file with the same name or data already exists. Always copy the file is Force is set
               if($Force) {
                    $doCopy = $true
                } else {
                    $FileHash = (Get-FileHash -Path $File.FullName).hash
                    $HashOK = $Hashes -notcontains $FileHash
                    $FileNameOK = Test-Path -Path $DestinationFile
                    $doCopy = $HashOK -and $FileNameOK
                }

                # Only copy the file if doCopy is True, and it's aspect hasn't been excluded
                if($doCopy -and
                    (($Aspect -eq $Portrait -and -not $NoPortrait) -or
                    ($Aspect -eq $Landscape -and -not $NoLandscape)
                    )) {
                    Copy-Item $File.FullName -Destination $DestinationFile
                    Write-Verbose "Copied $($Aspect) image: $($DestinationFile)"
                    if(-not $Force) {
                        $Hashes += $FileHash
                    }
                }
            }
        } catch {
            Write-Verbose "Not an image file: $($File.Name)"
        }
    }
}
