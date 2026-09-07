param([string]$Launcher,[string]$WorkingDir)
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
$s.IconLocation = (Join-Path $env:SystemRoot 'System32\shell32.dll') + ',220'
$s.Description = 'LitNodex local literature workspace'
$s.Save()
Write-Host "Created: $shortcutPath"
