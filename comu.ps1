
$MyPortName="COM3"

function Send-HexSerialData {
    param (
        [Parameter(Mandatory=$true)]
        [string]$PortName,
        
        [Parameter(Mandatory=$true)]
        [byte[]]$hexData
    )

    try {
        # Crear una nueva instancia del objeto SerialPort
        $serialPort = New-Object System.IO.Ports.SerialPort
        $serialPort.PortName = $PortName
        $serialPort.BaudRate = 4800
        $serialPort.DataBits = 8
        $serialPort.StopBits = 1
        $serialPort.Parity = "None"
       # $serialPort.Handshake = System.IO.Ports.HandshakeType.None
        
        # Abrir la conexión serial
        $serialPort.Open()
        
        Write-Host "$($hexData.Count)"
       
     
        $serialPort.BaseStream.Write($hexData, 0, $hexData.Length)

        Start-Sleep -Milliseconds 100
        
        # Cerrar la conexión
        $serialPort.Close()
        
        Write-Host "Datos enviados exitosamente"
    }
    catch {
        Write-Host "Error al enviar datos: $_"
    }
}


function GeneraTrama{
      param (
            [Parameter(Mandatory=$true)]
            [string]$Datos)

       $bytestosend=New-Object byte[] 0


#HEADER       
       $bytestosend+=0x16
       $num_bytes=$datos.Length+2+5+1 #checksum+header+datos+null 
       $bytestosend+=[byte]($num_bytes%256)
       $bytestosend+=[byte]($num_bytes/256)
       $bytestosend+=0x01
       $bytestosend+=0x27

#DATOS
        for ($i = 0; $i -lt $Datos.Length; $i++) {
            $char = $Datos[$i]
            $bytestosend+=[byte]($char)
       
        }
        
        $bytestosend+=0


#CHECKSUM
        $checksum=0
        foreach($mybyte in $bytestosend)
        {
            $checksum+=$mybyte
        }
       $bytestosend+=[byte]($checksum%256)
       $bytestosend+=[byte]($checksum/256)
     return $bytestosend
}

function GeneraTramaScroll{
      param (
            [Parameter(Mandatory=$true)]
            [string]$Datos)

       $bytestosend=New-Object byte[] 0


#HEADER       
       $bytestosend+=0x16
       $num_bytes=$datos.Length+2+5+7+1 #checksum+header+datos+7scroll 
       $bytestosend+=[byte]($num_bytes%256)
       $bytestosend+=[byte]($num_bytes/256)
       $bytestosend+=0x01
       $bytestosend+=0x27

       #scroll
       $bytestosend+=0x03
       $bytestosend+=0xC7
       $bytestosend+=0x31
       $bytestosend+=0x2C
       $bytestosend+=0x31
       $bytestosend+=0x04
       $bytestosend+=0xE0
      

#DATOS
        for ($i = 0; $i -lt $Datos.Length; $i++) {
            $char = $Datos[$i]
            $bytestosend+=[byte]($char)
       
        }
        
        $bytestosend+=0


#CHECKSUM
        $checksum=0
        foreach($mybyte in $bytestosend)
        {
            $checksum+=$mybyte
        }
       $bytestosend+=[byte]($checksum%256)
       $bytestosend+=[byte]($checksum/256)
     return $bytestosend
}






 
function TestDisplay
{
    Send-HexSerialData -PortName $MyPortName -HexData $test_display
}    




function EnviarMsg{
      param (
            [Parameter(Mandatory=$true)]
            [string]$Msg)
     Send-HexSerialData -PortName $MyPortName -hexData (GeneraTrama -Datos $Msg)
    
}


function EnviarMsgScroll{
      param (
            [Parameter(Mandatory=$true)]
            [string]$Msg)
     Send-HexSerialData -PortName $MyPortName -hexData (GeneraTramaScroll -Datos $Msg)
}




function EnviarMsgScrollPausa{
      param (
            [Parameter(Mandatory=$true)]
            [string]$Msg)
     Send-HexSerialData -PortName $MyPortName -hexData (GeneraTramaScroll -Datos $Msg)
     Start-Sleep -Seconds 2
     Send-HexSerialData -PortName $MyPortName -HexData $stopclear
     Start-Sleep -Milliseconds 2500
}



function EnviarMsgParpadeo{
      param (
            [Parameter(Mandatory=$true)]
            [string]$Msg)
     Send-HexSerialData -PortName $MyPortName -hexData (GeneraTramaParpadeo -Datos $Msg)
}



$test_display = @(0x16,0x07,0x00,0x01,0x3C,0x5A,0x00)
$stop=@(0x16,0x07,0x00,0x01,0x03,0x21,0x00)
$scriptScroll=@(0x16,0x10,0x00,0x01,0x27,0x03,0xC7,0x31,0x2C,0x31,0x04,0xE0,0x4D,0x50,0x27,0x03)
$stopclear =@(0x16,0x07,0x00,0x01,0xA1,0xBF,0x00)


TestDisplay
Start-Sleep -Seconds 8

EnviarMsg("hola")
Start-Sleep -Seconds 2


#Contador

for($i=0;$i -le 20;$i++)
{
   EnviarMsg($i)
   Start-Sleep -Seconds 1      
}


EnviarMsgScroll("casa")
Start-Sleep -Seconds 6

EnviarMsgScrollPausa("DS23")
EnviarMsgScrollPausa("AB44")


#EnviarMsgScroll("Informatica")

