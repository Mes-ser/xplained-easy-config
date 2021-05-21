$targetMCU = "ATmega1284p"
$hexFileName = "Test"
$comPort = "COM4"
$port = New-Object System.IO.Ports.SerialPort($comPort)
 
if($port.IsOpen){
    write-host "Port $comPort is already in use"
}else{
    write-host "Setting up xplained board"
    $port.BaudRate = 57600
    $port.Parity = [System.IO.Ports.Parity]"None"
    $port.StopBits = [System.IO.Ports.StopBits]"One"
    $port.DataBits = 8
    $port.Open()
    $port.Close()
    Write-Host "Put xplained into bootloader mode then press any key..."
    cmd /c pause | out-null
    avrosp "-d$targetMCU" "-c$comPort" -pf -vf -if".\Release\$hexFileName.hex" -e
}