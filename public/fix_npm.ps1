[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " [ARFab Portal] Restoring Node.js (NPM) Dependencies...         " -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
$npm = "C:\Program Files\nodejs\npm.cmd"

if (-not (Test-Path $npm)) {
    Write-Warning "npm not found at $npm, trying fallback from PATH..."
    $npm = "npm"
}

$projects = @(
    "C:\ARFabServices\AI솔루션포털",
    "C:\ARFabServices\창업관련\mentor-matching",
    "C:\ARFabServices\창업관련\유학생창업동아리\startup-club-manager",
    "C:\ARFabServices\B-Bridge",
    "C:\ARFabServices\Idea2Real\MDConversion\frontend",
    "C:\ARFabServices\Idea2Real\MD2HTMLDOCPDF\frontend",
    "C:\ARFabServices\ARFab"
)

foreach ($p in $projects) {
    if (Test-Path $p) {
        Write-Host "`n-> Installing npm packages in $p..." -ForegroundColor Yellow
        Push-Location $p
        & $npm install --legacy-peer-deps --loglevel=error
        Pop-Location
    } else {
        Write-Warning "Directory not found: $p"
    }
}

Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host " [ARFab Portal] All Dependencies Installed! Restarting Services..." -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

Stop-ScheduledTask -TaskName "ARFab_Portal_Autostart" -ErrorAction SilentlyContinue
Start-ScheduledTask -TaskName "ARFab_Portal_Autostart"

Write-Host "`nServices restarted successfully! Check http://portal.arfab.kr" -ForegroundColor Green