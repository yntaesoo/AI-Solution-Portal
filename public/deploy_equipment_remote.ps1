# ==============================================================================
# [ARFab Production Server 203.241.190.58]
# 동서대 IC 기자재 예약 시스템 (Next.js 8000번 포트) 원클릭 원격 자동 배포기
# 대상 경로: C:\ARFabServices\EquipmentBookingSystem
# ==============================================================================

$ErrorActionPreference = "Stop"
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "🚀 동서대 IC 장비예약시스템 (203.241.190.58) 원격 배포를 시작합니다" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$destDir = "C:\ARFabServices\EquipmentBookingSystem"
$portalDir = "C:\ARFabServices\AI솔루션포털"
$zipSource = "$portalDir\public\equipment_booking_system.zip"
$fallbackZipUrl = "https://raw.githubusercontent.com/yntaesoo/AI-Solution-Portal/main/public/equipment_booking_system.zip"

# 1. 기존 8000번 포트 (구버전 Flask) 프로세스 종료 (다른 서비스 영향 방지 위해 특정 PID만 종료)
Write-Host "[1/6] 기존 8000번 포트(구버전 장비관리) 프로세스 종료 중..." -ForegroundColor Yellow
$pids = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique
foreach ($p in $pids) {
    if ($p -and $p -ne 0) {
        Write-Host "  -> 프로세스 PID $p 종료..." -ForegroundColor Gray
        cmd /c "taskkill /f /pid $p >nul 2>&1"
    }
}

# 2. 배포 압축파일 확인 및 다운로드
Write-Host "[2/6] 배포 패키지 파일 확인 중..." -ForegroundColor Yellow
if (!(Test-Path $zipSource)) {
    Write-Host "  로컬 패키지가 없어 GitHub에서 최신 패키지 다운로드 중..." -ForegroundColor Gray
    New-Item -ItemType Directory -Path "$portalDir\public" -Force | Out-Null
    Invoke-WebRequest -Uri $fallbackZipUrl -OutFile $zipSource -UseBasicParsing
}

# 3. 디렉토리 준비 및 백업
Write-Host "[3/6] 대상 디렉토리 준비 ($destDir)..." -ForegroundColor Yellow
if (!(Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
} elseif (Test-Path "$destDir\prisma\dev.db") {
    $backupDir = "$destDir\_backup"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    Copy-Item "$destDir\prisma\dev.db" "$backupDir\dev_$timestamp.db" -Force
    Write-Host "  -> 기존 DB 백업 완료 ($backupDir\dev_$timestamp.db)" -ForegroundColor Green
}

# 4. 압축 해제
Write-Host "[4/6] 최신 소스 및 프로덕션 빌드 압축 해제 중..." -ForegroundColor Yellow
Expand-Archive -Path $zipSource -DestinationPath $destDir -Force
Write-Host "  -> 압축 해제 완료!" -ForegroundColor Green

# 5. 종속성 설치 및 Prisma 클라이언트 생성
Write-Host "[5/6] 패키지 의존성(npm) 및 Prisma 엔진 점검..." -ForegroundColor Yellow
Set-Location $destDir
if (!(Test-Path "$destDir\node_modules")) {
    Write-Host "  npm install 실행 중 (최초 1회, 1~2분 소요)..." -ForegroundColor Gray
    cmd /c "npm install --omit=dev"
}
cmd /c "npx prisma generate"

# 6. 서비스 구동 (8000번 장비 및 3000번 포털 동시 보장)
Write-Host "[6/6] 서비스 기동 및 상태 보장 중..." -ForegroundColor Yellow
Start-Process -FilePath "cmd.exe" -ArgumentList "/c npm run start" -WorkingDirectory $destDir -WindowStyle Hidden

# 포털 서비스 (3000번) 가동 여부 점검 및 필요 시 자동 기동
$p3000 = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue
if (!$p3000) {
    Write-Host "  -> 포털 서비스(3000번) 기동 중..." -ForegroundColor Gray
    if (Test-Path "$portalDir\_start_portal_service.bat") {
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c call `"$portalDir\_start_portal_service.bat`"" -WorkingDirectory $portalDir -WindowStyle Hidden
    } else {
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c npm run dev" -WorkingDirectory $portalDir -WindowStyle Hidden
    }
}

# 게이트웨이 (80번) 가동 여부 점검
$p80 = Get-NetTCPConnection -LocalPort 80 -ErrorAction SilentlyContinue
if (!$p80) {
    Write-Host "  -> 게이트웨이(80번) 기동 중..." -ForegroundColor Gray
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c node `"$portalDir\gateway\gateway.mjs`"" -WorkingDirectory "$portalDir\gateway" -WindowStyle Hidden
}

Start-Sleep -Seconds 5

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "🎉 203.241.190.58 서버 배포 및 서비스 점검 완료!" -ForegroundColor Green
Write-Host "   - 포털 메인:   http://portal.arfab.kr" -ForegroundColor Green
Write-Host "   - 장비 시스템: http://equipment.arfab.kr" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
