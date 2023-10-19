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

function Update-A10ClientSslTemplate {
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
    $uri      = "https://$($Session.ApplianceFQDN)/services/rest/$($env:A10ApiVersion)/?session_id=$($Session.Id)&format=$($Env:A10ApiFormat)&method=slb.template.client_ssl.update"

    try {
        Write-Verbose "Attempting to update the client SSL template..."

        $currentClientSslTemplate = Get-A10ClientSslTemplate `
            -Session $session `
            -Filter $Parameters.Name

        if($currentClientSslTemplate){
            $clientSslTemplate = [ClientSslTemplate]::new()
            $clientSslTemplate.Properties = $currentClientSslTemplate.virtual_service.PSObject.Properties
            $clientSslTemplate.JsonObject = $currentClientSslTemplate
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
        else{
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    ([System.Net.Http.HttpRequestException]"Client SSL Template Not Found"),
                    "10",
                    [System.Management.Automation.ErrorCategory]::InvalidResult,
                    $null
                )
            )
        }
    }
    catch {
        $error = $_
        $PSCmdlet.ThrowTerminatingError($error)
    }

    if($response){
        if($response.response.status -ne "fail"){
            Write-Verbose "Successfully updated client SSL template $($clientSslTemplate.Properties.client_ssl_template.name)."
            $newClientSslTemplate = Get-A10ClientSslTemplate -Session $session -FilterByName $clientSslTemplate.Properties.client_ssl_template.name
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