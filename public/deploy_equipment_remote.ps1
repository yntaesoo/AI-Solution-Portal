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

# 1. 기존 8000번 포트 (구버전 Flask) 프로세스 종료
Write-Host "[1/6] 기존 8000번 포트(구버전 장비관리) 프로세스 종료 중..." -ForegroundColor Yellow
$pids = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique
foreach ($p in $pids) {
    if ($p -and $p -ne 0) {
        Write-Host "  -> 프로세스 PID $p 강제 종료..." -ForegroundColor Gray
        cmd /c "taskkill /f /pid $p /t >nul 2>&1"
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

# 6. 서비스 구동 및 헬스체크
Write-Host "[6/6] Next.js 8000번 포트 백그라운드 서비스 기동..." -ForegroundColor Yellow
Start-Process -FilePath "cmd.exe" -ArgumentList "/c npm run start" -WorkingDirectory $destDir -WindowStyle Hidden

Start-Sleep -Seconds 4
$checkPort = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue
if ($checkPort) {
    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host "🎉 203.241.190.58 서버 배포 및 서비스 기동 성공!" -ForegroundColor Green
    Write-Host "   - 로컬 테스트: http://localhost:8000" -ForegroundColor Green
    Write-Host "   - 포털 도메인: http://equipment.arfab.kr" -ForegroundColor Green
    Write-Host "   - 통합 포털:   http://portal.arfab.kr" -ForegroundColor Green
    Write-Host "========================================================" -ForegroundColor Green
} else {
    Write-Host "[주의] 8000번 포트 감지 대기 중입니다. 잠시 후 http://localhost:8000 접속을 확인해 주세요." -ForegroundColor Yellow
}
