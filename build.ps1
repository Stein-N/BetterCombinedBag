# --- Konfiguration ---
$addonName = "BetterCombinedBag"
$sourceFiles = Get-ChildItem -Path . -Recurse -Include *.lua, *.toc -File

$destinationFolder = "./build"

Write-Host "Lese Version aus '$addonName.toc'..."
$version = ""
try {
    $versionLine = Get-Content "$addonName.toc" | Where-Object { $_ -match "^\s*##\s*Version:" }

    if ($versionLine) {
        $version = ($versionLine -split ":")[1].Trim()
        Write-Host "✅ Version gefunden: $version"
    } else {
        $version = "0.0.0-dev"
        Write-Warning "Keine '## Version:' Zeile in der .toc-Datei gefunden. Verwende '$version' als Fallback."
    }
} catch {
    $version = "error-no-toc-found"
    Write-Error "Fehler beim Lesen der .toc-Datei unter '$addonName.toc'. Breche ab."
    return
}

$zipFile = "./build/$($addonName)-$($version).zip"
Write-Host "Der Name des ZIP-Archivs wird sein: '$zipFile'"

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
    Write-Host "Kopiere '$item' nach '$finalDestination'"
}

if (Test-Path $zipFile) {
    Remove-Item $zipFile
}

Compress-Archive -Path "$destinationFolder/$addonName" -DestinationPath $zipFile

Write-Host "Räume temporäre Dateien auf..."
Remove-Item -Recurse -Force $finalDestination

Write-Host "ZIP-Archiv erstellt unter: $zipFile"