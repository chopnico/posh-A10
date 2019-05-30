<#
.SYNOPSIS
    Creates a new A10 AXAPI session
.DESCRIPTION
    This function will create a new A10 AXAPI session that will be used for all subsequent A10 functions in this module.
.EXAMPLE
    New-A10Session -Username apiadmin -Password apiadmin -ApplianceFQDN lb.domain.local -Partition DMZ

    This will Write-Output a new [Session] containing the session ID and the partition name.
.NOTES
    General notes
#>
function New-A10Session {
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeLine = $false,
            ValueFromPipeLineByPropertyName = $false)]
        [String]$Username,

        [Parameter(
            Position = 1,
            Mandatory = $true,
            ValueFromPipeLine = $false,
            ValueFromPipeLineByPropertyName = $false)]
        [String]$Password,

        [Parameter(
            Position = 2,
            Mandatory = $true,
            ValueFromPipeLine = $false,
            ValueFromPipeLineByPropertyName = $false)]
        [String]$ApplianceFQDN,

        [Parameter(
            Position = 3,
            Mandatory = $true,
            ValueFromPipeLine = $false,
            ValueFromPipeLineByPropertyName = $false)]
        [String]$Partition
    )

    $response = $null
    $uri      = "https://$($ApplianceFQDN)/services/rest/$($env:A10ApiVersion)/?method=authenticate&format=$($Env:A10ApiFormat)&username=$($Username)&password=$($Password)"

    try {
        Write-Verbose "Attempting to authenticate..."
        $response = Invoke-RestMethod `
            -Uri $uri `
            -Method Post
    }
    catch {
        $error = $_
        $PSCmdlet.ThrowTerminatingError($error)
    }

    if($response){
        if($response.response.status -ne "fail"){

            Write-Verbose "Authenticated."
            $session = [Session]@{
                Id            = $response.session_id
                ApplianceFQDN = $ApplianceFQDN
                Partition     = $Partition
            }
            try{
                Set-A10Partition -Session $session -Partition $Partition | Out-Null
            }
            catch {
                $error = $_
                $PSCmdlet.ThrowTerminatingError($error)
            }
            Write-Output $session
        }
        else{
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