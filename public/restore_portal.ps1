# ==============================================================================
# [ARFab Portal & Equipment Recovery Script]
# 포털(3000번) 및 장비시스템(8000번), 게이트웨이(80번) 일괄 정상화
# ==============================================================================

$portalDir = "C:\ARFabServices\AI솔루션포털"
$equipDir = "C:\ARFabServices\EquipmentBookingSystem"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "🔧 ARFab 포털(3000) 및 장비(8000) 서비스 상태 복구 중..." -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

# 1. 포털 서비스 (3000번) 확인 및 기동
$p3000 = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue
if ($p3000) {
    Write-Host "✅ 포털 서비스(3000번) 이미 가동 중" -ForegroundColor Green
} else {
    Write-Host "🚀 포털 서비스(3000번) 시작 중..." -ForegroundColor Yellow
    if (Test-Path "$portalDir\_start_portal_service.bat") {
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c call `"$portalDir\_start_portal_service.bat`"" -WorkingDirectory $portalDir -WindowStyle Hidden
    } else {
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c npm run dev" -WorkingDirectory $portalDir -WindowStyle Hidden
    }
}

# 2. 장비 서비스 (8000번) 확인 및 기동
$p8000 = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue
if ($p8000) {
    Write-Host "✅ 장비예약 서비스(8000번) 이미 가동 중" -ForegroundColor Green
} else {
    Write-Host "🚀 장비예약 서비스(8000번) 시작 중..." -ForegroundColor Yellow
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c npm run start" -WorkingDirectory $equipDir -WindowStyle Hidden
}

# 3. 게이트웨이 (80번) 확인 및 기동
$p80 = Get-NetTCPConnection -LocalPort 80 -ErrorAction SilentlyContinue
if ($p80) {
    Write-Host "✅ 중앙 게이트웨이(80번) 이미 가동 중" -ForegroundColor Green
} else {
    Write-Host "🚀 중앙 게이트웨이(80번) 시작 중..." -ForegroundColor Yellow
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c node `"$portalDir\gateway\gateway.mjs`"" -WorkingDirectory "$portalDir\gateway" -WindowStyle Hidden
}

# 4. 5초 대기 후 헬스체크
Write-Host "`n서비스 바인딩 대기 중 (5초)..." -ForegroundColor Gray
Start-Sleep -Seconds 5

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "🔍 서비스 헬스체크 결과:" -ForegroundColor Cyan

try {
    $resPortal = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 3
    Write-Host "  - 포털 내부 (localhost:3000):   $($resPortal.StatusCode) OK" -ForegroundColor Green
} catch {
    Write-Host "  - 포털 내부 (localhost:3000):   오류 ($($_.Exception.Message))" -ForegroundColor Red
}

try {
    $resEquip = Invoke-WebRequest -Uri "http://localhost:8000" -UseBasicParsing -TimeoutSec 3
    Write-Host "  - 장비 내부 (localhost:8000):   $($resEquip.StatusCode) OK" -ForegroundColor Green
} catch {
    Write-Host "  - 장비 내부 (localhost:8000):   오류 ($($_.Exception.Message))" -ForegroundColor Red
}

try {
    $resPortalDom = Invoke-WebRequest -Uri "http://portal.arfab.kr" -UseBasicParsing -TimeoutSec 3
    Write-Host "  - 포털 도메인 (portal.arfab.kr): $($resPortalDom.StatusCode) 정상 서비스 중!" -ForegroundColor Green
} catch {
    Write-Host "  - 포털 도메인 (portal.arfab.kr): 오류 ($($_.Exception.Message))" -ForegroundColor Red
}

try {
    $resEquipDom = Invoke-WebRequest -Uri "http://equipment.arfab.kr" -UseBasicParsing -TimeoutSec 3
    Write-Host "  - 장비 도메인 (equipment.arfab.kr): $($resEquipDom.StatusCode) 정상 서비스 중!" -ForegroundColor Green
} catch {
    Write-Host "  - 장비 도메인 (equipment.arfab.kr): 오류 ($($_.Exception.Message))" -ForegroundColor Red
}
Write-Host "========================================================" -ForegroundColor Cyan
