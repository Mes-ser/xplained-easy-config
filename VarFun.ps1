
##### FUNCTIONS ######

# Download AVROSP source
Function DownloadNetFile {
    param(
        [Alias("ZUrl")]
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$ZipUrl
        ,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$OutName
    )
    process {
        Invoke-WebRequest -Uri $ZipUrl -OutFile $OutName
    }
}

# Operation on zip archive
Function ProcessArchive {
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$ZipFile
        ,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$FileToExtract
    )
    process{
        Add-Type -Assembly System.IO.Compression.FileSystem
        $zip = [IO.Compression.ZipFile]::OpenRead($PSScriptRoot +"\\"+ $ZipFile)
        $zip.Entries | Where-Object {$_.Name -eq $FileToExtract} | ForEach-Object {[System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, $PSScriptRoot+"\"+$FileToExtract, $true)}
        $zip.Dispose()
    }

}

# Copied from https://stackoverflow.com/a/5652674
Function Test-RegistryValue {
    param(
        [Alias("PSPath")]
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Path
        ,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Name
        ,
        [Switch]$PassThru
    )
    process {
        if (Test-Path $Path) {
            $Key = Get-Item -LiteralPath $Path
            if ($Key.GetValue($Name, $null) -ne $null) {
                if ($PassThru) {
                    Get-ItemProperty $Path $Name
                } else {
                    $true
                }
            } else {
                $false
            }
        } else {
            $false
        }
    }
}

# Get OS type
Function Get-OSType{
    if((Get-WmiObject win32_operatingsystem | Select-Object osarchitecture).osarchitecture -eq "64-bit") {
        return 64
    } else {
        return 32
    }
}