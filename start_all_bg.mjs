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

for (const file of batchFiles) {
  const filePath = join(portalDir, file);
  console.log(`Starting detached background service: ${filePath}`);
  
  const child = spawn("cmd.exe", ["/c", "call", filePath], {
    cwd: portalDir,
    detached: true,
    stdio: "ignore",
    windowsHide: true
  });
  
  child.unref();
}

console.log("All services spawned successfully in background!");
