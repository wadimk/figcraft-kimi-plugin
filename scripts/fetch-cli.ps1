# Downloads the FigCraft CLI (Windows x64) and installs it into %LOCALAPPDATA%\FigCraft\bin —
# outside the plugin package, because the binary exceeds the plugin single-file size
# limit and breaks plugin registration. The manifest must keep a relative command
# (absolute paths are dropped on registration), so bin\figcraft-cli.cmd is a small
# wrapper that calls the real binary.
# Usage: powershell -ExecutionPolicy Bypass -File scripts\fetch-cli.ps1
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$installDir = Join-Path $env:LOCALAPPDATA "FigCraft\bin"
New-Item -ItemType Directory -Force -Path $installDir | Out-Null
$cliPath = Join-Path $installDir "figcraft-cli.exe"

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
Copy-Item (Join-Path $tmp "figcraft-$ver-windows-x64-portable\figcraft-cli.exe") $cliPath
Remove-Item -Recurse -Force $tmp, $zip

# Recreate bin\ with just the wrapper (also clears the big binary left by older installs).
$bin = Join-Path $root "bin"
if (Test-Path $bin) { Remove-Item -Recurse -Force $bin }
New-Item -ItemType Directory -Force -Path $bin | Out-Null
$wrapper = Join-Path $bin "figcraft-cli.cmd"
[System.IO.File]::WriteAllText($wrapper, "@echo off`r`n`"%LOCALAPPDATA%\FigCraft\bin\figcraft-cli.exe`" %*`r`n")

# The manifest command must stay relative — absolute paths are dropped on registration.
$manifest = Join-Path $root "kimi.plugin.json"
$content = (Get-Content $manifest -Raw) -replace '"command":\s*"[^"]*"', '"command": "./bin/figcraft-cli.cmd"'
[System.IO.File]::WriteAllText($manifest, $content)

Write-Host "Done: $cliPath ($tag)"
& $cliPath --version
