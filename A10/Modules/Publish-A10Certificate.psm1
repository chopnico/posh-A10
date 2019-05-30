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

function Publish-A10Certificate {
    [CmdletBinding()]
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
            ParameterSetName = "Base64",
            ValueFromPipeLine = $false,
            ValueFromPipeLineByPropertyName = $false)]
        [String]$Base64Certificate,

        [Parameter(
            Position = 2,
            Mandatory = $false,
            ParameterSetName = "Base64",
            ValueFromPipeLine = $false,
            ValueFromPipeLineByPropertyName = $false)]
        [string]$Base64PrivateKey,

        [Parameter(
            Position = 3,
            Mandatory = $true,
            ValueFromPipeLine = $false,
            ValueFromPipeLineByPropertyName = $false)]
        [String]$Name
    )

    $uri = "https://$($Session.ApplianceFQDN)/services/rest/$($env:A10ApiVersion)/?session_id=$($Session.Id)&format=$($Env:A10ApiFormat)&method=slb.ssl.upload"

    try {
        Write-Verbose "Attempting to upload certificate...."
        $boundary               = [System.Guid]::NewGuid().ToString()
        $encoding               = [System.Text.Encoding]::GetEncoding("iso-8859-1")
        $bytesBase64Certificate = $encoding.GetBytes($Base64Certificate)
        if($Base64PrivateKey){
            $bytesBase64PrivateKey  = $encoding.GetBytes($Base64PrivateKey)
        }

        $LF = "`r`n"

        $certBody = (
            "--$boundary",
            "Content-Disposition: form-data; name=`"Filename`"; filename=`"$($Name)`"",
            "Content-Type: application/octet-stream$LF",
            $encoding.GetString($bytesBase64Certificate),
            "--$boundary--$LF"
        ) -join $LF

        $response = Invoke-RestMethod `
            -Uri "$($uri)&type=certificate" `
            -ContentType "multipart/form-data; boundary=$boundary" `
            -Method Post `
            -Body $certBody

        if($Base64PrivateKey){
            $keyBody = (
                "--$boundary",
                "Content-Disposition: form-data; name=`"Filename`"; filename=`"$($Name)`"",
                "Content-Type: application/octet-stream$LF",
                $encoding.GetString($bytesBase64PrivateKey),
                "--$boundary--$LF"
            ) -join $LF

            $response = Invoke-RestMethod `
                -Uri "$($uri)&type=key" `
                -ContentType "multipart/form-data; boundary=$boundary" `
                -Method Post `
                -Body $keyBody
        }
    }
    catch {
        $error = $_
        $PSCmdlet.ThrowTerminatingError($error)
    }

    if($response){
        if($response.response.status -ne "fail"){
            Write-Verbose "Successfully uploaded certificate."
            $uploadedCertificate = Get-A10Certificate -Session $session -Filter @{ "FileName" = $Name }
            Write-Output $uploadedCertificate
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