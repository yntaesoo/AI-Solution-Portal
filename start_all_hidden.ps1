$portalDir = $PSScriptRoot

$batchFiles = @(
  "_start_arfab_service.bat",
  "_start_dsu_service.bat",
  "_start_equipment_service.bat",
  "_start_ocr_service.bat",
  "_start_chatbot_service.bat",
  "_start_mentor_service.bat",
  "_start_startup_club_service.bat",
  "_start_md_backend.bat",
  "_start_md_frontend.bat",
  "_start_md2html_backend.bat",
  "_start_md2html_frontend.bat",
  "_start_portal_service.bat",
  "gateway\start_gateway.bat"
)

Write-Host "=== Starting all ARFab Web Services in Hidden Mode ==="
Write-Host "Portal Directory: $portalDir"

foreach ($file in $batchFiles) {
  $filePath = Join-Path $portalDir $file
  Write-Host "Launching background service: $file"
  
  # Start-Process with WindowStyle Hidden runs it in a detached, hidden window
  # so it won't clutter the taskbar or desktop, and won't die when this script exits.
  Start-Process -FilePath "cmd.exe" -ArgumentList "/c call `"$filePath`"" -WorkingDirectory $portalDir -WindowStyle Hidden
}

Write-Host "All services successfully started in the background!"
