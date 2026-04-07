package handlers

import (
	"encoding/json"
	"net/http"
	"github.com/you/learning_search/models"
	"github.com/you/learning_search/services"
)

// SearchHandler API 处理器
type SearchHandler struct {
	searchService *services.SearchService
}

// NewSearchHandler 创建处理器
func NewSearchHandler(s *services.SearchService) *SearchHandler {
	return &SearchHandler{
		searchService: s,
	}
}

// Search 搜索问题
func (h *SearchHandler) Search(w http.ResponseWriter, r *http.Request) {
	var req models.SearchRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	result, err := h.searchService.Search(req.Question)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}

// Explain 解释关键词
func (h *SearchHandler) Explain(w http.ResponseWriter, r *http.Request) {
	var req models.ExplainRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	result, err := h.searchService.Explain(req.Keyword)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}

// ExplainCustom 自定义解释
func (h *SearchHandler) ExplainCustom(w http.ResponseWriter, r *http.Request) {
	var req models.ExplainCustomRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	result, err := h.searchService.ExplainCustom(req.Keyword, req.UserNote)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}

// GenerateDocument 生成学习文档
func (h *SearchHandler) GenerateDocument(w http.ResponseWriter, r *http.Request) {
	var req models.GenerateDocumentRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	result, err := h.searchService.GenerateDocument(req)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}

// Export 导出文档
// 支持两种格式: md (markdown) 和 pdf
func (h *SearchHandler) Export(w http.ResponseWriter, r *http.Request) {
	var req models.ExportRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	switch req.Format {
	case "md":
		// Markdown 导出：直接返回文本内容，设置下载头
		w.Header().Set("Content-Type", "text/markdown")
		w.Header().Set("Content-Disposition", "attachment; filename=learning-document.md")
		w.Write([]byte(req.Markdown))
	case "pdf":
		// PDF 导出：使用 gofpdf 生成
		pdf := models.GeneratePDF(req.Markdown)
		w.Header().Set("Content-Type", "application/pdf")
		w.Header().Set("Content-Disposition", "attachment; filename=learning-document.pdf")
		pdf.Output(w)
	default:
		http.Error(w, "unsupported format: "+req.Format, http.StatusBadRequest)
	}
}
