# Recibe como parametro el destino al cual conectarse

param (
  [Parameter(Mandatory=$true)][string]$hostId
)

# Completar estas variables con los valores correspondientes.

$glUser = "***********"
$glPass = "***********"
$glUrl  = "vpn-crr.globallogic.com"
$wtUser = "***********"
$wtPass = "***********"
$wtUrl  = "201.218.224.99"

$cysco = "C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe"

# En caso de que exista una conexión previa, la elimina

$state = &$cysco state
if ($state -match ">> state: Connected") {
  Write-Host "Abortando conexiones previas`n"
  &$cysco disconnect 2>&1 | Out-Null
}

switch($hostId) {
  gl {
    Write-Host "Esta conexion requiere un segundo factor de autenticacion."
    Write-Host "El mismo debe ser generado mediante la aplicacion Duo Mobile o solicitud de correo."
    $glDual = Read-Host -Prompt 'Ingrese segundo factor'
    Write-host "Conectando..."
    $credential = $glUser + "`n" + $glPass + "`n" + $glDual + "`n"
    $credential  |  &$cysco -s connect $glUrl 2>&1 | Out-Null
  }
  wt {
    Write-host "Conectando..."
    $credential = "y`n7`n" + $wtUser + "`n" + $wtPass + "`n"
    $credential  | &$cysco -s connect $wtUrl 2>&1 | Out-Null
  }
  disconnect {
    Write-Output "Se encuentra desconectado."
  }
  default {
    Write-Host $hostId " no es una opcion valida"
    Write-Host "Pruebe alguna de las siguientes:"
    Write-Host "`t'gl'         - Conectarse a GlobalLogic"
    Write-Host "`t'wt'         - Conectarse a Ba*****co WT"
    Write-Host "`t'disconnect' - Desconectarse"
  }
}

# Se valida que la conexión se haya realizado con exito

$state = &$cysco state
if ($state -match ">> state: Connected") {
  Write-Output "`nSe encuentra conectado!`n"
} else {
  Write-Output "Se encuentra desconectado, revise la configuracion de la vpn.`n"
}
