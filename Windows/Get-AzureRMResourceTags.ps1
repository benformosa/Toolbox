<#
.SYNOPSIS
Report on tags applied to Azure Resources

.DESCRIPTION


.PARAMETER VirtualMachines
Only report on Virtual Machines

.OUTPUTS
pscustomobject[]
#>
[CmdletBinding()]
param(
    [Switch]
    $VirtualMachines
)

begin {
    # Don't report on these tags
    $IgnoreTags = @(
        "ms-resource-usage"
        "creationSource"
        "RSVaultBackup"
    )

    # Get a list of all Tag Names (Keys)
    $TagNames = (Get-AzureRmTag).Name | Where-Object {!$IgnoreTags.Contains($_)}

    # List of properties to return for each resource
    $Properties = @(
        "ResourceName"
        "ResourceGroupName"
        "ResourceID"
    )

    # Array of custom objects to return
    $Resources = @()

    $VirtualMachinesFilter = {$_.ResourceType -eq "Microsoft.Compute/virtualMachines"}
    $AllFilter = {$_}

    if ($VirtualMachines) {
        $Filter = $VirtualMachinesFilter
    } else {
        $Filter = $AllFilter
    }
}

process {
    # Get all Virtual Machine Resources
    foreach ($Resource in $(Get-AzureRMResource | Where-Object $Filter)) {

        # Create a custom object
        $Object = New-Object PSObject

        # Add a member for each Property
        foreach ($Property in $Properties) {
            $Object | Add-Member Noteproperty $Property $Resource.$Property
        }

        # Add a member for each TagName
        foreach ($TagName in $TagNames) {
            $Object | Add-Member Noteproperty "TAG_$TagName" $Resource.Tags.$TagName
        }

        $Resources += $Object
    }
}

end {
    $Resources
}
