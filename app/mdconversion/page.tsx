"use client";

import React, { useState, useRef, useEffect } from 'react';
import { 
  UploadCloud, FileText, CheckCircle2, Download, Eye, X, Copy, Save, 
  FileSpreadsheet, Play, FileQuestion, FileWarning, Loader2, ArrowLeft, Check
} from 'lucide-react';
import { marked } from 'marked';
import './mdconversion.css';

const API_BASE = "/api/mdconversion";

export default function MdConversionPage() {
  const [files, setFiles] = useState<any[]>([]);
  const [isDragActive, setIsDragActive] = useState(false);
  const [activeDrawerFileId, setActiveDrawerFileId] = useState<string | null>(null);
  const [drawerText, setDrawerText] = useState("");
  const [toast, setToast] = useState({ show: false, message: "" });
  
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Configure marked options
  useEffect(() => {
    marked.setOptions({
      breaks: true,
      gfm: true
    });
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
      const validExtensions = ['pdf', 'docx', 'pptx', 'xlsx', 'hwpx'];
      
      if (!ext || !validExtensions.includes(ext)) {
        showToast(`지원하지 않는 파일 형식입니다: .${ext}`);
        return;
      }

      const fileId = Math.random().toString(36).substring(2, 9);
      const newFileObj = {
        id: fileId,
        name: file.name,
        size: file.size,
        type: ext,
        status: 'converting',
        progress: 0,
        markdown: '',
        previewMarkdown: '',
        hasImages: false,
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
      const response = await fetch(`${API_BASE}/api/convert`, {
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
            previewMarkdown: data.preview_markdown,
            hasImages: data.has_images,
            taskId: data.task_id
          };
        }
        return f;
      }));
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

  const handleDownload = async (fileObj: any) => {
    if (!fileObj.taskId) return;
    
    // Choose zip if has images, otherwise raw md
    const endpoint = fileObj.hasImages ? 'zip' : 'md';
    const url = `${API_BASE}/api/download/${fileObj.taskId}/${endpoint}?filename=${encodeURIComponent(fileObj.name)}`;
    
    // Trigger download
    const link = document.createElement('a');
    link.href = url;
    link.setAttribute('download', '');
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const handleBulkZipDownload = async () => {
    const completedFiles = files.filter(f => f.status === 'complete');
    if (completedFiles.length === 0) return;

    try {
      const requestData = {
        task_ids: completedFiles.map(f => f.taskId),
        filenames: completedFiles.map(f => f.name)
      };

      const response = await fetch(`${API_BASE}/api/download/bulk-zip`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(requestData)
      });

      if (!response.ok) throw new Error("Bulk download failed");

      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', 'converted_documents.zip');
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      window.URL.revokeObjectURL(url);
    } catch (err) {
      showToast("일괄 다운로드 중 오류가 발생했습니다.");
    }
  };

  const openPreview = (fileObj: any) => {
    setActiveDrawerFileId(fileObj.id);
    setDrawerText(fileObj.markdown);
  };

  const closePreview = () => {
    setActiveDrawerFileId(null);
    setDrawerText("");
  };

  const saveDrawerChanges = () => {
    setFiles(prev => prev.map(f => {
      if (f.id === activeDrawerFileId) {
        const images = f.markdown === drawerText ? [] : (drawerText.match(/images[/\\]([^)\s]+)/g) || []);
        let newPreview = drawerText;
        images.forEach(imgRef => {
          const imgName = imgRef.replace(/images[/\\]/, '');
          newPreview = newPreview.replace(imgRef, `${API_BASE}/api/files/${f.taskId}_output/images/${imgName}`);
        });

        return {
          ...f,
          markdown: drawerText,
          previewMarkdown: newPreview
        };
      }
      return f;
    }));
    showToast("수정사항이 저장되었습니다.");
  };

  const copyToClipboard = () => {
    navigator.clipboard.writeText(drawerText);
    showToast("클립보드에 복사되었습니다!");
  };

  const downloadEditedMd = () => {
    const activeFile = files.find(f => f.id === activeDrawerFileId);
    if (!activeFile) return;

    const blob = new Blob([drawerText], { type: "text/markdown;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    
    const baseName = activeFile.name.substring(0, activeFile.name.lastIndexOf('.')) || activeFile.name;
    link.href = url;
    link.setAttribute('download', `${baseName}.md`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  };

  const activeFile = files.find(f => f.id === activeDrawerFileId);

  const renderMarkdown = () => {
    if (!activeFile) return { __html: "" };
    let processed = drawerText;
    
    const pattern = /images[/\\]([^)\s]+)/g;
    processed = processed.replace(pattern, `${API_BASE}/api/files/${activeFile.taskId}_output/images/$1`);
    
    return { __html: marked.parse(processed) as string };
  };

  const formatSize = (bytes: number) => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  const getFileIcon = (type: string) => {
    switch (type) {
      case 'xlsx':
        return <FileSpreadsheet className="file-icon" size={24} />;
      case 'pdf':
        return <FileText className="file-icon" size={24} style={{ color: '#f43f5e' }} />;
      case 'docx':
        return <FileText className="file-icon" size={24} style={{ color: '#3b82f6' }} />;
      case 'pptx':
        return <FileText className="file-icon" size={24} style={{ color: '#f97316' }} />;
      case 'hwpx':
        return <FileText className="file-icon" size={24} style={{ color: '#06b6d4' }} />;
      default:
        return <FileQuestion className="file-icon" size={24} />;
    }
  };

  const completedCount = files.filter(f => f.status === 'complete').length;

  return (
    <>
      <div className="background-glow">
        <div className="glow-orb orb-1"></div>
        <div className="glow-orb orb-2"></div>
        <div className="glow-orb orb-3"></div>
      </div>

      <div className="app-container">
        {/* Navigation Back to Portal */}
        <div style={{ display: 'flex', alignItems: 'center', marginBottom: '15px' }}>
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

        <header className="app-header">
          <h1 className="app-title">문서 ➔ Markdown 변환기</h1>
          <p className="app-subtitle">
            PDF · DOCX · PPTX · XLSX · HWPX 파일을 Markdown으로 변환합니다.
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
            accept=".pdf,.docx,.pptx,.xlsx,.hwpx"
            style={{ display: 'none' }} 
          />
          <div className="dropzone-icon">
            <UploadCloud size={32} />
          </div>
          <p className="dropzone-text">파일을 드래그하거나 클릭해서 선택하세요</p>
          <p className="dropzone-subtext">.pdf, .docx, .pptx, .xlsx, .hwpx</p>
        </div>

        {/* Bulk Actions */}
        {files.length > 0 && (
          <div className="actions-bar">
            <button 
              className="btn-zip-download"
              onClick={handleBulkZipDownload}
              disabled={completedCount === 0}
            >
              <Download size={16} />
              전체 zip 다운로드
            </button>
          </div>
        )}

        {/* File List */}
        <div className="file-list">
          {files.map(file => (
            <div key={file.id} className="file-item">
              <div className="file-info">
                {getFileIcon(file.type)}
                <span className="file-name" title={file.name}>
                  {file.name}
                </span>
              </div>
              
              <div className="file-status-actions">
                {file.status === 'converting' && (
                  <span className="badge badge-loading">
                    <Loader2 className="spinner" size={12} />
                    변환 중
                  </span>
                )}
                {file.status === 'error' && (
                  <span className="badge badge-error">
                    <FileWarning size={12} />
                    오류
                  </span>
                )}
                {file.status === 'complete' && (
                  <>
                    <span className="badge badge-complete">
                      <CheckCircle2 size={12} />
                      완료
                    </span>
                    <a className="action-link" onClick={() => openPreview(file)}>
                      미리보기
                    </a>
                    <a className="action-link" onClick={() => handleDownload(file)}>
                      다운로드
                    </a>
                  </>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Slide-out Preview Drawer */}
      <div className={`drawer-backdrop ${activeDrawerFileId ? 'open' : ''}`} onClick={closePreview} />
      <div className={`drawer ${activeDrawerFileId ? 'open' : ''}`}>
        {activeFile && (
          <>
            <div className="drawer-header">
              <div className="drawer-title-area">
                <span className="drawer-title">{activeFile.name}</span>
                <span className="drawer-subtitle">
                  크기: {formatSize(activeFile.size)} | 형식: {activeFile.type.toUpperCase()}
                </span>
              </div>
              <div className="drawer-actions">
                <button className="btn-action" onClick={copyToClipboard}>
                  <Copy size={14} />
                  Markdown 복사
                </button>
                <button className="btn-action" onClick={saveDrawerChanges}>
                  <Save size={14} />
                  수정사항 저장
                </button>
                <button className="btn-action" onClick={downloadEditedMd}>
                  <Download size={14} />
                  Markdown 파일 다운로드
                </button>
                <button className="btn-close" onClick={closePreview}>
                  <X size={20} />
                </button>
              </div>
            </div>
            <div className="drawer-content">
              {/* Left Column: Editor */}
              <div className="pane pane-left">
                <div className="pane-header">
                  <FileText size={12} /> Markdown 편집기
                </div>
                <textarea
                  className="markdown-editor"
                  value={drawerText}
                  onChange={(e) => setDrawerText(e.target.value)}
                  placeholder="Markdown 내용을 여기에 입력하세요..."
                />
              </div>
              {/* Right Column: Preview */}
              <div className="pane pane-right">
                <div className="pane-header">
                  <Eye size={12} /> 실시간 미리보기
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

      {/* Copy/Status Toast */}
      <div className={`toast ${toast.show ? 'show' : ''}`}>
        <Check size={16} style={{ color: 'var(--success-color)' }} />
        <span>{toast.message}</span>
      </div>
    </>
  );
}
