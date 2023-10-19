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

function Get-A10Certificate {
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

    if(-not $Filter){
        $uri = "https://$($Session.ApplianceFQDN)/services/rest/$($env:A10ApiVersion)/?session_id=$($Session.Id)&format=$($Env:A10ApiFormat)&method=slb.ssl.getAll"
    }
    else{
        if($Filter.FileName){
            $searchParameters = @{
                "file_name" = $Filter.FileName
            } | ConvertTo-Json
        }
        $uri = "https://$($Session.ApplianceFQDN)/services/rest/$($env:A10ApiVersion)/?session_id=$($Session.Id)&format=$($Env:A10ApiFormat)&method=slb.ssl.search"
    }

    try {
        if($Filter.FileName){
            Write-Verbose "Searching for $($Filter.FileName)..."
            $response = Invoke-RestMethod `
                -Uri $uri `
                -Method Post `
                -Body $searchParameters
        }
        else {
            Write-Verbose "Attempting to get a list of SSL/TLS certificates..."
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
            if($Filter.FileName){
                foreach($file in $response.x509_file_list){
                    if($file.file_name -eq $Filter.FileName){
                        Write-Verbose " Found certificate $($Filter.FileName)..."
                        Write-Output $file
                    }
                }
            }
            else{
                Write-Verbose "Listing all certificates..."
                Write-Output $response.x509_file_list
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