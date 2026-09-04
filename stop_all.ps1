$ports = @(80, 3000, 3001, 3002, 3003, 3004, 3005, 5173, 8000, 8001, 8002, 8080, 8089, 8090)

Write-Host "=== Terminating all processes on ARFab Portal Ports ==="

foreach ($port in $ports) {
  Write-Host "Checking port $port..."
  
  # Find PIDs listening on this port
  $connections = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue | Where-Object { $_.State -eq "Listen" }
  
  if ($connections) {
    $pids = $connections.OwningProcess | Select-Object -Unique
    
    foreach ($p in $pids) {
      Write-Host "  Found PID $p listening on port $port. Terminating..."
      try {
        Stop-Process -Id $p -Force -ErrorAction Stop
        Write-Host "    Successfully terminated PID $p."
      } catch {
        Write-Warning "    Failed to terminate PID $p : $($_.Exception.Message)"
      }
    }
  } else {
    Write-Host "  No active processes found on port $port."
  }
}

Write-Host "All portal ports cleared successfully!"
