Import-Module $PSScriptRoot\AMLRest.Utils.psm1 -Force

$ArmEndpoint = "https://adminmanagement.shanghai.int.azurestack.corp.microsoft.com"
$SubscriptionId = "ec8a03cd-95c8-4e27-8298-baafeac190cd"
$ResourceGroupName = "jiadu-amltestrg"
$Location = "shanghai"

$env:AZUREML_CURRENT_CLOUD="AzureStack-Admin-cae20689-f5ee-4377-93ba-18a68ebb55d4"
$env:ARM_CLOUD_METADATA_URL="https://aml.dbadapter.shanghai.int.azurestack.corp.microsoft.com/CloudEndpoints"
$env:HTTPS_PROXY="http://127.0.0.1:8888"
$env:HTTP_PROXY="http://127.0.0.1:8888"
$env:NO_PROXY="kubernetes.docker.internal:6443"

# List workspace under resource group
$response = ListWorkspaceUnderResourceGroup -ArmEndpoint $ArmEndpoint -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName
Write-Host "List workspaces in ResourceGroupName $ResourceGroupName" -ForegroundColor Green
($response.Content | ConvertFrom-Json).value | ft name,type -AutoSize

# Get or create workspace
$WorkspaceName = "jd-e2ews-220331b"
try {
    $response = GetWorkspaceUnderResourceGroup -ArmEndpoint $ArmEndpoint -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName
    Write-Host "Workspace $WorkspaceName found in ResourceGroupName $ResourceGroupName" -ForegroundColor Green
} 
catch {
    Write-Host "Create Workspace $WorkspaceName in ResourceGroupName $ResourceGroupName" -ForegroundColor Green
    CreateWorkspaceUnderResourceGroup -ArmEndpoint $ArmEndpoint -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName -Location $Location
    Write-Host "Workspace $WorkspaceName Created in ResourceGroupName $ResourceGroupName" -ForegroundColor Green
}

# List computes under workspace
$response = ListComputesUnderWorkspace -ArmEndpoint $ArmEndpoint -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName
Write-Host "List computes under Workspace $WorkspaceName in ResourceGroupName $ResourceGroupName" -ForegroundColor Green
($response.Content | ConvertFrom-Json).value | ft name, type -AutoSize

# Get or attach compute
$ComputeName = "amlarc-asz3"
try {
    $response = GetComputesUnderWorkspace -ArmEndpoint $ArmEndpoint -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName -ComputeName $ComputeName -ErrorAction Continue
    Write-Host "Compute $ComputeName found under Workspace $WorkspaceName in ResourceGroupName $ResourceGroupName" -ForegroundColor Green
}
catch {
    Write-Host "Create Compute $ComputeName found under Workspace $WorkspaceName in ResourceGroupName $ResourceGroupName" -ForegroundColor Green
    AttachComputesUnderWorkspace -ArmEndpoint $ArmEndpoint -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName -ComputeName $ComputeName -Location $Location 
    Write-Host "Compute $ComputeName under Workspace $WorkspaceName Created in ResourceGroupName $ResourceGroupName" -ForegroundColor Green
}