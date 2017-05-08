<#
.SYNOPSIS 
Copies images from the Windows Spotlight hidden folder.

.DESCRIPTION
Use this script to save the Spotlight lock screen images to use as desktop wallpaper.
By default, images are saved to a folder "Spotlight" in your Pictures library. Portrait and Landscape images are sorted into subfolders.

.PARAMETER Source
Path to copy images from. By default, this is the directory in which Windows stores Spotlight images.

.PARAMETER Destination
Path to copy images to.

.PARAMETER NoSubFolders
Copy all images to the destination, rather than to a "Landscape" or "Portrait" subfolder.

.PARAMETER NoLandscape
Don't copy images which are wider than they are tall.

.PARAMETER NoPortrait
Don't copy images which are taller than they are wide.

.PARAMETER MinimumImageSize
Only copy images with a height and width of this many pixels.

.PARAMETER Force
Always copy images, even if they already exist in the destination.

.EXAMPLE
C:\PS> Copy-SpotlightImages.ps1 -Destination C:\Wallpapers -NoPortrait -NoSubFolders
#>

[CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact='Low')]
Param(
    [Parameter(Position=1)] [string] $Source = (Join-Path $env:LocalAppData "Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets"),
    [Parameter(Position=2)] [string] $Destination = (Join-Path $env:USERPROFILE "Pictures\Spotlight"),
    [switch] $NoSubFolders,
    [switch] $NoLandscape,
    [switch] $NoPortrait,
    [int] $MinimumImageSize = 500,
    [switch] $Force
)

begin {
    # Import the dotNet Assembly
    Add-Type -AssemblyName System.Drawing

    $Landscape = "Landscape"
    $Portrait = "Portrait"
    $LandscapePath = (Join-Path $Destination $Landscape)
    $PortraitPath = (Join-Path $Destination $Portrait)

    Write-Verbose "Copy-SpotlightImages: Computing file hashes of all files in destination"
    $Hashes = Get-ChildItem -Path $Destination -Recurse | Get-FileHash | Select-Object -ExpandProperty Hash
}

process {
    # Create destination Directories
    New-Item -ItemType Directory -Path $Destination -ErrorAction SilentlyContinue | Out-Null
    If($?) { Write-Verbose "Copy-SpotlightImages: Created directory $($Destination)" }
    if(-not $NoSubFolders) {
        if(-not $NoLandscape) {
            New-Item -ItemType Directory -Path $LandscapePath -ErrorAction SilentlyContinue | Out-Null
            If($?) { Write-Verbose "Copy-SpotlightImages: Created directory $($LandscapePath)" }
        }
        if(-not $NoPortrait) {
            New-Item -ItemType Directory -Path $PortraitPath -ErrorAction SilentlyContinue | Out-Null
            If($?) { Write-Verbose "Copy-SpotlightImages: Created directory $($PortraitPath)" }
        }
    }

    # Loop over all files in source directory
    foreach($File in (Get-ChildItem -File $Source)) {
        $Image = $null
        try  {
            # Open file as Drawing.Image from a FileStream
            $FileStream = New-Object IO.FileStream(
                $File.FullName,
                [System.IO.FileMode]::Open,
                [System.IO.FileAccess]::Read,
                [IO.FileShare]::Read
            )
            $Image = [System.Drawing.Image]::FromStream($FileStream)
            Write-Verbose "Copy-SpotlightImages: $($File.Name) opened"
        } catch [System.Management.Automation.MethodInvocationException] {
            Write-Verbose "Copy-SpotlightImages: $($File.Name) is not an image"
        }

        if($Image) {
            # Filter out images which are too small to be wallpapers
            if ($Image.width -gt $MinimumImageSize -and $Image.height -gt $MinimumImageSize) {
                # Determine the aspect of the image
                if($Image.width -gt $Image.height) {
                    $Aspect = $Landscape
                } else {
                    $Aspect = $Portrait
                }
                Write-Verbose "Copy-SpotlightImages: $($File.Name) Aspect is $Aspect"

                # Set a destination directory
                if($NoSubFolders) {
                    $DestinationDir = $Destination
                } else {
                    $DestinationDir = Join-Path $Destination $Aspect
                }
                
                # Set a file extension if one doesn't exist
                $DestinationFile = Join-Path $DestinationDir "$($File.name)"
                if($file.name -notmatch "\.jpe?g$") { # Don't rename if it already has the right extension. -notmatch is case-insensitive
                    $DestinationFile += ".jpg"
                }
                
                # Test if a file with the same name or data already exists. Always copy the file if -Force is used
                if($Force) {
                    $doCopy = $true
                } else {
                    $FileHash = (Get-FileHash -Path $File.FullName).hash
                    $HashOK = $Hashes -notcontains $FileHash
                    if(-not $HashOK) {
                        Write-Verbose "Copy-SpotlightImages: $($File.name) filehash matches file in destination and won't be copied"
                    }
                    $FileNameOK = -not (Test-Path -Path $DestinationFile) # True if destination file does not exist
                    if(-not $FileNameOK) {
                        Write-Verbose "Copy-SpotlightImages: $($File.name) filename matches file in destination $($DestinationFile) and won't be copied"
                    }
                    $doCopy = $HashOK -and $FileNameOK
                }
                
                # Copy the file if doCopy is True, and it's aspect hasn't been excluded
                if($doCopy -and
                    (($Aspect -eq $Portrait -and -not $NoPortrait) -or
                    ($Aspect -eq $Landscape -and -not $NoLandscape)
                    )) {
                    Copy-Item $File.FullName -Destination $DestinationFile
                    Write-Verbose "Copy-SpotlightImages: Copied $($File.name) to $($DestinationFile)"
                    if(-not $Force) {
                        $Hashes += $FileHash
                    }
                }
            } else {
                Write-Verbose "Copy-SpotlightImages: $($File.Name) is too small. Width: $($Image.width), Height: $($Image.height)"
            }
        }
    }
}
