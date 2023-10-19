<#
.SYNOPSIS
    Set the working A10 Partition
.DESCRIPTION
    This module will attempt to change the current working partition to the one specified. After it's been set, every call thereafter will be working in 
    the context of the specified partition. By default your current partition will be set to shared.
.EXAMPLE
    New-A10Session -Username apiadmin -Password apiadmin -ApplianceFQDN lb.domain.local -Partition DMZ

    This will Write-Output a new [Session] containing the session ID and the partition name.
.NOTES
    General notes
#>
function Set-A10Partition {
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
        [String]$Partition="shared"
    )

    $response = $null
    $uri      = "https://$($Session.ApplianceFQDN)/services/rest/$($env:A10ApiVersion)/?session_id=$($Session.Id)&format=$($Env:A10ApiFormat)&method=system.partition.active"

    try {
        Write-Verbose "Attempting to set partition..."
        $body = @{
            "name" = $Partition
        }

        $response = Invoke-RestMethod `
            -Uri $uri `
            -Body ($body | ConvertTo-Json) `
            -Method Post
    }
    catch {
        $error = $_
        throw $error
    }

    if($response){
        if($response.response.status -ne "fail"){
            Write-Verbose "Partition set to $($Partition)"
        }
        else{
            $error = $response.response.err
            throw $error | ConvertTo-Json -Depth 100
        }
    }
}