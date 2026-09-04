$zipUrl = "http://portal.arfab.kr/ARFabServices.zip"
$zipTarget = "C:\ARFabServices.zip"
$destDir = "C:\ARFabServices"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " [ARFab Portal] One-Click Automated Remote Setup for Target PC   " -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

Write-Host "`n[Step 1/3] Checking ARFab Services Package..." -ForegroundColor Yellow
if (Test-Path $zipTarget) {
    $sizeMB = [math]::Round((Get-Item $zipTarget).Length / 1MB, 2)
    Write-Host "Found existing package ($sizeMB MB) at $zipTarget. Skipping download!" -ForegroundColor Green
} else {
    Write-Host "Downloading package from $zipUrl..." -ForegroundColor Yellow
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($zipUrl, $zipTarget)
    Write-Host "Download completed successfully!" -ForegroundColor Green
}

Write-Host "`n[Step 2/3] Extracting package to $destDir..." -ForegroundColor Yellow
if (-not (Test-Path $destDir)) {
    New-Item -Path $destDir -ItemType Directory -Force | Out-Null
}

try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipTarget, $destDir)
} catch {
    Write-Host "Using Expand-Archive fallback..." -ForegroundColor Gray
    Expand-Archive -Path $zipTarget -DestinationPath $destDir -Force
}
Write-Host "Extraction completed successfully!" -ForegroundColor Green

Write-Host "`n[Step 3/3] Running Master Environment & Service Configuration..." -ForegroundColor Yellow
$installer = "$destDir\install_on_target.ps1"
if (Test-Path $installer) {
    & powershell.exe -ExecutionPolicy Bypass -File $installer
} else {
    Write-Error "Installer script not found at $installer"
}