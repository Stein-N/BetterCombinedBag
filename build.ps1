# --- Konfiguration ---
$addonName = "BetterCombinedBag"
$sourceFiles = Get-ChildItem -Path . -Recurse -Include *.lua, *.toc -File

$destinationFolder = "./build"

Write-Host "Read version from '$addonName.toc'..."
$version = ""
try {
    $versionLine = Get-Content "$addonName.toc" | Where-Object { $_ -match "^\s*##\s*Version:" }

    if ($versionLine) {
        $version = ($versionLine -split ":")[1].Trim()
        Write-Host "Version found: $version"
    } else {
        $version = "0.0.0-dev"
        Write-Warning "No '## Version:' found in .toc-Datei. Using '$version' as fallback"
    }
} catch {
    $version = "error-no-toc-found"
    Write-Error "Error while reading '$addonName.toc'. Task will be terminated"
    return
}

$zipFile = "./build/$($addonName)-$($version).zip"
Write-Host "ZIP-Archive name: '$zipFile'"

if (Test-Path $destinationFolder) {
    Remove-Item -Recurse -Force $destinationFolder
}
New-Item -ItemType Directory -Force -Path $destinationFolder

foreach ($item in $sourceFiles) {
    $finalDestination = Join-Path $destinationFolder $addonName
    if (-not (Test-Path $finalDestination)) {
        New-Item -ItemType Directory -Force -Path $finalDestination
    }

    Copy-Item -Path $item -Destination $finalDestination -Recurse
    Write-Host "Copy '$item' to '$finalDestination'"
}

if (Test-Path $zipFile) {
    Remove-Item $zipFile
}

Compress-Archive -Path "$destinationFolder/$addonName" -DestinationPath $zipFile

Write-Host "Delete temporary data..."
Remove-Item -Recurse -Force $finalDestination

Write-Host "ZIP-Archive created: $zipFile"