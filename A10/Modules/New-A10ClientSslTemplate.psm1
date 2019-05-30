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

function New-A10ClientSslTemplate {
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeLine = $false,
            ValueFromPipeLineByPropertyName = $false)]
        [Session]$Session,

        [Parameter(
            Position = 1,
            Mandatory = $true,
            ValueFromPipeLine = $false,
            ValueFromPipeLineByPropertyName = $false)]
        [hashtable]$Parameters
    )

    $response = $null 
    $uri      = "https://$($Session.ApplianceFQDN)/services/rest/$($env:A10ApiVersion)/?session_id=$($Session.Id)&format=$($Env:A10ApiFormat)&method=slb.template.client_ssl.create"

    try {
        Write-Verbose "Attempting to create a client SSL template..."

        $clientSslTemplate = [ClientSslTemplate]::new()
        $clientSslTemplate.Properties | ForEach-Object {
            $property = $_.Name
            $Parameters.keys | ForEach-Object {
                $parameter = $_
                if($parameter -eq $property){
                    $clientSslTemplate.JsonObject.client_ssl_template.$parameter = $Parameters.$parameter
                }
            }
        }

        $response = Invoke-RestMethod `
            -Uri $uri `
            -Method Post `
            -Body ($clientSslTemplate.JsonObject | ConvertTo-Json)
    }
    catch {
        $error = $_
        $PSCmdlet.ThrowTerminatingError($error)
    }

    if($response){
        if($response.response.status -ne "fail"){
            Write-Verbose "Successfully create client SSL template $($Parameters.name)."
            $newClientSslTemplate = Get-A10ClientSslTemplate -Session $session -Filter @{ "name" = $Parameters.name }
            Write-Output $newClientSslTemplate
        }
        elseif($response.response.err.msg.Trim() -eq "Template name already exists."){
            Write-Verbose "Template $($Parameters.name) already exists."
            $newClientSslTemplate = Get-A10ClientSslTemplate -Session $session -Filter @{ "name" = $Parameters.name }
            Write-Output $newClientSslTemplate
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