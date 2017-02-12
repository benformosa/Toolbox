<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

 .PARAMETER subscriptionId
    The subscription id where the template will be deployed.

 .PARAMETER resourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER resourceGroupLocation
    Optional, a resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.

 .PARAMETER templateFilePath
    Path to the template file.

 .PARAMETER templateUri
    URI of a JSON template file.

 .PARAMETER parametersFilePath
    Optional, path to the parameters file. Defaults to parameters.json. If file is not found, will prompt for parameter values based on template.

  .PARAMETER Test
    Optional, runs Test-AzureRmResourceGroupDeployment instead of deploying the template. The Resource Group will still be created if it doesn't exist.

  .NOTES
    This script was cribbed from some Microsoft source online, I can't find exactly which one, but this general pattern seems to have been spread around the Internet quite a bit.
#>

param(
 [Parameter(Mandatory=$True)]
 [string]
 $subscriptionId,

 [Parameter(Mandatory=$True)]
 [string]
 $resourceGroupName,

 [string]
 $resourceGroupLocation = "australiaeast",

 [Parameter(Mandatory=$True,ParameterSetName='templateUri')]
 [string]
 $templateUri,

 [Parameter(Mandatory=$True,ParameterSetName='templateFile')]
 [string]
 $templateFilePath,

 [Parameter(Mandatory=$True)]
 [string]
 $parametersFilePath = "parameters.json",

 [ValidateSet("Incremental", "Complete")]
 [string]
 $mode = "Incremental",

 [switch]
 $test
)

<#
.SYNOPSIS
    Registers RPs
#>
Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Host "Registering resource provider '$ResourceProviderNamespace'";
    Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace;
}

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

$LoggedIn = $false
try {
    # Will throw an exception if the user is not logged in.
    Get-AzureRMContext | Out-Null
    $LoggedIn = $True
} catch {
    Write-Error "Run Login-AzureRmAccount to login."
}

if($LoggedIn) {
    # select subscription
    Write-Host "Selecting subscription '$subscriptionId'";
    Select-AzureRmSubscription -SubscriptionID $subscriptionId;

    # Register RPs
    $resourceProviders = @();
    if($resourceProviders.length) {
        Write-Host "Registering resource providers"
        foreach($resourceProvider in $resourceProviders) {
            RegisterRP($resourceProvider);
        }
    }

    #Create or check for existing resource group
    $resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
    if(!$resourceGroup)
    {
        Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
        if(!$resourceGroupLocation) {
            $resourceGroupLocation = Read-Host "resourceGroupLocation";
        }
        Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
        New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
    }
    else{
        Write-Host "Using existing resource group '$resourceGroupName'";
    }

    # Set up parameters to splat
    $Params = @{
        "ResourceGroupName" = $resourceGroupName
    }

    if(Test-Path $parametersFilePath) {
        $Params += @{
            "TemplateParameterFile" = $parametersFilePath
        }
    }

    if($templateUri) {
        $Params += @{
            "TemplateUri" = $templateUri
        }
    } else {
        $Params += @{
            "TemplateFile" = $templateFilePath
        }
    }

    # Start the deployment
    if($test){
        Write-Host "Starting test..."
        $Params += @{
            "Verbose" = $True
        }

        Test-AzureRmResourceGroupDeployment @Params
    } else {
        Write-Host "Starting deployment...";
        $Params += @{
            "Mode"= $Mode
            "Force" = $True
        }

        New-AzureRmResourceGroupDeployment @Params
    }
}
