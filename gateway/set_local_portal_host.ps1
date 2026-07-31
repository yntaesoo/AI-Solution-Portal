$ErrorActionPreference = "Stop"
$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
$entry = "127.0.0.1 portal.arfab.kr"
$content = Get-Content -LiteralPath $hostsPath -Raw

if ($content -notmatch "(?m)^\s*127\.0\.0\.1\s+portal\.arfab\.kr\s*$") {
    $updated = $content.TrimEnd("`r", "`n") + "`r`n" + $entry + "`r`n"
    [System.IO.File]::WriteAllText(
        $hostsPath,
        $updated,
        [System.Text.Encoding]::ASCII
    )
}

ipconfig /flushdns | Out-Null
