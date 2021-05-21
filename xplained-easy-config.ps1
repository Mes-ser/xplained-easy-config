#
#
# TODO: wybieranie pliku avrosp.exe z archiwum
#
#
#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# imports
. .\VarFun.ps1

##### VARIABLES #####

# user defined variables
$AVRToolsPath = "C:\bin\AVR\temp"

# Don't touch this - www.youtube.com/watch?v=otCpCn0l4Wo
$RegisterPath = @{
                64="HKLM:\Software\WOW6432Node\Atmel\AVRTools";
                32="HKLM:\Software\Atmel\AVRTools\"
            }
$AVRKeyName = "AVRToolsPath"
$XMLDirName = "PartDescriptionFiles"
$AVROSPDirName = "avrosp"
$ScriptMsg = "Script Message"

# Pobieranie pliku
$AVROSPURL = "http://ww1.microchip.com/downloads/en/AppNotes/AVR911.zip"
$OutZipName = "avrosp.zip"
$avrospexe = 'avrosp.exe'

##### MAIN #####
# downloading AVR911 avrosp source
DownloadNetFile $AVROSPURL ($PSScriptRoot + "\\" + $OutZipName)
Start-Sleep 5
ProcessArchive $OutZipName $avrospexe


$RegisterPath = $RegisterPath[(Get-OSType)]

# Check if registry exists
if(Test-RegistryValue $RegisterPath $AVRKeyName) {
    $Key = Get-ItemPropertyValue -Path $RegisterPath -Name $AVRKeyName
    $Response = [System.Windows.Forms.MessageBox]::Show("It already have AVRTools `n PATH: $Key`n Do you want to continue?", $ScriptMsg, "YesNo", "Warning")
    if($Response -eq "Yes") {
        # Set new ItemProperty Value
        Set-ItemProperty -Path $RegisterPath -Name $AVRKeyName -Value $AVRToolsPath
    } else {
        Write-Host "Aborted"
        exit
    }
} else {
    # Create property in registry
    Write-Host "Creating property in registry..."
    New-Item $RegisterPath -force | New-Itemproperty -Name $AVRKeyName -Value $AVRToolsPath -force | Out-Null
    Write-Host "Created property!"
}

# Creating directory for XML files in $AVRToolsPath
$XMLDirPath = Join-Path $AVRToolsPath $XMLDirName
if(Test-Path -Path $XMLDirPath ) {
    $Response = [System.Windows.Forms.MessageBox]::Show("$($XMLDirName) already exists - Do you want to proceed?", $ScriptMsg, "YesNo", "Warning")
    if($Response -eq "Yes"){
        Copy-Item -Path $XMLDirName -Filter *.xml -Destination ($AVRToolsPath + $XMLDirName) -Recurse -Force
        Write-Host "Done - XML files copied to $($XMLDirName)"
    }
    
} else {
    New-Item -ItemType Directory -Force -Path $XMLDirPath
    Copy-Item -Path $XMLDirName -Filter *.xml -Destination ($AVRToolsPath + $XMLDirName) -Recurse -Force
    Write-Host "$($XMLDirName) added"
}

# coping AVRosp
$avrospPath = Join-Path $AVRToolsPath $AVROSPDirName
if(Test-Path -Path $avrospPath ) {
    if(Test-Path (Join-Path $avrospPath $avrospexe)){
        $Response = [System.Windows.Forms.MessageBox]::Show("$($avrospexe) already exists - Do you want to replace it anyway?", $ScriptMsg, "YesNo", "Warning")
        if($Response -eq "Yes"){
            Copy-Item $avrospexe -Destination $avrospPath
            Write-Host "$($avrospexe) successfully replaced"
        }
    }
    
} else {
    New-Item -ItemType Directory -Force -Path $avrospPath
    Copy-Item $avrospexe -Destination $avrospPath
    Write-Host "$($avrospexe) added"
}