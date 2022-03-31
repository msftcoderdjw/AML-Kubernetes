# region: aml helper function

Import-Module $PSScriptRoot\AzureRest.Utils.psm1 -Force

function ListWorkspaceUnderResourceGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string] $ArmEndpoint,
        [Parameter(Mandatory=$true)]
        [string] $SubscriptionId,
        [Parameter(Mandatory=$true)]
        [string] $ResourceGroupName
    )

    $Endpoint = "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.MachineLearningServices/workspaces?api-version=2021-03-01-preview"

    return Invoke-AzureRestCall -EndPoint $Endpoint -ArmEndpoint $ArmEndpoint -Get
}

function CreateWorkspaceUnderResourceGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string] $ArmEndpoint,
        [Parameter(Mandatory=$true)]
        [string] $SubscriptionId,
        [Parameter(Mandatory=$true)]
        [string] $ResourceGroupName,
        [Parameter(Mandatory=$true)]
        [string] $WorkspaceName,
        [Parameter(Mandatory=$true)]
        [string] $Location
    )

    $body = 
    '{
        "location": "' + $Location + '",
        "properties": {
          "friendlyName": "JiaweiTestAMLWorkspace-' + $WorkspaceName + '",
          "description": "Jiawei Test AML Workspace ' + $WorkspaceName + '",
          "storageAccount": "/subscriptions/746a51ba-0bd4-497f-89cc-f955a5db3bc8/resourcegroups/jiadu-amlonebox/providers/microsoft.storage/storageaccounts/aszoneboxws1610548251",
          "keyVault": "/subscriptions/746a51ba-0bd4-497f-89cc-f955a5db3bc8/resourcegroups/jiadu-amlonebox/providers/microsoft.keyvault/vaults/aszoneboxws1059700753",
          "applicationInsights": "/subscriptions/746a51ba-0bd4-497f-89cc-f955a5db3bc8/resourcegroups/jiadu-amlonebox/providers/microsoft.insights/components/aszoneboxws6908297026",
          "containerRegistry": "/subscriptions/746a51ba-0bd4-497f-89cc-f955a5db3bc8/resourceGroups/jiadu-amlonebox/providers/Microsoft.ContainerRegistry/registries/da9e9b5125c24342886e63ba5b8f9abb"
        }
    }'

    $Endpoint = "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.MachineLearningServices/workspaces/$($WorkspaceName)?api-version=2021-03-01-preview"

    return Invoke-AzureRestCall -EndPoint $Endpoint -ArmEndpoint $ArmEndpoint -Body $body -Put
}

function GetWorkspaceUnderResourceGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string] $ArmEndpoint,
        [Parameter(Mandatory=$true)]
        [string] $SubscriptionId,
        [Parameter(Mandatory=$true)]
        [string] $ResourceGroupName,
        [Parameter(Mandatory=$true)]
        [string] $WorkspaceName
    )

    $Endpoint = "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.MachineLearningServices/workspaces/$($WorkspaceName)?api-version=2021-03-01-preview"

    return Invoke-AzureRestCall -EndPoint $Endpoint -ArmEndpoint $ArmEndpoint -Get
}

function ListComputesUnderWorkspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string] $ArmEndpoint,
        [Parameter(Mandatory=$true)]
        [string] $SubscriptionId,
        [Parameter(Mandatory=$true)]
        [string] $ResourceGroupName,
        [Parameter(Mandatory=$true)]
        [string] $WorkspaceName
    )

    $Endpoint = "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.MachineLearningServices/workspaces/$($WorkspaceName)/computes?api-version=2019-05-01"

    return Invoke-AzureRestCall -EndPoint $Endpoint -ArmEndpoint $ArmEndpoint -Get
}

function GetComputesUnderWorkspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string] $ArmEndpoint,
        [Parameter(Mandatory=$true)]
        [string] $SubscriptionId,
        [Parameter(Mandatory=$true)]
        [string] $ResourceGroupName,
        [Parameter(Mandatory=$true)]
        [string] $WorkspaceName,
        [Parameter(Mandatory=$true)]
        [string] $ComputeName
    )

    $Endpoint = "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.MachineLearningServices/workspaces/$($WorkspaceName)/computes/$($ComputeName)?api-version=2019-05-01"

    return Invoke-AzureRestCall -EndPoint $Endpoint -ArmEndpoint $ArmEndpoint -Get
}

function AttachComputesUnderWorkspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string] $ArmEndpoint,
        [Parameter(Mandatory=$true)]
        [string] $SubscriptionId,
        [Parameter(Mandatory=$true)]
        [string] $ResourceGroupName,
        [Parameter(Mandatory=$true)]
        [string] $WorkspaceName,
        [Parameter(Mandatory=$true)]
        [string] $ComputeName,
        [Parameter(Mandatory=$true)]
        [string] $Location
    )

    $body = 
    '{
        "location": "' + $Location + '",
        "properties": {
            "computeType": "Kubernetes",
            "resourceId": "/subscriptions/746a51ba-0bd4-497f-89cc-f955a5db3bc8/resourceGroups/jiadu-amlonebox/providers/Microsoft.Kubernetes/connectedClusters/jiadu-ashk8s",
            "properties": {
                "namespace": "default",
                "defaultInstanceType": "default",
                "instanceTypes": {
                    "default": {
                        "nodeSelector": {
                            "ml.azure.com/sku": "CPU_8c_27GB"
                        },
                        "resources": {
                            "requests": {
                                "cpu": "1",
                                "memory": "2Gi",
                                "nvidia.com/gpu": 0
                            },
                            "limits": {
                                "cpu": "1",
                                "memory": "2Gi",
                                "nvidia.com/gpu": 0
                            }
                        }
                    }
                }
            }
        }
    }'

    $Endpoint = "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.MachineLearningServices/workspaces/$($WorkspaceName)/computes/$($ComputeName)?api-version=2019-05-01"

    return Invoke-AzureRestCall -EndPoint $Endpoint -ArmEndpoint $ArmEndpoint -Body $body -Put
}

# endregion