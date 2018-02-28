# AWSSnowballls
# Recursive ls and du for AWS Snowball
# Assumes AWS Snowball client is installed, and `snowball` is in your PATH

# Given a human-readable filesize, return a number of bytes
function dehumanise([string] $s) {
    $s = $s.Replace("Byte", "")
    $s.Replace(" ", "")/1
}

# Convert `snowball ls` output to a pscustom object
function snowball-ls ([string] $path) {
    $strings = snowball ls $path
    # Loop over each line of output
    $obj = $strings | 
        ForEach-Object {
            # Convert each line into an array
            $p=($_ -replace "  +", ";").split(';')
            New-Object psobject -property @{
                Type=$p[0]
                Size=$p[1]
                SizeBytes=dehumanise($p[1])
                Path=$p[2]
            }
        }
    return $obj
}

# Recursively list directories on snowball
function snowball-ls-recursive ([string] $path) {
    # ArrayLists allow members to be easily removed
    [System.Collections.ArrayList] $Files = @() # List of files
    [System.Collections.ArrayList] $Folders = @($Path) # List of paths to ls

    While ($Folders) {
        Write-Verbose "$($Files.count) files listed"
        Write-Verbose "$($Folders.Count) folders pending"
        $Folders | %{ Write-Verbose "     $_"}

        # Process the first pending folder
        $F = $Folders[0]
        Write-Verbose $f

        # List the directory
        $obj = snowball-ls $F

        # Remove this folder from the list of pending folders
        $Folders.Remove($F)

        # Filter out files and add to our output
        $listedfiles = ($obj | Group-Object "Type" | ?{$_.Name -eq "File"}).Group
        Write-Verbose "$($listedfiles.count) new files"
        $Files += $listedfiles

        # Filter out folders and add to list of pending folders
        $listedfolders = ($obj | Group-Object "Type" | ?{$_.Name -eq "Folder"}).Group.Path
        Write-Verbose "$($listedfolders.count) new folders"
        # Don't add empty arrays to $Folders
        if($listedfolders) {
            $Folders += $listedfolders
        }
    }
    return $Files
}

# Get the total size of snowball files
# Ingests output of snowball-ls or snowball-ls-recursive
function snowball-ls-bytes ($obj) {
    $Bytes = ($obj.SizeBytes | Measure-Object -Sum).Sum

    New-Object psobject -property @{
        Bytes = $Bytes
        Kilobytes = [math]::truncate($Bytes / 1KB)
        Megabytes = [math]::truncate($Bytes / 1MB)
        Gigabytes = [math]::truncate($Bytes / 1GB)
    }
}

# Show the total size of a snowball directory
function snowball-du ([string] $path) {
    snowball-ls-bytes $(snowball-ls-recursive $path) | Select @{N="Path"; E={$path}}, Megabytes, Bytes
}
