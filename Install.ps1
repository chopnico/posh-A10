<#
.SYNOPSIS
    Installs the A10 Venafi Driver
.DESCRIPTION
    This script installs the A10 Venafi Driver. It essentially copies the driver to the appropriate folder. It will also create new Windows Event Log sources and log file.
.EXAMPLE
    Install.ps1 -InstallLocation "C:\Program Files\Venafi\Scripts\AdaptableApp" -LogLocation "C:\Venafi Driver Logs\A10"
    
    This will install the driver to "InstallLocation" and will create the root log folder for the driver at "LogLocation"
.NOTES
    This script MUST be ran as Administrator.
#>

param(
    [Parameter(
        Position = 0,
        Mandatory = $false,
        ValueFromPipeLine = $false,
        ValueFromPipeLineByPropertyName = $false)]
    [String]$InstallLocation="C:\Program Files\Venafi\Scripts\AdaptableApp",

    [Parameter(
        Position = 0,
        Mandatory = $false,
        ValueFromPipeLine = $false,
        ValueFromPipeLineByPropertyName = $false)]
    [String]$LogLocation="C:\Venafi Driver Logs\A10"
)

# Get a list of modules
If(Test-Path "A10/Modules"){
    $modules = $(Get-ChildItem "A10/Modules").Name.Replace(".psm1", "")
}

# Install the A10 Venafi Driver
If(Test-Path $InstallLocation){
    Write-Verbose "Installing the A10 Venafi Driver..."
    Copy-Item -Force -Path "A10.ps1" -Destination "$($InstallLocation)\"
    Copy-Item -Force -Recurse -Path "A10" -Destination "$($InstallLocation)\"
}

# Create Windows event log sources and log file
If($modules){
    If($modules.Length -ne 0){
        foreach($module in $modules){
            Write-Verbose "Creating log source $($module)..."
            New-EventLog -LogName "A10 Venafi Driver" -Source $module -ErrorAction SilentlyContinue
        }
    }
}

# Create log folder if it doesn't exist
If(-not $(Test-Path -Path $LogLocation)){
    Write-Verbose "Creating log folder $($LogLocation)..."

    $logFolder    = New-Item -Path $LogLocation -ItemType Directory
    $logFolderAcl = Get-Acl $logFolder -Force -Recurse
    $accessRule   = [System.Security.AccessControl.FileSystemAccessRule]::new("Everyone", "FullControl", "Allow")

    $logFolderAcl.SetAccessRule($accessRule)
    $logFolderAcl | Set-Acl -Path $LogLocation 
}