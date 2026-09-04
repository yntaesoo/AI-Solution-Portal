$parent = 'H:\Create with Codex'
$dir = Get-ChildItem -Path $parent -Directory -Recurse -Depth 2 -ErrorAction SilentlyContinue | Where-Object {
    $config = Join-Path $_.FullName 'vite.config.ts'
    if (Test-Path $config) {
        (Get-Content $config -Raw -ErrorAction SilentlyContinue) -like '*mentor.arfab.kr*'
    } else {
        $false
    }
} | Select-Object -First 1

if ($dir) {
    Set-Location $dir.FullName
    npm.cmd run dev
}
