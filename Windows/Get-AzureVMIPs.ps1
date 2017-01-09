<#
.SYNOPSIS
Get the Private IP Addresses of all Azure VMs in a Resource Group.

.DESCRIPTION
Find the VM Name, Private IP Address and IP Address allocation method of each VM in an Azure Resource Group.

.PARAMETER ResourceGroupName
Name of the Azure Resource Group.

.OUTPUTS
pscustomobject
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [String]
    $ResourceGroupName
)

$vms = Get-AzureRmVM -ResourceGroupName $ResourceGroupName
$nics = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName | Where-Object VirtualMachine -NE $null

$output = @()
foreach($nic in $nics)
{
    $vm = $vms | Where-Object -Property Id -EQ $nic.VirtualMachine.id
    $output += @{
        Name = $vm.Name
        PrivateIpAddress = $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
        PrivateIpAllocationMethod = $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAllocationMethod
    }
}

$output | ForEach-Object {
    ( [pscustomobject] [hashtable] $_ )
} | Select-Object Name, PrivateIPAddress, PrivateIpAllocationMethod
