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

function Get-A10VirtualService {
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
        [Hashtable]$Filter
    )

    $uri = $null

    if(-not $Filter){
        $uri = "https://$($Session.ApplianceFQDN)/services/rest/$($env:A10ApiVersion)/?session_id=$($Session.Id)&format=$($Env:A10ApiFormat)&method=slb.virtual_service.getAll"
    }
    else{
        if($Filter.Name){
            $searchParameters = @{
                "name" = $Filter.Name
            } | ConvertTo-Json
        }
        $uri = "https://$($Session.ApplianceFQDN)/services/rest/$($env:A10ApiVersion)/?session_id=$($Session.Id)&format=$($Env:A10ApiFormat)&method=slb.virtual_service.search"
    }

    try {
        if($Filter.Name){
            Write-Verbose "Searching for $($Filter.Name)..."
            $response = Invoke-RestMethod `
                -Uri $uri `
                -Method Post `
                -Body $searchParameters
        }
        else {
            Write-Verbose "Attempting to get a list of virtual services..."
            $response = Invoke-RestMethod `
                -Uri $uri `
                -Method Get `
        }
    }
    catch {
        $error = $_
        $PSCmdlet.ThrowTerminatingError($error)
    }

    if($response){
        if($response.response.status -ne "fail"){
            if($Filter.Name){
                foreach($virtualService in $response.virtual_service){
                    if($virtualService.name -eq $Filter.Name){
                        Write-Verbose "Found virtual service $($Filter.Name)..."
                        Write-Output $virtualService
                    }
                }
            }
            else{
                Write-Verbose "Listing all virtual services..."
                Write-Output $response.virtual_service_list
            }
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