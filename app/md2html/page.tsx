"use client";

import React, { useState, useRef, useEffect } from 'react';
import { 
  UploadCloud, FileText, CheckCircle2, Download, Eye, X, Copy, Save, 
  FileWarning, Loader2, ArrowLeft, RefreshCw, FileCode, Check
} from 'lucide-react';
import { marked } from 'marked';
import './md2html.css';

// Using relative path for API_BASE so that requests are sent through the gateway (port 80)
// which will rewrite '/api/md2html' to '/api' and proxy them to the backend server (port 8090)
const API_BASE = "/api/md2html";

export default function Md2HtmlPage() {
  const [files, setFiles] = useState<any[]>([]);
  const [isDragActive, setIsDragActive] = useState(false);
  const [activeDrawerFileId, setActiveDrawerFileId] = useState<string | null>(null);
  const [drawerText, setDrawerText] = useState("");
  const [toast, setToast] = useState({ show: false, message: "" });
  const [isSaving, setIsSaving] = useState(false);
  
  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    marked.setOptions({
      breaks: true,
      gfm: true
    });

    const preventDefault = (e: DragEvent) => e.preventDefault();
    window.addEventListener("dragover", preventDefault);
    window.addEventListener("drop", preventDefault);

    return () => {
      window.removeEventListener("dragover", preventDefault);
      window.removeEventListener("drop", preventDefault);
    };
  }, []);

  const showToast = (message: string) => {
    setToast({ show: true, message });
    setTimeout(() => {
      setToast({ show: false, message: "" });
    }, 2500);
  };

  const handleDrag = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.type === "dragenter" || e.type === "dragover") {
      setIsDragActive(true);
    } else if (e.type === "dragleave") {
      setIsDragActive(false);
    }
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragActive(false);
    
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      handleFiles(e.dataTransfer.files);
    }
  };

  const handleFileInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      handleFiles(e.target.files);
    }
  };

  const triggerFileInput = () => {
    fileInputRef.current?.click();
  };

  const handleFiles = (uploadedFiles: FileList) => {
    Array.from(uploadedFiles).forEach(file => {
      const ext = file.name.split('.').pop()?.toLowerCase();
      
      if (ext !== 'md') {
        showToast("Markdown (.md) 파일만 업로드할 수 있습니다.");
        return;
      }

      const fileId = Math.random().toString(36).substring(2, 9);
      const newFileObj = {
        id: fileId,
        name: file.name,
        size: file.size,
        status: 'converting',
        markdown: '',
        taskId: null,
        error: null
      };

      setFiles(prev => [newFileObj, ...prev]);
      uploadAndConvert(file, fileId);
    });
  };

  const uploadAndConvert = async (file: File, fileId: string) => {
    const formData = new FormData();
    formData.append("file", file);

    try {
      const response = await fetch(`${API_BASE}/convert`, {
        method: "POST",
        body: formData,
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.detail || "변환에 실패했습니다.");
      }

      const data = await response.json();
      
      setFiles(prev => prev.map(f => {
        if (f.id === fileId) {
          return {
            ...f,
            status: 'complete',
            markdown: data.markdown,
            taskId: data.task_id
          };
        }
        return f;
      }));
      showToast(`${file.name} 변환이 완료되었습니다.`);
    } catch (err: any) {
      setFiles(prev => prev.map(f => {
        if (f.id === fileId) {
          return {
            ...f,
            status: 'error',
            error: err.message
          };
        }
        return f;
      }));
      showToast(`${file.name} 변환 실패: ${err.message}`);
    }
  };

  const handleDownload = (taskId: string, format: string, originalName: string) => {
    if (!taskId) return;
    const baseName = originalName.substring(0, originalName.lastIndexOf('.')) || originalName;
    const downloadUrl = `${API_BASE}/download/${taskId}/${format}`;
    
    const link = document.createElement('a');
    link.href = downloadUrl;
    link.setAttribute('download', `${baseName}.${format}`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const openPreview = (fileObj: any) => {
    setActiveDrawerFileId(fileObj.id);
    setDrawerText(fileObj.markdown);
  };

  const closePreview = () => {
    setActiveDrawerFileId(null);
    setDrawerText("");
  };

  const saveDrawerChanges = async () => {
    const activeFile = files.find(f => f.id === activeDrawerFileId);
    if (!activeFile) return;

    setIsSaving(true);
    try {
      const response = await fetch(`${API_BASE}/update-task`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          task_id: activeFile.taskId,
          markdown_content: drawerText,
          filename: activeFile.name
        })
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.detail || "저장에 실패했습니다.");
      }

      setFiles(prev => prev.map(f => {
        if (f.id === activeDrawerFileId) {
          return {
            ...f,
            markdown: drawerText
          };
        }
        return f;
      }));
      showToast("수정된 내용으로 문서가 다시 생성되었습니다.");
    } catch (err: any) {
      showToast(`저장 오류: ${err.message}`);
    } finally {
      setIsSaving(false);
    }
  };

  const copyToClipboard = () => {
    navigator.clipboard.writeText(drawerText);
    showToast("클립보드에 복사되었습니다!");
  };

  const activeFile = files.find(f => f.id === activeDrawerFileId);

  const renderMarkdown = () => {
    if (!drawerText) return "";
    return { __html: marked.parse(drawerText) as string };
  };

  const formatSize = (bytes: number) => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  return (
    <>
      <div className="app-container">
        {/* Navigation Back to Portal */}
        <div style={{ display: 'flex', alignItems: 'center', marginBottom: '-10px' }}>
          <button 
            onClick={() => window.location.href = "/"}
            style={{
              background: 'transparent',
              border: 'none',
              color: 'var(--text-muted)',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              fontSize: '0.9rem',
              fontWeight: 600,
              padding: '6px 12px',
              borderRadius: '8px',
              transition: 'all 0.2s'
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.color = 'var(--text-main)';
              e.currentTarget.style.background = 'rgba(255,255,255,0.03)';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.color = 'var(--text-muted)';
              e.currentTarget.style.background = 'transparent';
            }}
          >
            <ArrowLeft size={16} />
            <span>포털 홈으로 돌아가기</span>
          </button>
        </div>

        {/* Header */}
        <header className="app-header">
          <div className="logo-badge">MD CONVERTER</div>
          <h1 className="app-title">Markdown ➔ HTML / DOCX / PDF</h1>
          <p className="app-subtitle">
            마크다운 파일을 드래그앤드롭하여 즉시 3가지 포맷의 문서로 변환하고 자유롭게 편집해 보세요.
          </p>
        </header>

        {/* Drag and Drop Zone */}
        <div 
          className={`dropzone ${isDragActive ? 'active' : ''}`}
          onDragEnter={handleDrag}
          onDragOver={handleDrag}
          onDragLeave={handleDrag}
          onDrop={handleDrop}
          onClick={triggerFileInput}
        >
          <input 
            type="file" 
            ref={fileInputRef}
            onChange={handleFileInputChange}
            multiple
            accept=".md"
            style={{ display: 'none' }} 
          />
          <div className="dropzone-icon-container">
            <UploadCloud className="dropzone-icon" size={40} />
          </div>
          <p className="dropzone-text">마크다운 파일을 드래그하여 놓거나 클릭하여 선택하세요</p>
          <p className="dropzone-subtext">지원 포맷: .md</p>
        </div>

        {/* File List Section */}
        {files.length > 0 && (
          <div className="list-section">
            <div className="list-header">
              <h2 className="list-title">변환 목록 ({files.length})</h2>
            </div>
            
            <div className="file-list">
              {files.map(file => (
                <div key={file.id} className={`file-item ${file.status}`}>
                  <div className="file-info">
                    <div className="file-type-icon">
                      <FileCode size={20} />
                    </div>
                    <div className="file-meta">
                      <span className="file-name" title={file.name}>
                        {file.name}
                      </span>
                      <span className="file-size">{formatSize(file.size)}</span>
                    </div>
                  </div>
                  
                  <div className="file-actions-wrapper">
                    {file.status === 'converting' && (
                      <span className="status-badge loading">
                        <Loader2 className="spinner" size={14} />
                        변환 중
                      </span>
                    )}
                    
                    {file.status === 'error' && (
                      <div className="status-error-group">
                        <span className="status-badge error">
                          <FileWarning size={14} />
                          에러
                        </span>
                        <span className="error-message" title={file.error}>{file.error}</span>
                      </div>
                    )}
                    
                    {file.status === 'complete' && (
                      <div className="download-button-group">
                        {/* Preview */}
                        <button 
                          className="btn-preview" 
                          onClick={() => openPreview(file)}
                          title="문서 편집 및 미리보기"
                        >
                          <Eye size={14} />
                          <span>미리보기 & 편집</span>
                        </button>
                        
                        {/* HTML Download */}
                        <button 
                          className="btn-download html"
                          onClick={() => handleDownload(file.taskId, 'html', file.name)}
                          title="HTML 파일로 다운로드"
                        >
                          <Download size={13} />
                          <span>HTML</span>
                        </button>
                        
                        {/* DOCX Download */}
                        <button 
                          className="btn-download docx"
                          onClick={() => handleDownload(file.taskId, 'docx', file.name)}
                          title="Word(DOCX) 파일로 다운로드"
                        >
                          <Download size={13} />
                          <span>DOCX</span>
                        </button>
                        
                        {/* PDF Download */}
                        <button 
                          className="btn-download pdf"
                          onClick={() => handleDownload(file.taskId, 'pdf', file.name)}
                          title="PDF 파일로 다운로드"
                        >
                          <Download size={13} />
                          <span>PDF</span>
                        </button>
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Slide-out Preview & Editor Drawer */}
      <div className={`drawer-backdrop ${activeDrawerFileId ? 'open' : ''}`} onClick={closePreview} />
      <div className={`drawer ${activeDrawerFileId ? 'open' : ''}`}>
        {activeFile && (
          <>
            <div className="drawer-header">
              <div className="drawer-title-area">
                <span className="drawer-badge">LIVE EDITOR & PREVIEW</span>
                <h3 className="drawer-title">{activeFile.name}</h3>
              </div>
              <div className="drawer-actions">
                <button className="btn-drawer-action secondary" onClick={copyToClipboard}>
                  <Copy size={14} />
                  <span>복사</span>
                </button>
                <button 
                  className={`btn-drawer-action primary ${isSaving ? 'saving' : ''}`} 
                  onClick={saveDrawerChanges}
                  disabled={isSaving}
                >
                  {isSaving ? (
                    <RefreshCw className="spinner" size={14} />
                  ) : (
                    <Save size={14} />
                  )}
                  <span>{isSaving ? "다시 빌드 중..." : "저장 및 변환"}</span>
                </button>
                
                <div className="drawer-downloads-divider"></div>
                
                {/* Drawer direct downloads */}
                <button 
                  className="btn-drawer-download html"
                  onClick={() => handleDownload(activeFile.taskId, 'html', activeFile.name)}
                >
                  HTML
                </button>
                <button 
                  className="btn-drawer-download docx"
                  onClick={() => handleDownload(activeFile.taskId, 'docx', activeFile.name)}
                >
                  DOCX
                </button>
                <button 
                  className="btn-drawer-download pdf"
                  onClick={() => handleDownload(activeFile.taskId, 'pdf', activeFile.name)}
                >
                  PDF
                </button>

                <button className="btn-drawer-close" onClick={closePreview}>
                  <X size={20} />
                </button>
              </div>
            </div>
            
            <div className="drawer-content">
              {/* Left Column: Markdown Editor */}
              <div className="pane pane-editor">
                <div className="pane-header">
                  <FileCode size={14} /> 
                  <span>Markdown 소스 편집</span>
                </div>
                <textarea
                  className="markdown-editor"
                  value={drawerText}
                  onChange={(e) => setDrawerText(e.target.value)}
                  placeholder="마크다운 내용을 여기에 작성하면 실시간 미리보기가 작동합니다..."
                />
              </div>
              
              {/* Right Column: styled HTML preview */}
              <div className="pane pane-preview">
                <div className="pane-header">
                  <Eye size={14} /> 
                  <span>HTML 렌더링 미리보기</span>
                </div>
                <div 
                  className="markdown-preview"
                  dangerouslySetInnerHTML={renderMarkdown()}
                />
              </div>
            </div>
          </>
        )}
      </div>

      {/* Modern Status Toast */}
      <div className={`toast-message ${toast.show ? 'show' : ''}`}>
        <Check size={16} className="toast-icon" />
        <span>{toast.message}</span>
      </div>
    </>
  );
}
