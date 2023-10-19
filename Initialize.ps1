# Load classes
$classes = Get-ChildItem -Path $PSScriptRoot\Classes\*.ps1
ForEach($class in $classes){ 
    Write-Verbose "Importing classs $($class)"
    . $class.FullName
}

# Set some environment variables (global)
$env:A10ApiVersion        = "V2.1"
$env:A10ApiFormat         = "json"