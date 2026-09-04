"use client";

import { useMemo, useState, useEffect } from "react";

const categories = [
  { id: "all", label: "전체", icon: "✦" },
  { id: "research", label: "연구용", icon: "⌁" },
  { id: "startup", label: "창업지원", icon: "↗" },
  { id: "commercial", label: "프로젝트(사업화)", icon: "◆" },
  { id: "idea", label: "아이디어", icon: "◌" },
  { id: "other", label: "기타", icon: "＋" },
];

const solutions = [
  {
    id: "dsu-game-portal",
    name: "DSU Game Portal",
    description:
      "동서대학교 게임 개발 프로젝트를 발견하고 등록·관리하는 게임 퍼블리싱 포털입니다.",
    category: "commercial",
    icon: "DG",
    href: "http://localhost:8080",
    publicHref: "http://dsu.arfab.kr",
    source: "F:\\create with claude\\DSUGamePortal",
    status: "연결됨",
    tags: ["Game", "Publishing", "FastAPI"],
  },
  {
    id: "equipment-management",
    name: "VFX EquipRent",
    description:
      "영화·VFX 실습 장비의 재고를 확인하고 대여·반납과 관리자 업무를 처리하는 장비 관리 시스템입니다.",
    category: "commercial",
    icon: "EQ",
    href: "http://localhost:8000",
    publicHref: "http://equipment.arfab.kr",
    source: "F:\\Create with Claude\\EquipmentManagement",
    status: "연결됨",
    tags: ["Equipment", "Rental", "Flask"],
  },
  {
    id: "army-ocr",
    name: "Army OCR",
    description:
      "문서와 이미지에서 텍스트를 인식하고 결과를 관리·활용하는 AI OCR 웹 애플리케이션입니다.",
    category: "commercial",
    icon: "OC",
    href: "http://localhost:8001",
    source: "F:\\Create with Claude\\OCR",
    status: "연결됨",
    tags: ["OCR", "Document AI", "FastAPI"],
    disabled: true, // 보안상 비활성화 설정 (나중에 해제하려면 이 줄을 지우거나 false로 수정)
  },
  {
    id: "chatbot-with-rag",
    name: "ChatBot with RAG",
    description:
      "기관 맞춤형 RAG를 기반으로 지식 문서를 학습하여 답변하고, 4K 실사 AI 아바타(HeyGen)와 대화하는 안내원 시스템입니다.",
    category: "commercial",
    icon: "CR",
    href: "http://localhost:8003",
    publicHref: "http://chatbotrag.arfab.kr",
    source: "H:\\Create with Anti\\ChatBot based on RAG",
    status: "연결됨",
    tags: ["ChatBot", "RAG", "HeyGen", "AI Human"],
  },
  {
    id: "live2d-chatbot",
    name: "Live2D ChatBot",
    description:
      "대학 지식자료를 기반으로 답변하고 음성·캐릭터 인터페이스를 제공하는 AI 챗봇입니다.",
    category: "commercial",
    icon: "CB",
    href: "http://localhost:8002",
    publicHref: "http://chatbot.arfab.kr",
    source: "F:\\Create with Claude\\ChatBot",
    status: "연결됨",
    tags: ["ChatBot", "RAG", "Live2D"],
  },
  {
    id: "mentor-matching",
    name: "창업멘토 매칭시스템",
    description:
      "창업가와 전문 멘토를 매칭하여 피드백과 코칭을 제공하고 멘토링 매칭 현황을 관리하는 창업지원 시스템입니다.",
    category: "startup",
    icon: "MT",
    href: "http://localhost:3001",
    publicHref: "http://mentor.arfab.kr",
    source: "H:\\Create with Codex\\창업관련\\창업멘토매칭시스템",
    status: "연결됨",
    tags: ["Startup", "Mentor", "Next.js"],
  },
  {
    id: "startup-club",
    name: "유학생 창업동아리 관리",
    description:
      "유학생 창업동아리의 소속원 정보, 의무 활동 이력, 사업비 예산현황 및 멘토 일지를 통합 관리하는 창업지원 시스템입니다.",
    category: "startup",
    icon: "SC",
    href: "http://localhost:3004",
    publicHref: "http://club.arfab.kr",
    source: "H:\\Create with Codex\\창업관련\\유학생창업동아리\\startup-club-manager",
    status: "연결됨",
    tags: ["Startup", "Club", "Next.js"],
  },
  {
    id: "b-bridge",
    name: "유학생 정주지원 B-Bridge",
    description:
      "부산형 RISE 사업 연계 동서대학교 외국인 유학생 정주지원 및 지산학협의체 60개 참여기업 통합 정보시스템입니다.",
    category: "startup",
    icon: "BB",
    href: "http://localhost:3005/b-bridge/",
    publicHref: "http://bbridge.arfab.kr",
    source: "H:\\Create with Anti\\B-Bridge",
    status: "연결됨",
    tags: ["RISE", "B-Bridge", "유학생정주", "React"],
  },
  {
    id: "md-conversion",
    name: "MD문서 변환기",
    description:
      "PDF, DOCX, PPTX, XLSX, HWPX 문서를 고품질 Markdown으로 변환하고 표와 이미지를 추출·편집하는 도구입니다.",
    category: "idea",
    icon: "MD",
    href: "/mdconversion",
    publicHref: "/mdconversion",
    source: "H:\\Create with Codex\\Idea2Real\\MDConversion",
    status: "연결됨",
    tags: ["Markdown", "Converter", "FastAPI", "React"],
  },
  {
    id: "md-to-html-docx-pdf",
    name: "MD2HTMLDOCPDF 변환기",
    description:
      "Markdown 파일을 드래그앤 드롭하여 고품질 HTML, DOCX, PDF 파일로 변환하는 도구입니다.",
    category: "idea",
    icon: "MP",
    href: "/md2html",
    publicHref: "/md2html",
    source: "H:\\Create with Codex\\Idea2Real\\MD2HTMLDOCPDF",
    status: "연결됨",
    tags: ["Markdown", "HTML", "DOCX", "PDF"],
  },
];

