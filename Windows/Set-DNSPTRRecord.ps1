<#
.SYNOPSIS
Updates the Reverse DNS record for a given hostname

.DESCRIPTION
Creates or updates a reverse DNS record in Windows DNS.
Assumes that classless reverse DNS zones are not used, i.e,
the most specific reverse DNS zone covers a Class C (/24) network.

.PARAMETER Hostname
Host for which to update DNS record. Hostname is resolved to an IP address.

.PARAMETER Nameserver
Nameserver to update DNS records on

#>

[CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Medium')]
Param(
    [Parameter(Position=1,Mandatory=$True)] [string] $Hostname,
    [Parameter(Position=2,Mandatory=$True)] [string] $Nameserver
)

begin {

    <#
    .SYNOPSIS
    Return the most specific reverse DNS zone for an IPv4 Address

    .DESCRIPTION
    Search a list of reverse DNS zone names for the most specific which matches the IP address.
    Assumes that a reverse DNS zone is not more specific than a /24 subnet.
    Returns $Null if no zones match.

    .PARAMETER Zones
    List of reverse DNS zone names. e.g. "30.20.10.in-addr.arpa".

    .PARAMETER IP
    An IPv4 address

    #>
    function Get-MatchingReverseDNSZone {
        Param(
            [string[]] $Zones,
            [IPAddress] $IP
        )

        # Sort zones from most to least specific, drop any forward zones
        $Zones = $Zones | 
            Where-Object { $_ -like "*.in-addr.arpa" } | 
            sort -Descending {$_.split('.').length}

        foreach($Zone in $Zones) {
            $Z = $Zone -replace ".in-addr.arpa", ""

            # Try each permutation of the IP, dropping the least significant octet each time.
            foreach($i in 2..0){
                $IPPart = $($ip.ToString().split('.')[$i..0] -join '.')
                if($Z -eq $IPPart) {
                    return $Zone
                }
            }
        }
        return $Null
    }


    $logprefix = "Set-DNSPTRRecord:"
    $Zones = (Get-DnsServerZone -ComputerName $Nameserver).ZoneName
}

process {
    # Resolve the hostname
    $Dig = Resolve-DnsName $Hostname

    # Get the canonical form of the hostname, including a trailing dot.
    #$CanonicalName = "$($Dig.Name)."

    # Resolve the hostname to an IPv4 address
    $IP = $Dig.IP4Address
    $RevIP = $IP.Split('.')[3..0] -join '.'

    # Get the DNS zone
    $ZoneName = (Get-MatchingReverseDNSZone -Zones $Zones -IP $IP)

    if($ZoneName) {
        $Zone = Get-DnsServerZone -ComputerName $Nameserver -Name $ZoneName
        
        # The number of octets in the zone
        $ZoneLength = ($ZoneName -replace ".in-addr.arpa", "").Split('.').Length
        
        # The value to set in the RR
        $PTRIP = $RevIP.Split('.')[0..($IP.Split('.').Length - $ZoneLength - 1)] -join '.'

        # Get the current reverse DNS record
        $oldptr = $Null
        $oldptr = Get-DnsServerResourceRecord -ComputerName $Nameserver -ZoneName $zone.ZoneName -RRType PTR -Name $PTRIP -ErrorAction SilentlyContinue

        Write-Verbose "$($logprefix) Host $($hostname) has IPv4 address $($ip)"
        Write-Verbose "$($logprefix) Reverse DNS $($PTRIP).$($zone.ZoneName): $($oldptr.RecordData.PtrDomainName)"

        if($oldptr.RecordData.PtrDomainName -eq $canonicalname) {
            Write-Verbose "$($logprefix) Reverse DNS already set correctly"
    
        } elseif($oldptr) {
            Write-Verbose "$($logprefix) Reverse DNS set incorrectly, updating"

            # Create a new object and update its value
            $newptr = $oldptr.Clone()
            $newptr.RecordData.PtrDomainName = $hostname

            if($PSCmdlet.ShouldProcess("Update Reverse DNS Record")) {
                Set-DnsServerResourceRecord -ComputerName $Nameserver -ZoneName $zone.ZoneName -OldInputObject $oldptr -NewInputObject $newptr -Verbose -PassThru
            }
        } else {
            Write-Verbose "$($logprefix) Reverse DNS not set, creating"
            if($PSCmdlet.ShouldProcess("Create Reverse DNS Record")) {
                Add-DnsServerResourceRecord -ComputerName $Nameserver -ZoneName $zone.ZoneName -AllowUpdateAny -Name $PTRIP -Ptr -PtrDomainName $hostname -Verbose -PassThru
            }
        }
    } else {
        Write-Error $([String]::Format("Reverse DNS zone not found for host {0} ({1})", $Hostname, $IP))
    }
}
