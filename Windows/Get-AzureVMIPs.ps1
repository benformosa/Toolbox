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
    [String]
    $ResourceGroupName
)

$params = @{}
if($ResourceGroupName) {
    $params += @{
        ResourceGroupName = $ResourceGroupName
    }
}

$vms = Get-AzureRmVM @params
$nics = Get-AzureRmNetworkInterface @params | Where-Object VirtualMachine -NE $null

$output = @()

# Get PrivateIPAddress of each VM
foreach($nic in $nics)
{
    $vm = $vms | Where-Object -Property Id -EQ $nic.VirtualMachine.id
    $output += @{
        Name = $vm.Name
        PrivateIpAddress = $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
        PrivateIpAllocationMethod = $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAllocationMethod
    }
}

# Get PrivateIPAddress of each VM Scale Set instance
(Get-AzureRmVmss @params) | ForEach-Object {
    $VMSSName = $_.Name
    $ResourceGroup = $_.ResourceGroupName
    Get-AzureRmVmssVM -ResourceGroupName $ResourceGroup -VMScaleSetName $VMSSName | ForEach-Object {
        $VMSSVM = Get-AzureRmVmssVM -ResourceGroupName $ResourceGroup -VMScaleSetName $VMSSName -InstanceId $_.InstanceID
        $output += @{
            Name = $VMSSVM.name
            PrivateIpAddress = (Get-AzureRmResource -Resourceid $VMSSVM.NetworkProfile.NetworkInterfaces.Id).Properties.IpConfigurations.Properties.PrivateIpAddress
            PrivateIpAllocationMethod = (Get-AzureRmResource -Resourceid $VMSSVM.NetworkProfile.NetworkInterfaces.Id).Properties.IpConfigurations.Properties.PrivateIpAllocationMethod
        }
    }
}

# Output as a pscustomobject
$output | ForEach-Object {
    ( [pscustomobject] [hashtable] $_ )
} | Select-Object Name, PrivateIPAddress, PrivateIpAllocationMethod |
    Sort-Object -Property { [System.Version]$_.PrivateIPAddress } # Treat dotted decimal IP Addresses as version numbers for sorting
