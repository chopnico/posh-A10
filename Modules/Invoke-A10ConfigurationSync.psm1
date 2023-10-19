<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>
function Invoke-A10ConfigurationSync {
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeLine = $false,
            ValueFromPipeLineByPropertyName = $false)]
        [Session]$Session,

        [Parameter(
            Position = 1,
            Mandatory = $false,
            ValueFromPipeLine = $false,
            ValueFromPipeLineByPropertyName = $false)]
        [Switch]$SyncAllPartitions,

        [Parameter(
            Position = 2,
            Mandatory = $true,
            ValueFromPipeLine = $false,
            ValueFromPipeLineByPropertyName = $false)]
        [String]$PeerAddress
    )

    $uri = "https://$($Session.ApplianceFQDN)/services/rest/$($env:A10ApiVersion)/?session_id=$($Session.Id)&format=$($Env:A10ApiFormat)&method=ha.sync_config"

    if($SyncAllPartitions) { [String]$SyncAllPartitions = 1}

    $body = @"
{
        "ha_config_sync": {
            "auto_authentication": 1,
            "sync_all_partition": $($SyncAllPartitions),
            "operation": 0,
            "peer_destination": 1,
            "peer_reload": 1,
            "destination_ip": "$($PeerAddress)"
        }
    }
"@

    Write-Verbose "Attempting to sync configuration to peer..."
    $response = Invoke-RestMethod `
        -Uri $uri `
        -Method Post `
        -Body $body

    if($response){
        if($response.response.status -ne "fail"){
            Write-Verbose "Outputing status..."
            Write-Output $response.response
        }
        else {
            $error = $response.response.err
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    ([System.Net.Http.HttpRequestException]$error.msg),
                    $error.code,
                    [System.Management.Automation.ErrorCategory]::InvalidResult,
                    $error
                )
            )
        }
    }
}