import serial
import time
port = 'COM4'
baudrate = 57600
timeout = 2
parityVal = serial.PARITY_NONE
bytesize = serial.EIGHTBITS

ser = serial.Serial()
ser.port = port
ser.baudrate = baudrate
ser.timeout = timeout
ser.parity = parityVal
ser.bytesize = bytesize
ser.writeTimeout = timeout
if(not ser.isOpen()):
    input("Put xplained board into Bootloader Mode then press any key...")
    ser.open()
    for i in range(0,10):
        ser.write(b'\x1b') # Wysylanie ESC char (DEC: 27, CHAR: \x1B) - Cal operacja synchronizuje nam MCU z PC
    ser.write(b'S') # Komenda 'S' dl programatora
    ser.flush()
    #for i in range(len(id)):
    #    id[i] = ser.read(1)
    print(ser.read(7).decode('utf-8'))
    ser.close()
    