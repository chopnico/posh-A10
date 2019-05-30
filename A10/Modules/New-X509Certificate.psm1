function Get-CertificateDetails {
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeLine = $false,
            ValueFromPipeLineByPropertyName = $false)]
        [String]$Base64Certificate
    )
    try {
        Write-Verbose "Attempting to create temporary certificate file..."
        $tempCertificateFile = New-TemporaryFile
        Set-Content $tempCertificateFile -Value $Base64Certificate.Trim()

        $x509Certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new()
        $x509Certificate.Import($tempCertificateFile.FullName)
        
        Write-Output $x509Certificate
    }
    catch{
        throw $_.Exception
    }
}