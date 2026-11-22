# ==============================================================================
# [ARFab Production Server 203.241.190.58]
# AI 솔루션 포털 및 유학생 창업동아리 원클릭 원격 자동 업데이트 스크립트
# ==============================================================================

$ErrorActionPreference = "Continue"
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "🚀 AI 솔루션 포털 (portal.arfab.kr) 최신 업데이트 시작" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$portalDir = "C:\ARFabServices\AI솔루션포털"
if (!(Test-Path $portalDir)) {
    $portalDir = "H:\Create with Codex\AI솔루션포털"
}

# 1. 포털 Git Pull 최신화
Write-Host "`n[1/5] 포털 최신 소스 Git Pull 동기화 중..." -ForegroundColor Yellow
if (Test-Path "$portalDir\.git") {
    Push-Location $portalDir
    cmd /c "git reset --hard HEAD"
    cmd /c "git pull origin main"
    Pop-Location
    Write-Host "  -> Git Pull 완료!" -ForegroundColor Green
} else {
    Write-Host "  -> .git 폴더 없음, 현재 소스 유지" -ForegroundColor Gray
}

# 2. hosts 파일 갱신
Write-Host "`n[2/5] C:\Windows\System32\drivers\etc\hosts 등록 갱신 중..." -ForegroundColor Yellow
if (Test-Path "$portalDir\hosts.txt") {
    try {
        Copy-Item "$portalDir\hosts.txt" "C:\Windows\System32\drivers\etc\hosts" -Force
        Write-Host "  -> hosts 파일 갱신 완료!" -ForegroundColor Green
    } catch {
        Write-Host "  -> hosts 파일 갱신 실패 (관리자 권한 필요): $_" -ForegroundColor Yellow
    }
}

# 3. 유학생 창업동아리(3004) 패치 적용 및 재기동
Write-Host "`n[3/5] 유학생 창업동아리 관리 서비스 최신 패치 및 점검..." -ForegroundColor Yellow
$clubDir = "C:\ARFabServices\창업관련\유학생창업동아리\startup-club-manager"
if (!(Test-Path $clubDir)) {
    $clubDir = "H:\Create with Codex\창업관련\유학생창업동아리\startup-club-manager"
}
if (Test-Path $clubDir) {
    Push-Location $clubDir
    $pids = Get-NetTCPConnection -LocalPort 3004 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique
    foreach ($p in $pids) {
        if ($p -and $p -ne 0) {
            cmd /c "taskkill /f /pid $p >nul 2>&1"
        }
    }
    if (Test-Path "$portalDir\public\startup_club_patch.zip") {
        Expand-Archive -Path "$portalDir\public\startup_club_patch.zip" -DestinationPath $clubDir -Force
        Write-Host "  -> 유학생 창업동아리 최신 패치 압축 해제 완료!" -ForegroundColor Green
    }
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c npm run start" -WorkingDirectory $clubDir -WindowStyle Hidden
    Pop-Location
}

# 4. 포털(3000) 및 게이트웨이(80) 점검 및 재기동
Write-Host "`n[4/5] 중앙 게이트웨이(Port 80) 및 포털 서비스 점검 중..." -ForegroundColor Yellow
$p80 = Get-NetTCPConnection -LocalPort 80 -ErrorAction SilentlyContinue
if (!$p80) {
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c node `"$portalDir\gateway\gateway.mjs`"" -WorkingDirectory "$portalDir\gateway" -WindowStyle Hidden
    Write-Host "  -> 게이트웨이(80) 백그라운드 시작" -ForegroundColor Green
} else {
    Write-Host "  -> 게이트웨이(80) 가동 중" -ForegroundColor Green
}

$p3000 = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue
if (!$p3000) {
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c npm run dev" -WorkingDirectory $portalDir -WindowStyle Hidden
    Write-Host "  -> 포털(3000) 백그라운드 시작" -ForegroundColor Green
} else {
    Write-Host "  -> 포털(3000) 가동 중" -ForegroundColor Green
}

Start-Sleep -Seconds 3

# 5. 전체 서비스 헬스체크
Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "🔍 전체 포털 서비스 도메인 헬스체크 (http://*.arfab.kr)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$domains = @(
    @{ Name = "AI 솔루션 포털 메인"; Url = "http://portal.arfab.kr" },
    @{ Name = "유학생 창업동아리 관리"; Url = "http://club.arfab.kr/StartupClub" },
    @{ Name = "동서대 장비예약 (VFX)"; Url = "http://equipment.arfab.kr" },
    @{ Name = "동서대 게임학과 포털"; Url = "http://dsu.arfab.kr" },
    @{ Name = "창업멘토 매칭시스템"; Url = "http://mentor.arfab.kr" },
    @{ Name = "Live2D 챗봇 (RAG)"; Url = "http://chatbotrag.arfab.kr" },
    @{ Name = "유학생 정주지원 B-Bridge"; Url = "http://bbridge.arfab.kr" },
    @{ Name = "동서대 앵커 회의록 AI"; Url = "http://minutes.arfab.kr" }
)

foreach ($d in $domains) {
    try {
        $code = (curl.exe -s -o NUL -w "%{http_code}" -m 3 $d.Url)
        if ($code -eq "200" -or $code -eq "302" -or $code -eq "307" -or $code -eq "308") {
            Write-Host "✅ [$code] $($d.Name) ($($d.Url))" -ForegroundColor Green
        } else {
            Write-Host "⚠️ [$code] $($d.Name) ($($d.Url))" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ [ERR] $($d.Name) ($($d.Url))" -ForegroundColor Red
    }
}

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "🎉 모든 포털 업데이트 및 검증 완료!" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
