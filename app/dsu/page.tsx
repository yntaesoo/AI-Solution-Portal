"use client";
import { useEffect } from "react";

export default function RedirectPage() {
  useEffect(() => {
    window.location.href = "http://dsu.arfab.kr";
  }, []);

  return (
    <div style={{ padding: 48, fontFamily: "sans-serif", textAlign: "center", minHeight: "60vh", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center" }}>
      <h2 style={{ fontSize: "24px", color: "#14211d", marginBottom: "16px" }}>동서대 게임학과 서비스로 이동 중입니다...</h2>
      <p style={{ color: "#4f615b", fontSize: "15px" }}>
        잠시 후 자동으로 이동하지 않으면{" "}
        <a href="http://dsu.arfab.kr" style={{ color: "#0c79d8", fontWeight: 700, textDecoration: "underline" }}>
          여기를 클릭
        </a>
        하세요.
      </p>
    </div>
  );
}
