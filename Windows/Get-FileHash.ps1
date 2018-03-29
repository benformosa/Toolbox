# Get-FileHash for PowerShell 2.0

$files = GCI .
$sha1 = New-Object System.Security.Cryptography.SHA1CryptoServiceProvider
foreach($file in $files) {
    New-Object PSObject -Property @{
        Algorithm = "SHA1"
        Hash = [System.BitConverter]::ToString( $sha1.ComputeHash([System.IO.File]::ReadAllBytes($file))) -replace '-'
        Path = $file.FullName
    }
}
