function Write-VenafiDriverLog {
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeLine = $false,
            ValueFromPipeLineByPropertyName = $false)]
        [String]$Source,

        [Parameter(
            Position = 1,
            Mandatory = $true,
            ValueFromPipeLine = $false,
            ValueFromPipeLineByPropertyName = $false)]
        [String]$Code,

        [Parameter(
            Position = 2,
            Mandatory = $true,
            ValueFromPipeLine = $false,
            ValueFromPipeLineByPropertyName = $false)]
        [String]$Message,

        [Parameter(
            Position = 3,
            Mandatory = $true,
            ValueFromPipeLine = $false,
            ValueFromPipeLineByPropertyName = $false)]
        [String]$Type,

        [Parameter(
            Position = 4,
            Mandatory = $true,
            ValueFromPipeLine = $false,
            ValueFromPipeLineByPropertyName = $false)]
        [String]$Location
    )

    try{
        $dateTime = $(Get-Date)
        $path = "$($Location)\$($dateTime.ToString("yyyy-MM-dd"))"

        if(-not $(Test-Path -Path $path)){
            $logFolder    = New-Item -Path $path -ItemType Directory
            $logFolderAcl = Get-Acl $logFolder
            $accessRule   = [System.Security.AccessControl.FileSystemAccessRule]::new("Everyone", "FullControl", "Allow")
        
            $logFolderAcl.SetAccessRule($accessRule)
            $logFolderAcl | Set-Acl -Path $path
        }
        $time = $dateTime.ToString("hh_mm_ss")
        $event = [Event]@{
            DateTime    = $dateTime
            Code        = $Code
            Type        = $Type
            Message     = $Message
            Source      = $Source
        }
        Out-File -FilePath "$($path)\$($Source)_$($time).txt" -InputObject $event
    }
    catch{
        throw $_.Exception
    }
}