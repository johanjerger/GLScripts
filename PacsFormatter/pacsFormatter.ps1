# Recibe la carpeta que se desea formatear
# la carpeta deseada SOLO TIENE QUE CONTENER el archivo de actualizacion

param (
  [Parameter(Mandatory=$true)][string]$path
)

$zipName = (Get-ChildItem -Path $path)
$fileCount = $zipName | Measure-Object

if ($fileCount.Count -gt 1) {
  Write-Host "La carpeta indicada SOLO debe contener el comprimido de la actualizacion."
  exit
}

$zipPath = $zipName.FullName
$path = $zipName.DirectoryName + '\'

# Extrae el archivo de la actualizacion

$extractedFolder = $path + $zipName.BaseName
Write-Host "Extrayendo " $zipName.Name " en " $extractedFolder "`n"
Expand-Archive $zipPath $path

# Mueve el contenido de todas las carpetas extraidas a la carpeta principal

$pacsList = (Get-ChildItem -Path $extractedFolder)

$pacsList | ForEach-Object -process {
  Write-Host "Extrayendo " $_.Name
  $folderToMove = $extractedFolder + '\' + $_.Name + '\*'
  Move-Item $folderToMove $extractedFolder -Force
  $folderToRemove = $extractedFolder + '\' + $_.Name
  Remove-Item $folderToRemove
}

# Se obtiene el listado de todos los archivos obtenidos

$fileList = Get-ChildItem $extractedFolder

# Se generan las carpetas resultado

$insertFolder  = $extractedFolder + '\inserts\'
$docsFolder    = $extractedFolder + '\docs\'
$jarsFolder    = $extractedFolder + '\jars\'
$bconFolder    = $extractedFolder + '\bcon\'
$updatesFolder = $extractedFolder + '\updates\'
$othersFolder  = $extractedFolder + '\others\'

$resultFolders = $insertFolder, $docsFolder, $jarsFolder, $bconFolder, $updatesFolder, $othersFolder

$resultFolders | ForEach-Object -process {
  New-Item $_ -ItemType "directory"
}

# Itera sobre todos los archivos moviendolos a su directorio correspondiente

$fileList | ForEach-Object -process {
  $extension = $_.Extension
  $fileToNest = $extractedFolder + '\' + $_.Name

  switch ($extension) {
    {$fileToNest -match "INSERTS.jar"} {
      Move-Item $fileToNest $insertFolder -Force
      continue
    }
    {$fileToNest -match "INSERT.jar"} {
      Move-Item $fileToNest $insertFolder -Force
      continue
    }
    {$fileToNest -match "T24Updates"} {
      Move-Item $fileToNest $updatesFolder -Force
      continue
    }
    .jar {
      Move-Item $fileToNest $jarsFolder -Force
    }
    {$_ -in ".doc", ".docx"} {
      Move-Item $fileToNest $docsFolder -Force
    }
    {$_ -in ".tar", ".gz"} {
      Move-Item $fileToNest $bconFolder -Force
    }
    default {
      Move-Item $fileToNest $othersFolder -Force
    }
  }
}

# Extrae las carpetas de los BCONs en caso de que haya

$winrar = "C:\Program Files (x86)\WinRAR\WinRAR.exe"

$directoryCount = Get-ChildItem $bconFolder | Measure-Object
if ($directoryCount.count -gt 0) {

  Write-Host "`nExtrayendo BCONs..."
  $bconFileList = Get-ChildItem $bconFolder

  $bconFileList | ForEach-Object -process {
    $bconToExpand = $bconFolder + $_
    $outputFolder = $bconFolder + $_.Name
    &$winrar x -y -ibck $bconToExpand $bconFolder
    Get-Process winrar | Wait-Process
    Remove-Item $bconToExpand
  }

# Genera un listado de BCONs

  Write-Host "`nGenerando listado..."
  $bconFileList = Get-ChildItem $bconFolder

  $bconFileList | ForEach-Object -process {
    $bconName       = $_.Name + "`n"
    $outputListFile = $bconFolder + "\LISTA"
    echo $bconName >> $outputListFile
  }

}

<# DEPRECADO
# Extrae los archivos de los Insert

Write-Host "`nExtrayendo INSERTS..."
$insertFileList = Get-ChildItem $insertFolder

$insertFileList | ForEach-Object -process {
  $insertToExpand = $insertFolder + $_
  $outputFolder = $insertFolder + $_.Name
  &$winrar x -y -ibck $insertToExpand $insertFolder
  Get-Process winrar | Wait-Process
}
#>

# Desacopla los instert en una sola carpeta y elimina META-INF

$metaInf = $insertFolder + '\' + 'META-INF'
if ((Test-Path -Path $metaInf)) {
  Remove-Item $metaInf -Force -Recurse
}

$insertSubFolder = $insertFolder + '\' + 'INSERTS'
if ((Test-Path -Path $insertSubFolder)) {
  $insertsList = (Get-ChildItem -Path $insertSubFolder)

  $folderToMove = $insertSubFolder + '\*'
  Move-Item $folderToMove $insertFolder -Force
  Remove-Item $insertSubFolder -Force
}

# Remueve Carpetas innecesarias

Write-Host "`nEliminando carpetas innecesarias"

$resultFolders | ForEach-Object -process {
  $directoryCount = Get-ChildItem $_ | Measure-Object
  if ($directoryCount.count -eq 0) {
    Remove-Item $_
  }
}

Write-Host "`nProceso Completado."
