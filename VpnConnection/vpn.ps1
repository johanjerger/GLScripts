# Recibe como parametro el destino al cual conectarse

param (
  [Parameter(Mandatory=$true)][string]$hostId
)

# Completar estas variables con los valores correspondientes.

$glUser = "***.***"
$glPass = "*******"
$glUrl  = "vpn-crr.globallogic.com"
$wtUser = "*******"
$wtPass = "*******"
$wtUrl  = "201.218.224.99"

# En caso de que exista una conexion previa, la elimina

Write-Host "Abortando conexiones previas`n"

$cysco = "C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe"
&$cysco disconnect

switch($hostId) {
  gl {
    $credential = $glUser + "`n" + $glPass + "`n"
    $credential  |  &$cysco -s connect $glUrl
    Write-Output "Ya estas conectado a gl como $gluser`n"
  }
  wt {
    $credential = "y`n1`n" + $wtUser + "`n" + $wtPass + "`n"
    $credential  | &$cysco -s connect $wtUrl
    Write-Output "Ya estas conectado a wt como $wtUser`n"
  }
  disconnect {
    Write-Output "Desconectado."
  }
  default {
    Write-Host $hostId " no es una opción valida"
    Write-Host "Pruebe alguna de las siguientes:"
    Write-Host "`t'gl'         - Conectarse a GlobalLogic"
    Write-Host "`t'wt'         - Conectarse a Ba*****co WT"
    Write-Host "`t'disconnect' - Desconectarse"
  }
}
