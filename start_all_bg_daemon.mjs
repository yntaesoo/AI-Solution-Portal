import { spawn } from "node:child_process";
import { join } from "node:path";
import { existsSync } from "node:fs";

const equipmentDir = existsSync("H:\\Create with Anti\\EquipmentBookingSystem")
  ? "H:\\Create with Anti\\EquipmentBookingSystem"
  : "C:\\ARFabServices\\EquipmentBookingSystem";

const services = [
  {
    name: "arfab_service",
    cwd: "F:\\create with claude\\Documents\\ARFab",
    cmd: "npm",
    args: ["run", "dev"],
    shell: true
  },
  {
    name: "dsu_service",
    cwd: "F:\\create with claude\\DSUGamePortal",
    cmd: "C:\\Users\\yntae\\AppData\\Local\\Programs\\Python\\Python311\\python.exe",
    args: ["-m", "uvicorn", "backend.main:app", "--host", "127.0.0.1", "--port", "8080"],
    shell: false
  },
  {
    name: "equipment_service",
    cwd: equipmentDir,
    cmd: "node",
    args: ["node_modules/next/dist/bin/next", "start", "-H", "0.0.0.0", "-p", "8000"],
    shell: false
  },
  {
    name: "ocr_service",
    cwd: "F:\\Create with Claude\\OCR\\backend",
    cmd: "F:\\Create with Claude\\OCR\\backend\\venv311\\Scripts\\python.exe",
    args: ["-m", "uvicorn", "main:app", "--host", "127.0.0.1", "--port", "8001"],
    shell: false
  },
  {
    name: "chatbot_service",
    cwd: "F:\\Create with Claude\\ChatBot\\backend",
    cmd: "F:\\Create with Claude\\ChatBot\\backend\\.venv\\Scripts\\python.exe",
    args: ["-m", "uvicorn", "main:app", "--host", "127.0.0.1", "--port", "8002"],
    shell: false
  },
  {
    name: "mentor_service",
    cwd: "H:\\Create with Codex\\창업관련\\창업멘토매칭시스템",
    cmd: "npm",
    args: ["run", "dev"],
    shell: true
  },
  {
    name: "startup_club_service",
    cwd: "H:\\Create with Codex\\창업관련\\유학생창업동아리\\startup-club-manager",
    cmd: "npm",
    args: ["run", "start", "--", "-p", "3004"],
    shell: true
  },
  {
    name: "md_backend",
    cwd: "H:\\Create with Codex\\Idea2Real\\MDConversion\\backend",
    cmd: "H:\\Create with Codex\\Idea2Real\\MDConversion\\backend\\venv\\Scripts\\python.exe",
    args: ["-m", "uvicorn", "main:app", "--host", "127.0.0.1", "--port", "8089"],
    shell: false
  },
  {
    name: "md_frontend",
    cwd: "H:\\Create with Codex\\Idea2Real\\MDConversion\\frontend",
    cmd: "npm",
    args: ["run", "dev"],
    shell: true
  },
  {
    name: "md2html_backend",
    cwd: "H:\\Create with Codex\\Idea2Real\\MD2HTMLDOCPDF\\backend",
    cmd: "H:\\Create with Codex\\Idea2Real\\MD2HTMLDOCPDF\\backend\\venv\\Scripts\\python.exe",
    args: ["-m", "uvicorn", "main:app", "--host", "127.0.0.1", "--port", "8090"],
    shell: false
  },
  {
    name: "md2html_frontend",
    cwd: "H:\\Create with Codex\\Idea2Real\\MD2HTMLDOCPDF\\frontend",
    cmd: "npm",
    args: ["run", "dev"],
    shell: true
  },
  {
    name: "portal_service",
    cwd: "H:\\Create with Codex\\AI\uC194\uB8E8\uC158\uD3EC\uD138",
    cmd: "npm",
    args: ["run", "dev"],
    shell: true
  },
  {
    name: "gateway",
    cwd: "H:\\Create with Codex\\AI\uC194\uB8E8\uC158\uD3EC\uD138\\gateway",
    cmd: "node",
    args: ["gateway.mjs"],
    shell: false
  }
];

console.log("=== ARFab Web Services Daemon Manager ===");

const children = {};

for (const svc of services) {
  console.log(`Spawning daemon process: ${svc.name} in ${svc.cwd}...`);
  
  const child = spawn(svc.cmd, svc.args, {
    cwd: svc.cwd,
    detached: true,
    stdio: "ignore",
    windowsHide: true,
    shell: svc.shell
  });
  
  children[svc.name] = {
    pid: child.pid,
    process: child
  };
  
  child.on("exit", (code, signal) => {
    console.log(`[DAEMON ERROR] Service "${svc.name}" (PID ${child.pid}) exited with code ${code} and signal ${signal}`);
  });
  
  child.unref();
}

console.log("All child services successfully spawned and detached!");

// Keep the daemon process running indefinitely
setInterval(() => {
  console.log(`[HEARTBEAT] Daemon manager is active. Monitoring ${Object.keys(children).length} services...`);
}, 60000); // output heartbeat every minute
