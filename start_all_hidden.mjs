import { spawn } from "node:child_process";
import { join } from "node:path";

const portalDir = "H:\\Create with Codex\\AI\uC194\uB8E8\uC158\uD3EC\uD138";

const batchFiles = [
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
  "gateway\\start_gateway.bat"
];

console.log("=== Launching ARFab Web Services via PowerShell Detached ===");

for (const file of batchFiles) {
  const filePath = join(portalDir, file);
  console.log(`Starting background daemon: ${file}`);
  
  // Launching via powershell Start-Process -WindowStyle Hidden breaks the Job Object chain,
  // allowing the services to keep running headlessly even after the parent script exits.
  spawn("powershell.exe", [
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-Command", `Start-Process -FilePath "cmd.exe" -ArgumentList "/c call \\"${filePath}\\"" -WorkingDirectory "${portalDir}" -WindowStyle Hidden`
  ], { stdio: "ignore" });
}

console.log("All services successfully launched in background!");
