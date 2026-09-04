import http from "node:http";
import net from "node:net";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const gatewayDir = dirname(fileURLToPath(import.meta.url));
const routes = JSON.parse(readFileSync(join(gatewayDir, "routes.json"), "utf8"));
const listenPort = Number(process.env.GATEWAY_PORT || 80);

function findRoute(hostHeader = "") {
  const hostname = hostHeader.toLowerCase().split(":")[0];
  return { hostname, route: routes[hostname] };
}

function unavailable(res, hostname, message = "Service unavailable") {
  res.writeHead(503, { "content-type": "text/html; charset=utf-8" });
  res.end(`<!doctype html><html lang="ko"><meta charset="utf-8"><title>${message}</title>
    <body style="font-family:Arial,sans-serif;padding:48px;background:#f4f4ef;color:#14211d">
    <h1>${message}</h1><p>${hostname || "Unknown host"} 서비스를 확인해 주세요.</p></body></html>`);
}

const server = http.createServer((req, res) => {
  const { hostname, route } = findRoute(req.headers.host);
  if (!route) {
    res.writeHead(404, { "content-type": "text/plain; charset=utf-8" });
    res.end(`No route configured for ${hostname || "unknown host"}`);
    return;
  }

  // Auto-redirect /b-bridge (without trailing slash) to /b-bridge/ to prevent Vite fallback warning
  if (hostname === "portal.arfab.kr" && req.url.toLowerCase() === "/b-bridge") {
    res.writeHead(301, { "Location": "/b-bridge/" });
    res.end();
    return;
  }

  const forwardedHeaders = {
    ...req.headers,
    "x-forwarded-host": req.headers.host,
    "x-forwarded-proto": "http",
    "x-forwarded-for": req.socket.remoteAddress || "",
  };

  let targetHost = route.host;
  let targetPort = route.port;
  let targetPath = req.url;

  if (hostname === "portal.arfab.kr" && req.url.startsWith("/api/md2html/")) {
    targetHost = "127.0.0.1";
    targetPort = 8090;
    targetPath = req.url.replace("/api/md2html/", "/api/");
  } else if (hostname === "portal.arfab.kr" && req.url.startsWith("/api/mdconversion/")) {
    targetHost = "127.0.0.1";
    targetPort = 8089;
    targetPath = req.url.replace("/api/mdconversion/", "/");
  } else if (hostname === "portal.arfab.kr" && req.url.toLowerCase().startsWith("/startupclub")) {
    targetHost = "127.0.0.1";
    targetPort = 3004;
  } else if (hostname === "portal.arfab.kr" && req.url.toLowerCase().startsWith("/b-bridge")) {
    targetHost = "127.0.0.1";
    targetPort = 3005;
  } else if (hostname === "portal.arfab.kr" && req.url.toLowerCase().startsWith("/chatbotrag")) {
    targetHost = "127.0.0.1";
    targetPort = 8003;
  } else if (hostname === "bbridge.arfab.kr" || hostname === "b-bridge.arfab.kr") {
    targetHost = "127.0.0.1";
    targetPort = 3005;
    if (!targetPath.toLowerCase().startsWith("/b-bridge")) {
      targetPath = "/b-bridge" + (targetPath.startsWith("/") ? targetPath : "/" + targetPath);
    }
  } else if (route.apiPort && req.url.startsWith("/api/")) {
    targetHost = "127.0.0.1";
    targetPort = route.apiPort;
  }

  const proxyReq = http.request(
    {
      hostname: targetHost,
      port: targetPort,
      path: targetPath,
      method: req.method,
      headers: forwardedHeaders,
    },
    (proxyRes) => {
      res.writeHead(proxyRes.statusCode || 502, proxyRes.headers);
      proxyRes.pipe(res);
    },
  );

  proxyReq.on("error", () => unavailable(res, hostname));
  req.pipe(proxyReq);
});

server.on("upgrade", (req, socket, head) => {
  const { route } = findRoute(req.headers.host);
  if (!route) {
    socket.destroy();
    return;
  }

  const upstream = net.connect(route.port, route.host, () => {
    const requestLine = `${req.method} ${req.url} HTTP/${req.httpVersion}\r\n`;
    const headers = Object.entries(req.headers)
      .map(([key, value]) => `${key}: ${Array.isArray(value) ? value.join(", ") : value}`)
      .join("\r\n");
    upstream.write(`${requestLine}${headers}\r\n\r\n`);
    if (head.length) upstream.write(head);
    socket.pipe(upstream).pipe(socket);
  });

  upstream.on("error", () => socket.destroy());
});

server.listen(listenPort, "0.0.0.0", () => {
  console.log(`ARFab gateway listening on port ${listenPort}`);
  for (const [hostname, route] of Object.entries(routes)) {
    console.log(`  ${hostname} -> ${route.host}:${route.port} (${route.name})`);
  }
});
