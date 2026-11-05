# Starts the FigCraft desktop app with the control channel open (required for attach mode).
# Usage: powershell -ExecutionPolicy Bypass -File scripts\start-app.ps1
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$app = Join-Path $root "bin\figcraft.exe"
if (-not (Test-Path $app)) { Write-Error "bin\figcraft.exe not found — run scripts\fetch-cli.ps1 first" }
Start-Process $app -ArgumentList "--control", "7979"
Write-Host "FigCraft started with --control 7979"
