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

function Update-A10VirtualServer {
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
    $uri      = "https://$($Session.ApplianceFQDN)/services/rest/$($env:A10ApiVersion)/?session_id=$($Session.Id)&format=$($Env:A10ApiFormat)&method=slb.virtual_service.update"

    try {
        Write-Verbose "Attempting to update the virtual service $($Parameters.name)..."

        $currentVirtualService = Get-A10VirtualService `
            -Session $session `
            -Filter $Parameters.Name

        if($currentVirtualService){
            $virtualService = [VirtualService]::new()
            $virtualService.Properties | ForEach-Object {
                $property = $_.Name
                $Parameters.keys | ForEach-Object {
                    $parameter = $_
                    if($parameter -eq $property){
                        $virtualService.JsonObject.virtual_service.$parameter = $Parameters.$parameter
                    }
                }
            }

            $response = Invoke-RestMethod `
                -Uri $uri `
                -Method Post `
                -Body ($virtualService.JsonObject | ConvertTo-Json)
        }
        else{
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    ([System.Net.Http.HttpRequestException]"Virtual Service Not Found"),
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
            Write-Verbose "Successfully updated virtual_service $($virtualService.Properties.virtual_service.name)."
            $newvirtualService = Get-A10VirtualService `
                -Session $session `
                -Filter @{ 
                    "name" = $virtualService.Properties.virtual_service.name
                }
            Write-Output $newvirtualService
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