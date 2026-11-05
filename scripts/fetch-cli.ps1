# Downloads the FigCraft CLI (Windows x64) into ./bin and points the plugin manifest at it.
# Usage: powershell -ExecutionPolicy Bypass -File scripts\fetch-cli.ps1
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$bin = Join-Path $root "bin"
New-Item -ItemType Directory -Force -Path $bin | Out-Null

$release = Invoke-RestMethod "https://api.github.com/repos/storytold/figcraft/releases/latest"
$tag = $release.tag_name
$ver = $tag.TrimStart("v")
$asset = "figcraft-$ver-windows-x64-portable.zip"
$url = "https://github.com/storytold/figcraft/releases/download/$tag/$asset"
$zip = Join-Path $env:TEMP $asset

Write-Host "Downloading $asset ..."
Invoke-WebRequest -Uri $url -OutFile $zip
$tmp = Join-Path $env:TEMP "figcraft-extract"
if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
Expand-Archive -Path $zip -DestinationPath $tmp
Copy-Item (Join-Path $tmp "figcraft-$ver-windows-x64-portable\figcraft-cli.exe") (Join-Path $bin "figcraft-cli.exe")
Remove-Item -Recurse -Force $tmp, $zip

# Manifest already references ./bin/figcraft-cli.exe — nothing to patch.
Write-Host "Done: bin\figcraft-cli.exe ($tag)"
& (Join-Path $bin "figcraft-cli.exe") --version
