#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="${REVIEW_ROOT:-$HOME/desktop/review}"
WIN_DIR="$ROOT/windows"
mkdir -p "$WIN_DIR"

command -v powershell.exe >/dev/null 2>&1 || { echo "ERROR: powershell.exe is not available from WSL."; exit 2; }
command -v wslpath >/dev/null 2>&1 || { echo "ERROR: wslpath is unavailable."; exit 2; }

# A VBS launcher keeps the WSL console hidden. The server itself opens the browser only after it is ready.
VBS="$WIN_DIR/launch_litnodex.vbs"
ROOT_ESC=${ROOT//\"/\"\"}
cat > "$VBS" <<EOF
Set shell = CreateObject("WScript.Shell")
cmd = "wsl.exe -e bash -lc ""cd '$ROOT_ESC' && ./scripts/start_review_app.sh"""
shell.Run cmd, 0, False
EOF

WIN_VBS=$(wslpath -w "$VBS")
WIN_ROOT=$(wslpath -w "$ROOT")
ICON="$ROOT/assets/litnodex.ico"
[[ -f "$ICON" ]] || { echo "ERROR: LitNodex icon is missing: $ICON"; exit 2; }
WIN_ICON=$(wslpath -w "$ICON")
PS1="$WIN_DIR/create_litnodex_shortcut.ps1"
cat > "$PS1" <<'PS'
param([string]$Launcher,[string]$WorkingDir,[string]$Icon)
$desktop = [Environment]::GetFolderPath('Desktop')
$oldShortcutPath = Join-Path $desktop 'Review Literature App.lnk'
if (Test-Path $oldShortcutPath) { Remove-Item $oldShortcutPath -Force -ErrorAction SilentlyContinue }
$legacyBrand = 'Folio' + 'Sort'
$legacyShortcutPath = Join-Path $desktop ($legacyBrand + '.lnk')
if (Test-Path $legacyShortcutPath) { Remove-Item $legacyShortcutPath -Force -ErrorAction SilentlyContinue }
$shortcutPath = Join-Path $desktop 'LitNodex.lnk'
$ws = New-Object -ComObject WScript.Shell
$s = $ws.CreateShortcut($shortcutPath)
$s.TargetPath = Join-Path $env:SystemRoot 'System32\wscript.exe'
$s.Arguments = '"' + $Launcher + '"'
$s.WorkingDirectory = $WorkingDir
$s.IconLocation = $Icon + ',0'
$s.Description = 'LitNodex local literature workspace'
$s.Save()
Write-Host "Created: $shortcutPath"
PS
WIN_PS1=$(wslpath -w "$PS1")
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$WIN_PS1" -Launcher "$WIN_VBS" -WorkingDir "$WIN_ROOT" -Icon "$WIN_ICON"

echo
echo "Windows launcher installed."
echo "Double-click 'LitNodex' on the Windows Desktop."
echo "Ubuntu does not need to be opened manually; WSL starts hidden in the background."
