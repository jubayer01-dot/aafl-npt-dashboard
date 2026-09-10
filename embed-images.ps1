# Embed photo.jpg and Logo.png into index.html as base64 data URIs
# Usage: powershell -ExecutionPolicy Bypass -File embed-images.ps1
# Requires: AAFL\photo.jpg and AAFL\Logo.png in same folder
$ErrorActionPreference = "Stop"
$dir = $PSScriptRoot
if (-not $dir) { $dir = "AAFL" }
$htmlPath = Join-Path $dir "index.html"
$outPath  = Join-Path $dir "index-embedded.html"

if (-not (Test-Path $htmlPath)) { Write-Error "index.html not found at $htmlPath"; exit 1 }

$html = Get-Content -LiteralPath $htmlPath -Raw

function ToDataUri($file) {
  if (-not (Test-Path $file)) { Write-Warning "Missing $file — keeping original src"; return $null }
  $bytes = [IO.File]::ReadAllBytes($file)
  $b64 = [Convert]::ToBase64String($bytes)
  $ext = [IO.Path]::GetExtension($file).ToLower()
  $mime = switch ($ext) { ".png" {"image/png"} ".jpg" {"image/jpeg"} ".jpeg" {"image/jpeg"} default {"image/png"} }
  return "data:$mime;base64,$b64"
}

$photoUri = ToDataUri (Join-Path $dir "photo.jpg")
$logoUri  = ToDataUri (Join-Path $dir "Logo.png")

if ($photoUri) {
  # Replace <img src="photo.jpg" ...> with data URI
  $html = $html -replace 'src="photo\.jpg"', "src=`"$photoUri`""
  Write-Host "Embedded photo.jpg ($([math]::Round($photoUri.Length/1KB,1)) KB)"
} else { Write-Host "photo.jpg not found — avatar will show AAFL fallback" }

if ($logoUri) {
  $html = $html -replace 'src="Logo\.png"', "src=`"$logoUri`""
  Write-Host "Embedded Logo.png ($([math]::Round($logoUri.Length/1KB,1)) KB)"
} else { Write-Host "Logo.png not found — logo shows AKIJ RESOURCES text fallback" }

Set-Content -LiteralPath $outPath -Value $html -Encoding UTF8
Write-Host "Created $outPath — single-file embedded dashboard (no separate images needed)"
Write-Host "Open: $outPath  or  http://localhost:3001/index-embedded.html (after copying to server dir)"
