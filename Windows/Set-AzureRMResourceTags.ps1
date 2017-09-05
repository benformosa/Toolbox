<#
.SYNOPSIS
Set tags on Azure Resources from input

.DESCRIPTION
Input should have a ResourceID. Tags should be in properties with names like TAG_tagname, where tagname is the key of the tag to set.

#>
[CmdletBinding(SupportsShouldProcess = $True)]
param(
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [object[]] $Resources
)

begin {
    $TagPrefix = "TAG_"
}

process {
    foreach ($Resource in $Resources) {
        # Validate that the input has a ResourceID
        if ($Resource.ResourceID) {
            # Get the Azure-RMResource
            $AzureResource = Get-AzureRMResource -ResourceId $Resource.ResourceID
            # Don't continue if Get-AzureRMResource failed
            if ($AzureResource) {
                Write-Verbose "Starting $($AzureResource.ResourceName)"
                
                # Convert the input into a Hash
                $ResourceHash = @{}
                $Resource.psobject.properties | ForEach-Object {
                    $ResourceHash."$($_.Name)" = $_.Value
                }
                
                # Remove any keys that aren't tags
                $NotTags = $ResourceHash.Keys | Where-Object {! $_.StartsWith($TagPrefix)}
                $NotTags | ForEach-Object {
                    $ResourceHash.Remove($_)
                }
                
                # Remove "TAG_" from the Hash keys
                $Tags = @{}
                $ResourceHash.GetEnumerator() | ForEach-Object {
                    $Tags."$($_.Name.replace($TagPrefix,''))" = $_.Value
                }
                Write-Verbose "    Found $($Tags.count) tags"
                
                # Update the Azure Resource
                $AzureResource | Set-AzureRmResource -Tag $Tags
            } else {
                Write-Verbose "Could not Get-AzureRMResource $($Resource.ResourceID)"
            }
        } else {
            Write-Verbose "No ResourceID found"
        }
    }
}
