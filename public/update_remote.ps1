# ==============================================================================
# [ARFab 원격 자동 패치 스크립트] 유학생 창업동아리 원클릭 업데이트
# 대상 경로: C:\ARFabServices\창업관련\유학생창업동아리\startup-club-manager
# ==============================================================================

$ErrorActionPreference = "Stop"
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "🚀 유학생 창업동아리 원클릭 원격 자동 패치를 시작합니다" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

# 1. 대상 프로젝트 폴더 감지 (startup-club-manger 또는 startup-club-manager 대응)
$basePath = "c:\ARFabServices\창업관련\유학생창업동아리"
$targetDir = Join-Path $basePath "startup-club-manger"
if (!(Test-Path $targetDir)) {
    $targetDir = Join-Path $basePath "startup-club-manager"
}

if (!(Test-Path $targetDir)) {
    Write-Host "[오류] 대상 프로젝트 폴더를 찾을 수 없습니다: $targetDir" -ForegroundColor Red
    Write-Host "확인된 기본 경로: $basePath" -ForegroundColor Yellow
    exit 1
}

Write-Host "📁 대상 프로젝트 경로: $targetDir" -ForegroundColor Green
Set-Location $targetDir

# 2. 패치 ZIP 다운로드
Write-Host "[1/5] 최신 패치 파일 다운로드 중 (http://portal.arfab.kr/startup_club_patch.zip)..." -ForegroundColor Yellow
$zipPath = Join-Path $targetDir "startup_club_patch.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Invoke-WebRequest -Uri "http://portal.arfab.kr/startup_club_patch.zip" -OutFile $zipPath -UseBasicParsing

# 3. 기존 실행 중인 3004번 포트 프로세스 정리
Write-Host "[2/5] 기존 3004번 포트 프로세스 확인 및 종료 중..." -ForegroundColor Yellow
$pids = Get-NetTCPConnection -LocalPort 3004 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique
foreach ($p in $pids) {
    if ($p -and $p -ne 0) {
        Write-Host "  -> 프로세스 PID $p 종료..."
        cmd /c "taskkill /f /pid $p /t >nul 2>&1"
    }
}

# 4. 압축 해제 및 패치 파일 덮어쓰기
Write-Host "[3/5] 패치 파일 압축 해제 및 소스코드 덮어쓰기..." -ForegroundColor Yellow
Expand-Archive -Path $zipPath -DestinationPath $targetDir -Force
Remove-Item $zipPath -Force

# 5. apply_patch.ps1 실행 (백업, DB 마이그레이션, 프로덕션 빌드, 헬스체크)
Write-Host "[4/5] 패치 적용 및 프로덕션 빌드 수행 중..." -ForegroundColor Yellow
powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $targetDir "apply_patch.ps1")

# 6. 백그라운드 서비스 기동 (3004번 포트)
Write-Host "[5/5] 최신 프로덕션 서비스 백그라운드 기동..." -ForegroundColor Yellow
Start-Process -FilePath "cmd.exe" -ArgumentList "/c npm run start" -WorkingDirectory $targetDir -WindowStyle Hidden

Start-Sleep -Seconds 4
$checkPort = Get-NetTCPConnection -LocalPort 3004 -ErrorAction SilentlyContinue
if ($checkPort) {
    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host "🎉 원격 패치 및 3004번 서비스 재기동이 완벽하게 완료되었습니다!" -ForegroundColor Green
    Write-Host "   - 로컬 테스트 주소: http://localhost:3004/StartupClub/dashboard" -ForegroundColor Green
    Write-Host "   - 포털 서비스 주소: http://portal.arfab.kr/startupclub/dashboard" -ForegroundColor Green
    Write-Host "========================================================" -ForegroundColor Green
} else {
    Write-Host "[주의] 3004 포트 감지 대기 중입니다. 'npm run start'로 수동 기동 여부를 확인해주세요." -ForegroundColor Yellow
}
