# Extracts all vscodium version that can be found in local directory.
#
# Example:
# - VSCodium-win32-ia32-1.28.2.zip
# - VSCodium-win32-x64-1.28.2.zip

$files = Get-ChildItem | Where-Object { $_.Name -match "^VSCodium-win32-(?<platform>(x64|ia32))-(?<version>\d+\.\d+\.\d+)\.zip$" }
$version = $($Matches.version)
$files | Foreach-Object {
  if ($_.Name -match "(?<version>\d+\.\d+\.\d+)" -and $_.Name -match "(?<platform>(x64|ia32))") {
    Expand-Archive -Path $_.Name -DestinationPath ".\$($version)\$($Matches.platform)"
  }
}
mv ".\$($version)\ia32" ".\$($version)\x86"