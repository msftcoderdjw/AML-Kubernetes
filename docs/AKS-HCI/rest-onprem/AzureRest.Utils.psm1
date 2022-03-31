# region: rest helper function
function Invoke-AzureRestCall {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Endpoint,

        [Parameter(Mandatory = $true)]
        [string]
        $ArmEndpoint,

        [Parameter(ParameterSetName='PutRequest')]
        [switch]
        $Put,

        [Parameter(ParameterSetName='GetRequest')]
        [switch]
        $Get,

        [Parameter(ParameterSetName='DeleteRequest')]
        [switch]
        $Delete,

        [Parameter(Mandatory = $true, ParameterSetName='PutRequest')]
        [string]
        $Body,

        [Parameter(Mandatory = $false)]
        [int]
        $TimeoutInSec = 300
    )
    
    $ErrorActionPreference = 'Stop'

    if ($Put) {
        $response = Send-Request -Endpoint $Endpoint -ArmEndpoint $ArmEndpoint -Put -Body $Body
    } elseif ($Get) {
        $response = Send-Request -Endpoint $Endpoint -ArmEndpoint $ArmEndpoint -Get
    } elseif ($Delete) {
        $response = Send-Request -Endpoint $Endpoint -ArmEndpoint $ArmEndpoint -Delete
    }

    if ((($response.StatusCode -eq 201) -or ($response.StatusCode -eq 202)) -and ($response.Headers["Azure-AsyncOperation"] -or $response.Headers["Location"])) {
        # Indicate an async operation
        return Wait-Operation -OperationResponse $response -ArmEndpoint $ArmEndpoint -TimeoutInSec $TimeoutInSec
    } else {
        return $response
    }

}

function Send-Request() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Endpoint,

        [Parameter(Mandatory = $true)]
        [string]
        $ArmEndpoint,

        [Parameter(ParameterSetName='PutRequest')]
        [switch]
        $Put,

        [Parameter(ParameterSetName='GetRequest')]
        [switch]
        $Get,

        [Parameter(ParameterSetName='DeleteRequest')]
        [switch]
        $Delete,

        [Parameter(Mandatory = $true, ParameterSetName='PutRequest')]
        [string]
        $Body
    )

    $ErrorActionPreference = 'Stop'

    try {
        $tokens = @()
        $tokens += try { [Microsoft.IdentityModel.Clients.ActiveDirectory.TokenCache]::DefaultShared.ReadItems() } catch { }
        $tokens += try { [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.TokenCache.ReadItems() } catch { }
        $tokenTraceProperties = @('DisplayableId', 'GivenName', 'ClientId', 'UniqueId', 'TenantId', 'Resource', 'Authority', 'IdentityProvider', 'ExpiresOn') # FamilyName, IsMultipleResourceRefreshToken, AccessToken, RefreshToken, IdToken

        $context = Get-AzureRmContext -ErrorAction Stop -Verbose
        $azureEnvironment = Get-AzureRmEnvironment -Name $($context.Environment.Name) -ErrorAction Stop
        $token = $tokens |
            Where-Object Resource  -eq $azureEnvironment.ActiveDirectoryServiceEndpointResourceId |
            Where-Object { ($_.TenantId -eq $azureEnvironment.AdTenant) -or ($azureEnvironment.AdTenant -and ($_.Authority -like "*$($azureEnvironment.AdTenant)*")) } |
            Where-Object DisplayableId -eq $context.Account.Id |
            Sort-Object ExpiresOn |
            Select-Object -Last 1
    
        Write-Verbose "Using access token: $($token | Select-Object $tokenTraceProperties | Format-List | Out-String)" -Verbose
    } catch {
        if ($_ -like "*Get-AzureRmContext*") {
            $token = (az account get-access-token) | ConvertFrom-Json
        } else {
            throw $_
        }
    }

    $header = @{
        'Content-Type'  = 'application\json'
        'Authorization' = "Bearer " + $token.AccessToken
    }

    $url = $Endpoint
    if (-not $Endpoint.StartsWith('http')) {
        $url = $ArmEndpoint + $Endpoint
    }

    if ($Get) {
        return Invoke-WebRequest -Uri $url -Headers $header -Method Get -UseBasicParsing
    }
    elseif ($Put) {
        return Invoke-WebRequest -Uri $url -Headers $header -Method Put -Body $body -ContentType 'application/json' -UseBasicParsing
    }
    elseif ($Delete) {
        return Invoke-WebRequest -Uri $url -Headers $header -Method Delete -UseBasicParsing
    }
}

function Wait-Operation() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]
        $OperationResponse,

        [Parameter(Mandatory = $true)]
        [string]
        $ArmEndpoint,

        [Parameter(Mandatory = $false)]
        [int]
        $TimeoutInSec = 300
    )

    $ErrorActionPreference = 'Stop'

    if ($OperationResponse.StatusCode -ge 300) {
        throw "Previous operation is failed: $OperationResponse"
    }

    $queryUrl = $OperationResponse.Headers["Azure-AsyncOperation"]
    if (-not $queryUrl) {
        $queryUrl = $OperationResponse.Headers["Location"]
    }

    $startTime = (Get-Date)

    while ($true) {
        $response = Send-Request -Endpoint $queryUrl -ArmEndpoint $ArmEndpoint -Get
        if (($response.Content | ConvertFrom-Json).Status -eq 'Succeeded') {
            return $response;
        }
        elseif (($response.Content | ConvertFrom-Json).Status -eq 'Failed') {
            $errorMessage = ($response.Content | ConvertFrom-Json).error.details.message
            throw "Wait-Operation failed due to $errorMessage"
        }
        else {
            Start-Sleep -Seconds 10
        }

        if (((Get-Date) - $startTime).TotalSeconds -gt $TimeoutInSec) {
            throw "Timeout while waiting for operation: $OperationResponse"
        }
    }
}

# endregion