# Opens the FigCraft desktop app with its control channel on 127.0.0.1:7979 so the
# plugin's figcraft-live MCP server (figcraft-cli mcp --attach 7979) drives the
# visible window and you can watch the agent work. If the app is not installed,
# downloads the portable build into %LOCALAPPDATA%\FigCraft\app.
# Usage: powershell -ExecutionPolicy Bypass -File scripts\open-live.ps1
$ErrorActionPreference = "Stop"
$port = 7979
$appDir = Join-Path $env:LOCALAPPDATA "FigCraft\app"

$exe = $null
$candidates = @(
  (Join-Path $env:ProgramFiles "FigCraft\figcraft.exe"),
  $(if (${env:ProgramFiles(x86)}) { Join-Path ${env:ProgramFiles(x86)} "FigCraft\figcraft.exe" }),
  (Join-Path $env:LOCALAPPDATA "Programs\FigCraft\figcraft.exe")
)
foreach ($c in $candidates) { if ($c -and (Test-Path $c)) { $exe = $c; break } }
if (-not $exe -and (Test-Path $appDir)) {
  $exe = Get-ChildItem $appDir -Recurse -Filter figcraft.exe | Select-Object -First 1 -ExpandProperty FullName
}

if (-not $exe) {
  $release = Invoke-RestMethod "https://api.github.com/repos/storytold/figcraft/releases/latest"
  $tag = $release.tag_name
  $ver = $tag.TrimStart("v")
  $asset = "figcraft-$ver-windows-x64-portable.zip"
  Write-Host "figcraft.exe not found — downloading $asset ..."
  $zip = Join-Path $env:TEMP $asset
  Invoke-WebRequest -Uri "https://github.com/storytold/figcraft/releases/download/$tag/$asset" -OutFile $zip
  if (Test-Path $appDir) { Remove-Item -Recurse -Force $appDir }
  Expand-Archive -Path $zip -DestinationPath $appDir
  Remove-Item -Force $zip
  $exe = Get-ChildItem $appDir -Recurse -Filter figcraft.exe | Select-Object -First 1 -ExpandProperty FullName
  if (-not $exe) { throw "figcraft.exe not found in $asset" }
}

Start-Process $exe -ArgumentList "--control", "$port"
Write-Host "FigCraft app started with --control $port — the figcraft-live MCP server can now drive its window."
