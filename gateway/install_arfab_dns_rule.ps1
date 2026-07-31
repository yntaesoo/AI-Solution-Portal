$ErrorActionPreference = 'Stop'

$namespace = '.arfab.kr'
$comment = 'AI Solution Portal - public DNS for ARFab subdomains'

Get-DnsClientNrptRule -ErrorAction SilentlyContinue |
    Where-Object { $_.Namespace -contains $namespace -and $_.Comment -eq $comment } |
    ForEach-Object { Remove-DnsClientNrptRule -Name $_.Name -Force }

Add-DnsClientNrptRule `
    -Namespace $namespace `
    -NameServers @('8.8.8.8', '1.1.1.1') `
    -Comment $comment | Out-Null

Clear-DnsClientCache
Write-Output 'ARFab domain-specific DNS rule installed.'
