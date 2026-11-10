# ==============================================================================
# [ARFab Production Server 203.241.190.58]
# 동서대 앵커사업단 회의록 자동 작성기 (Port 8005) 원클릭 원격 자동 배포기
# 대상 경로: C:\ARFabServices\회의록작성
# ==============================================================================

$ErrorActionPreference = "Continue"
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "🚀 동서대 앵커사업단 회의록 작성기 (203.241.190.58) 원격 배포를 시작합니다" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$destDir = "C:\ARFabServices\회의록작성"
$portalDir = "C:\ARFabServices\AI솔루션포털"
$zipSource = "$portalDir\public\meeting_minutes.zip"
$githubZipUrl = "https://raw.githubusercontent.com/yntaesoo/AI-Solution-Portal/main/public/meeting_minutes.zip"

# 1. 포털 소스 Git Pull 최신화
Write-Host "[1/5] AI 솔루션 포털 최신 소스 동기화 (Git Pull)..." -ForegroundColor Yellow
if (Test-Path "$portalDir\.git") {
    Push-Location $portalDir
    cmd /c "git reset --hard HEAD"
    cmd /c "git pull origin main"
    Pop-Location
}

# 2. 패키지 다운로드 또는 복사
Write-Host "[2/5] 회의록 작성기 최신 패키지 확보..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "$portalDir\public" -Force | Out-Null
try {
    Write-Host "  GitHub에서 최신 패키지 다운로드 중..." -ForegroundColor Gray
    Invoke-WebRequest -Uri $githubZipUrl -OutFile $zipSource -UseBasicParsing -TimeoutSec 30
    Write-Host "  -> GitHub 최신 패키지 다운로드 완료!" -ForegroundColor Green
} catch {
    Write-Host "  -> GitHub 직접 다운로드 경고 (로컬/캐시 패키지 유지 사용): $_" -ForegroundColor Yellow
}

# 3. 대상 폴더 준비 및 압축 해제
Write-Host "[3/5] 파일 압축 해제 중 ($destDir)..." -ForegroundColor Yellow
if (!(Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}
Expand-Archive -Path $zipSource -DestinationPath $destDir -Force
Write-Host "  -> 압축 해제 완료!" -ForegroundColor Green

# 4. 기존 8005 포트 및 한글(Hwp) 좀비 프로세스 정리 후 신규 기동
Write-Host "[4/5] 한글(HWP) 좀비 프로세스 정리 및 8005 서비스 신규 기동..." -ForegroundColor Yellow
cmd /c "taskkill /f /im Hwp.exe /t >nul 2>&1"
cmd /c "taskkill /f /im HwpApi.exe /t >nul 2>&1"
$pids = Get-NetTCPConnection -LocalPort 8005 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique
foreach ($p in $pids) {
    if ($p -and $p -ne 0) {
        Write-Host "  -> 이전 8005 프로세스 PID $p 종료..." -ForegroundColor Gray
        cmd /c "taskkill /f /pid $p >nul 2>&1"
    }
}
$python = "C:\Users\yntae\AppData\Local\Programs\Python\Python311\python.exe"
if (-not (Test-Path $python)) { $python = "python" }
Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$python`" server.py --port 8005" -WorkingDirectory $destDir -WindowStyle Normal

# 5. 게이트웨이 및 포털 재시작
Write-Host "[5/5] 게이트웨이 및 포털 서비스 리프레시..." -ForegroundColor Yellow
if (Test-Path "C:\Users\yntae\AppData\Local\ARFabServices") {
    Copy-Item "$portalDir\gateway\gateway.mjs" "C:\Users\yntae\AppData\Local\ARFabServices\gateway.mjs" -Force -ErrorAction SilentlyContinue
    Copy-Item "$portalDir\gateway\routes.json" "C:\Users\yntae\AppData\Local\ARFabServices\routes.json" -Force -ErrorAction SilentlyContinue
}

$p3000 = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique
foreach ($p in $p3000) { if ($p) { cmd /c "taskkill /f /pid $p >nul 2>&1" } }

$p80 = Get-NetTCPConnection -LocalPort 80 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique
foreach ($p in $p80) { if ($p) { cmd /c "taskkill /f /pid $p >nul 2>&1" } }

Start-Sleep -Seconds 2
if (Test-Path "$portalDir\_start_portal_service.bat") {
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c call `"$portalDir\_start_portal_service.bat`"" -WorkingDirectory $portalDir -WindowStyle Hidden
} else {
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c npm run dev" -WorkingDirectory $portalDir -WindowStyle Hidden
}
Start-Process -FilePath "cmd.exe" -ArgumentList "/c node `"$portalDir\gateway\gateway.mjs`"" -WorkingDirectory "$portalDir\gateway" -WindowStyle Hidden

Start-Sleep -Seconds 5
Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "🎉 203.241.190.58 서버 배포 및 서비스 갱신 완료!" -ForegroundColor Green
Write-Host "   - 포털 메인:   http://portal.arfab.kr" -ForegroundColor Green
Write-Host "   - 회의록 작성: http://minutes.arfab.kr" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
