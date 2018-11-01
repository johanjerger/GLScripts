# Descripción

Script generado para realizar el cambio de vpn de una forma mas fluida, dado que Cisco AnyConnect no permite multiples vpn de forma simultanea.

## Requiere

  - Cisco AnyConnect.

## Uso

  Llamar al Script indicando alguna de las opciones disponibles:

  - gl         - Conectarse a GlobalLogic
  - wt         - Conectarse a Ba*****co WT
  - disconnect - Desconectar VPN

  Si se alterna entre una VPN y la otra la desconexión se realizará de forma automatica.

## Configuración

  Abrir el archivo vpn.ps1 e indicar el valor del usuario y la contraseña tanto para gl como para wt.

  ```
    $glUser = "***.***"
    $glPass = "*******"
    $glUrl  = "vpn-crr.globallogic.com"
    $wtUser = "*******"
    $wtPass = "*******"
    $wtUrl  = "201.218.224.99"
  ```