export default function Home() {
  const [activeCategory, setActiveCategory] = useState("all");
  const [query, setQuery] = useState("");
  const [statuses, setStatuses] = useState<Record<string, string>>({});

  useEffect(() => {
    // Ping all solutions in parallel to check live status
    solutions.forEach(async (solution) => {
      if (solution.disabled) return;
      
      const pingUrl = solution.publicHref
        ? (solution.publicHref.startsWith("http") ? solution.publicHref : window.location.origin + solution.publicHref)
        : solution.href;

      try {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 2000);
        
        // Fetch in HEAD mode with no-cors to safely check port binding
        await fetch(pingUrl, {
          method: "HEAD",
          mode: "no-cors",
          signal: controller.signal
        });
        clearTimeout(timeoutId);
        setStatuses(prev => ({ ...prev, [solution.id]: "연결됨" }));
      } catch (err) {
        setStatuses(prev => ({ ...prev, [solution.id]: "서버 꺼짐" }));
      }
    });
  }, []);

  const visibleSolutions = useMemo(() => {
    const normalized = query.trim().toLowerCase();
    return solutions.filter((solution) => {
      const inCategory =
        activeCategory === "all" || solution.category === activeCategory;
      const matchesQuery =
        !normalized ||
        `${solution.name} ${solution.description} ${solution.tags.join(" ")}`
          .toLowerCase()
          .includes(normalized);
      return inCategory && matchesQuery;
    });
  }, [activeCategory, query]);

  const activeLabel =
    categories.find((category) => category.id === activeCategory)?.label ?? "전체";

  return (
    <main>
      <header className="topbar">
        <a className="brand" href="#" aria-label="AI 솔루션 포털 홈">
          <span className="brand-mark">AI</span>
          <span>
            <strong>Solution Portal</strong>
            <small>나의 AI 서비스 허브</small>
          </span>
        </a>
        <div className="top-actions">
          <label className="search">
            <span>⌕</span>
            <input
              type="search"
              placeholder="솔루션 검색"
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              aria-label="솔루션 검색"
            />
          </label>
          <button className="add-button" type="button" title="다음 단계에서 관리 기능을 연결합니다">
            <span>＋</span> 솔루션 등록
          </button>
        </div>
      </header>

      <section className="hero">
        <div className="hero-copy">
          <p className="eyebrow">MY AI WORKSPACE</p>
          <h1>
            아이디어를 발견하고,
            <br />
            <em>솔루션으로 연결하세요.</em>
          </h1>
          <p className="hero-description">
            연구부터 사업화까지, 직접 만든 AI 서비스를 한곳에서 찾고 실행하는
            개인 솔루션 포털입니다.
          </p>
        </div>
        <div className="hero-stat" aria-label="등록된 솔루션 수">
          <span className="orbit orbit-one" />
          <span className="orbit orbit-two" />
          <strong>{solutions.length.toString().padStart(2, "0")}</strong>
          <small>CONNECTED<br />SOLUTIONS</small>
        </div>
      </section>

      <nav className="category-nav" aria-label="솔루션 카테고리">
        {categories.map((category) => (
          <button
            type="button"
            key={category.id}
            className={activeCategory === category.id ? "active" : ""}
            onClick={() => setActiveCategory(category.id)}
          >
            <span>{category.icon}</span>
            {category.label}
            {category.id !== "all" && (
              <small>
                {solutions.filter((solution) => solution.category === category.id).length}
              </small>
            )}
          </button>
        ))}
      </nav>

      <section className="catalog">
        <div className="section-heading">
          <div>
            <p className="eyebrow">SOLUTION LIBRARY</p>
            <h2>{activeLabel} 솔루션</h2>
          </div>
          <p>{visibleSolutions.length}개의 솔루션</p>
        </div>

        <div className="solution-grid">
          {visibleSolutions.map((solution) => (
            <article className="solution-card" key={solution.id} style={solution.disabled ? { opacity: 0.75 } : undefined}>
              <div className="card-top">
                <div className="solution-icon" aria-hidden="true" style={solution.disabled ? { background: "#66736e" } : undefined}>
                  <span>{solution.icon}</span>
                </div>
                <span className="status">
                  <i style={
                    solution.disabled 
                      ? { background: "#a83a3a", boxShadow: "0 0 0 3px #f2dfdf" }
                      : (statuses[solution.id] === "서버 꺼짐" 
                          ? { background: "#a83a3a", boxShadow: "0 0 0 3px #f2dfdf" }
                          : { background: "#2ecc71", boxShadow: "0 0 0 3px #e8f8f5" })
                  } />
                  {solution.disabled 
                    ? "보안 제한" 
                    : (statuses[solution.id] || "확인 중...")}
                </span>
              </div>
              <div className="card-body">
                <p className="category-kicker">{categories.find(c => c.id === solution.category)?.label || "기타"}</p>
                <h3>{solution.name}</h3>
                <p>{solution.description}</p>
                <div className="tags">
                  {solution.tags.map((tag) => <span key={tag}>{tag}</span>)}
                </div>
              </div>
              <div className="card-footer">
                <div>
                  <small>LOCAL SOURCE</small>
                  <span title={solution.source}>{solution.source.split('\\').pop() || solution.source.split('/').pop()}</span>
                </div>
                {solution.disabled ? (
                  <button
                    type="button"
                    disabled
                    style={{
                      padding: "8px 9px",
                      borderRadius: "8px",
                      color: "#f4f4ef",
                      background: "#c0c9c5",
                      fontSize: "9px",
                      fontWeight: 800,
                      cursor: "not-allowed",
                      border: 0,
                    }}
                  >
                    실행 제한
                  </button>
                ) : (
                  <a
                    href={solution.href}
                    target="_blank"
                    rel="noreferrer"
                    onClick={(event) => {
                      if (
                        window.location.hostname === "portal.arfab.kr" &&
                        solution.publicHref
                      ) {
                        event.currentTarget.href = solution.publicHref;
                      }
                    }}
                  >
                    포털 열기 <span>↗</span>
                  </a>
                )}
              </div>
            </article>
          ))}

          {visibleSolutions.length === 0 && (
            <div className="empty-state">
              <span>⌕</span>
              <h3>찾는 솔루션이 없습니다</h3>
              <p>검색어나 카테고리를 바꿔보세요.</p>
            </div>
          )}
        </div>
      </section>

      <footer>
        <span>AI SOLUTION PORTAL</span>
        <p>Build once. Discover anytime.</p>
      </footer>
    </main>
  );
}
