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

function Get-A10ClientSslTemplate {
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
        [hashtable]$Filter
    )

    if(-not $Filter){
        $uri = "https://$($Session.ApplianceFQDN)/services/rest/$($env:A10ApiVersion)/?session_id=$($Session.Id)&format=$($Env:A10ApiFormat)&method=slb.template.client_ssl.getAll"
    }
    else{
        $uri = "https://$($Session.ApplianceFQDN)/services/rest/$($env:A10ApiVersion)/?session_id=$($Session.Id)&format=$($Env:A10ApiFormat)&method=slb.template.client_ssl.search"
    }

    try {
        if(-not $Filter){
            Write-Verbose "URI: $uri"
            Write-Verbose "Attempting to get a list of SSL/TLS certificates..."

            $response = Invoke-RestMethod `
                -Uri $uri `
                -Method Get `
        }
        else{
            Write-Verbose "URI: $uri"
            Write-Verbose "Searching for $FilterByName..."

            $response = Invoke-RestMethod `
                -Uri $uri `
                -Method Post `
                -Body $Filter | ConvertTo-Json
        }
    }
    catch {
        $error = $_
        $PSCmdlet.ThrowTerminatingError($error)
    }

    if($response){
        if($response.response.status -ne "fail"){
            if($Filter.name){
                foreach($template in $response.client_ssl_template){
                    if($template.name -eq $FilterByName){
                        Write-Verbose "Found client SSL template $FilterByName..."
                        Write-Output $response.client_ssl_template
                    }
                }
            }
            else{
                Write-Verbose "Result count: $($response.client_ssl_template.count)"
                Write-Output $response.client_ssl_template_list
            }
        }
        elseif($response.response.err.msg.Trim() -eq "No such Template"){
            Write-Verbose "No such template."
            Write-Output $response
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