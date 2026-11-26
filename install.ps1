# Installs the Halo theme into Herdr (Windows). Files it would replace are moved to a backup folder.
param(
  [switch]$SinSonidos,   # keep your current sounds
  [switch]$NoActivar     # install without switching to the layout
)
$ErrorActionPreference = "Stop"
$src = $PSScriptRoot
$dest = if ($env:HERDR_APP_HOME) { $env:HERDR_APP_HOME } else { Join-Path $HOME ".config\herdr-app" }
if (-not (Test-Path $dest)) { throw "No existe $dest. Instala y abre Herdr una vez antes de continuar." }
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backup = Join-Path $dest "backup-halo-$stamp"

$items = "themes\halo.json", "backgrounds\halo.jpg", "backgrounds\halo-infinite.jpg", "icons\halo", "sounds\halo-done.mp3",
         "sounds\halo-blocked.mp3", "mods\halo-agents", "mods\halo-spaces", "layouts\halo.svg",
         "layouts\halo.json"
foreach ($item in $items) {
  $from = Join-Path $src $item
  $to = Join-Path $dest $item
  if (Test-Path $to) {
    $old = Join-Path $backup $item
    New-Item -ItemType Directory -Force (Split-Path $old) | Out-Null
    Move-Item $to $old
  }
  New-Item -ItemType Directory -Force (Split-Path $to) | Out-Null
  Copy-Item -Recurse $from $to
  Write-Host "copiado  $item"
}
if (Test-Path $backup) { Write-Host "Lo que ya existia quedo en: $backup" }

if (-not $SinSonidos) {
  $file = Join-Path $dest "settings.json"
  try {
    $settings = $null
    if (Test-Path $file) {
      Copy-Item $file "$file.antes-de-halo-$stamp"
      $settings = Get-Content -Raw -Encoding UTF8 $file | ConvertFrom-Json
    }
    if ($null -eq $settings) { $settings = New-Object psobject }
    if ($null -eq $settings.sounds) {
      $settings | Add-Member -Force NoteProperty sounds ([pscustomobject]@{ enabled = $true })
    }
    $settings.sounds | Add-Member -Force NoteProperty done "sounds/halo-done.mp3"
    $settings.sounds | Add-Member -Force NoteProperty blocked "sounds/halo-blocked.mp3"
    $json = $settings | ConvertTo-Json -Depth 20
    [IO.File]::WriteAllText($file, $json, (New-Object Text.UTF8Encoding $false))
    Write-Host "sonidos configurados en settings.json"
  } catch {
    Write-Warning "No pude editar settings.json ($($_.Exception.Message)). Agrega los sonidos a mano: ver README."
  }
}

if (-not $NoActivar) {
  if (Get-Command herdr-app -ErrorAction SilentlyContinue) {
    herdr-app do layout.switch --name halo
    if ($LASTEXITCODE -ne 0) { Write-Warning "Abre Herdr y elige el layout 'halo' en Settings." }
  } else {
    Write-Warning "No encontre 'herdr-app' en el PATH. Elige el layout 'halo' en Settings."
  }
}
Write-Host "Listo."
