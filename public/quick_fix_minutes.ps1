# ==============================================================================
# [ARFab Production Server 203.241.190.58]
# 동서대 앵커사업단 회의록 자동 작성기 (Port 8005) 원클릭 즉각 복구 및 최신화 스크립트
# ==============================================================================

$ErrorActionPreference = "Continue"
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "🚀 동서대 앵커사업단 회의록 작성기 긴급 점검 및 복구 시작" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$destDir = "C:\ARFabServices\회의록작성"
$zipSource = "C:\ARFabServices\meeting_minutes.zip"
$githubZipUrl = "https://raw.githubusercontent.com/yntaesoo/AI-Solution-Portal/main/public/meeting_minutes.zip"
$python = "C:\Users\yntae\AppData\Local\Programs\Python\Python311\python.exe"
if (-not (Test-Path $python)) { $python = "python" }

# 1. 이전 Hwp 및 8005 포트 프로세스 강제 정리
Write-Host "[1/5] 한글(HWP) 좀비 프로세스 및 기존 8005 서비스 강제 정리..." -ForegroundColor Yellow
cmd /c "taskkill /f /im Hwp.exe /t >nul 2>&1"
cmd /c "taskkill /f /im HwpApi.exe /t >nul 2>&1"

$pids = Get-NetTCPConnection -LocalPort 8005 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique
foreach ($p in $pids) {
    if ($p -and $p -ne 0) {
        Write-Host "  -> 이전 포트 8005 프로세스 PID $p 종료..." -ForegroundColor Gray
        cmd /c "taskkill /f /pid $p >nul 2>&1"
    }
}
Start-Sleep -Seconds 1

# 2. 한글 보안 승인 모듈 레지스트리 자동 등록
Write-Host "[2/5] 한글(HWP) 자동화 보안 승인 모듈 레지스트리 점검 및 등록..." -ForegroundColor Yellow
$regPath = "HKCU:\Software\HNC\HwpAutomation\Modules"
if (!(Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}
$dllPath = "C:\Users\yntae\AppData\Local\Programs\Python\Python311\Lib\site-packages\pyhwpx\FilePathCheckerModule.dll"
if (Test-Path $dllPath) {
    Set-ItemProperty -Path $regPath -Name "FilePathCheckerModule" -Value $dllPath -Force
    Write-Host "  -> 보안 모듈 레지스트리 등록 완료 ($dllPath)" -ForegroundColor Green
} else {
    Write-Host "  -> 보안 모듈 DLL 경로 탐색 완료" -ForegroundColor Gray
}

# 3. 최신 패키지 다운로드 및 압축 해제
Write-Host "[3/5] GitHub에서 최신 패키지 직접 다운로드 중..." -ForegroundColor Yellow
if (!(Test-Path "C:\ARFabServices")) {
    New-Item -ItemType Directory -Path "C:\ARFabServices" -Force | Out-Null
}
try {
    Invoke-WebRequest -Uri $githubZipUrl -OutFile $zipSource -UseBasicParsing -TimeoutSec 30
    Write-Host "  -> 최신 패키지 다운로드 완료! ($zipSource)" -ForegroundColor Green
} catch {
    Write-Host "  -> 다운로드 오류: $_" -ForegroundColor Red
}

if (Test-Path $zipSource) {
    Write-Host "  -> $destDir 폴더에 최신 코드 덮어쓰기 중..." -ForegroundColor Yellow
    Expand-Archive -Path $zipSource -DestinationPath $destDir -Force
    Write-Host "  -> 압축 해제 및 파일 갱신 완료!" -ForegroundColor Green
}

# 4. 한글 자동화 COM 기동 자가 테스트
Write-Host "[4/5] 한글(HWP) 자동화 서버 연결 자가 진단 테스트 중..." -ForegroundColor Yellow
$testCmd = "import pyhwpx; h = pyhwpx.Hwp(new=True, visible=False); h.quit(); print('HWP_SUCCESS')"
$diagResult = & "$python" -c $testCmd 2>&1
if ($diagResult -match "HWP_SUCCESS") {
    Write-Host "  -> 🎉 [성공] 한글(HWP) COM 서버가 정상적으로 응답합니다!" -ForegroundColor Green
} else {
    Write-Host "  -> ⚠️ 한글 COM 진단 결과: $diagResult" -ForegroundColor Yellow
    Write-Host "     (한글이 현재 화면에 대화상자를 띄우고 있을 수 있으므로 작업표시줄의 한글 창을 확인해 주세요)" -ForegroundColor Gray
}

# 5. 회의록 서버(8005) 신규 기동
Write-Host "[5/5] 회의록 서비스(포트 8005) 가동..." -ForegroundColor Yellow
Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$python`" server.py --port 8005" -WorkingDirectory $destDir -WindowStyle Normal

Start-Sleep -Seconds 3

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "🎉 203.241.190.58 서버 회의록 작성기 긴급 복구 완료!" -ForegroundColor Green
Write-Host "   - 서비스 주소: http://minutes.arfab.kr" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
