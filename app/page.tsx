"use client";

import { useMemo, useState } from "react";

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
];

export default function Home() {
  const [activeCategory, setActiveCategory] = useState("all");
  const [query, setQuery] = useState("");

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
            <article className="solution-card" key={solution.id}>
              <div className="card-top">
                <div className="solution-icon" aria-hidden="true">
                  <span>{solution.icon}</span>
                </div>
                <span className="status"><i />{solution.status}</span>
              </div>
              <div className="card-body">
                <p className="category-kicker">프로젝트 · 사업화</p>
                <h3>{solution.name}</h3>
                <p>{solution.description}</p>
                <div className="tags">
                  {solution.tags.map((tag) => <span key={tag}>{tag}</span>)}
                </div>
              </div>
              <div className="card-footer">
                <div>
                  <small>LOCAL SOURCE</small>
                  <span title={solution.source}>DSUGamePortal</span>
                </div>
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
