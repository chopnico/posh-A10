class Logger {
    [DateTime]$DateTime
    [String]$ErrorMessage
    [String]$ErrorCode
    [String]$ErrorType
    [String]$ErrorSource
    [String]$Uri

    [void]WriteToWindowsEventLog(){
        Write-EventLog `
            -Source $This.ErrorSource `
            -LogName  "A10 Venafi Driver" `
            -EventId $This.ErrorCode `
            -Message $This.ErrorMessage `
            -EntryType $This.ErrorType `
    }

    [void]WriteToLogFile([String]$location){
        $logFolder = $This.createFolderByDate($location)
        $time      = $(Get-Date).ToString("hh_mm_ss")

        Out-File -FilePath "$($logFolder)\$($This.ErrorSource)_$($time).txt" -InputObject $This
    }

    hidden [string]createFolderByDate([string]$location){
        $date = $(Get-Date).ToString("yyyy-MM-dd")
        $path = "$($location)\$($date)"
        if(-not $(Test-Path -Path $path)){

            $logFolder    = New-Item -Path $path -ItemType Directory
            $logFolderAcl = Get-Acl $logFolder -Recurse
            $accessRule   = [System.Security.AccessControl.FileSystemAccessRule]::new("Everyone", "FullControl", "Allow")
        
            $logFolderAcl.SetAccessRule($accessRule)
            $logFolderAcl | Set-Acl -Path $path

            return $logFolder
        }
        return $path
    }
}