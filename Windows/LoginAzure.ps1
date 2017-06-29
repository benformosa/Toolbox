<#
.SYNOPSIS
Load Azure PowerShell Modules and authenticate

.DESCRIPTION
Easily connect to Azure PowerShell by storing subscription details in a JSON file

.PARAMETER Subscription
Name of the subscription to connect to. This name should be a key in the "subscriptions" object in
the Config File

.PARAMETER ConfigFile
Name of the JSON configuration file. Must contain the following:
- tenantId - Azure Tenant ID GUID.
- subscription - Objects. Each key is a friendly name which can be passed to the
    Subscription parameter. The value is a subscription ID GUID.
May also contain:
- username - the username (UPN/email address) you use to authenticate to Azure

.PARAMETER AzureDeploymentModel
Which Azure Modules to load, RM (Resource Manager), Classic or both.
#>

[CmdletBinding()]
Param(
    [Parameter(Position=1)] [string] $Subscription = "prod",
    [string] $ConfigFile = $(Join-Path $PSScriptRoot "LoginAzure.json"),
    [ValidateSet("RM","Classic","Both")] [string] $AzureDeploymentModel = "RM"
)

# Load settings from JSON
$Settings = Get-Content $ConfigFile | ConvertFrom-Json

# Ensure that required values are present
if(! $Settings.TenantId) {
    Write-Error "TenantId not set in Config File"
    exit
}
if(! $Settings.subscriptions.$Subscription) {
    Write-Error "Subscription $Subscription not set in Config File"
    exit
}

# If username is present, pass it to Get-Credential
$gcparams = @{
    'Message' = 'Azure credential'
}
if($Settings.username) {
    $gcparams['UserName'] = $Settings.username
}

# Get a credential for Azure
$AzureCred = Get-Credential @gcparams

# Import the PowerShell modules and authenticate to Azure
if(@("RM", "Both") -contains $AzureDeploymentModel) {
    Get-Module -ListAvailable AzureRM* | Import-Module
    Add-AzureRmAccount -TenantId $Settings.TenantId -Credential $AzureCred -SubscriptionId $Settings.subscriptions.$Subscription
}
if (@("Classic", "Both") -contains $AzureDeploymentModel) {
    Import-Module Azure
    Add-AzureAccount -TenantId $Settings.TenantId -Credential $AzureCred
}
