package handlers

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/you/learning_search/models"
	"github.com/you/learning_search/services"
)

func TestSearchHandler(t *testing.T) {
	svc := services.NewSearchService()
	handler := NewSearchHandler(svc)

	reqBody := models.SearchRequest{Question: "test question"}
	body, _ := json.Marshal(reqBody)

	req := httptest.NewRequest("POST", "/api/search", strings.NewReader(string(body)))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	handler.Search(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("expected status 200, got %d", w.Code)
	}

	var resp models.SearchResponse
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Errorf("failed to parse response: %v", err)
	}

	if resp.Answer == "" {
		t.Error("expected answer to not be empty")
	}
	if len(resp.Keywords) == 0 {
		t.Error("expected keywords to not be empty")
	}
}

func TestSearchHandlerInvalidBody(t *testing.T) {
	svc := services.NewSearchService()
	handler := NewSearchHandler(svc)

	req := httptest.NewRequest("POST", "/api/search", strings.NewReader("invalid json"))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	handler.Search(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected status 400, got %d", w.Code)
	}
}

func TestExplainHandler(t *testing.T) {
	svc := services.NewSearchService()
	handler := NewSearchHandler(svc)

	reqBody := models.ExplainRequest{Keyword: "test keyword"}
	body, _ := json.Marshal(reqBody)

	req := httptest.NewRequest("POST", "/api/explain", strings.NewReader(string(body)))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	handler.Explain(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("expected status 200, got %d", w.Code)
	}

	var resp models.ExplainResponse
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Errorf("failed to parse response: %v", err)
	}

	if resp.Explanation == "" {
		t.Error("expected explanation to not be empty")
	}
}

func TestExplainHandlerInvalidBody(t *testing.T) {
	svc := services.NewSearchService()
	handler := NewSearchHandler(svc)

	req := httptest.NewRequest("POST", "/api/explain", strings.NewReader("invalid json"))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	handler.Explain(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected status 400, got %d", w.Code)
	}
}

func TestExplainCustomHandler(t *testing.T) {
	svc := services.NewSearchService()
	handler := NewSearchHandler(svc)

	reqBody := models.ExplainCustomRequest{Keyword: "test keyword", UserNote: "user note"}
	body, _ := json.Marshal(reqBody)

	req := httptest.NewRequest("POST", "/api/explain-custom", strings.NewReader(string(body)))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	handler.ExplainCustom(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("expected status 200, got %d", w.Code)
	}

	var resp models.ExplainResponse
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Errorf("failed to parse response: %v", err)
	}

	if resp.Explanation == "" {
		t.Error("expected explanation to not be empty")
	}
}

func TestGenerateDocumentHandler(t *testing.T) {
	svc := services.NewSearchService()
	handler := NewSearchHandler(svc)

	reqBody := models.GenerateDocumentRequest{
		Question:     "test question",
		Explanations: map[string]string{"keyword1": "explanation1"},
	}
	body, _ := json.Marshal(reqBody)

	req := httptest.NewRequest("POST", "/api/generate-document", strings.NewReader(string(body)))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	handler.GenerateDocument(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("expected status 200, got %d", w.Code)
	}

	var resp models.GenerateDocumentResponse
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Errorf("failed to parse response: %v", err)
	}

	if resp.Markdown == "" {
		t.Error("expected markdown to not be empty")
	}
	if resp.Mindmap == "" {
		t.Error("expected mindmap to not be empty")
	}
}

func TestExportHandlerMarkdown(t *testing.T) {
	svc := services.NewSearchService()
	handler := NewSearchHandler(svc)

	reqBody := models.ExportRequest{
		Markdown: "# Test\n\nThis is test content.",
		Format:   "md",
	}
	body, _ := json.Marshal(reqBody)

	req := httptest.NewRequest("POST", "/api/export", strings.NewReader(string(body)))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	handler.Export(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("expected status 200, got %d", w.Code)
	}

	if w.Header().Get("Content-Type") != "text/markdown" {
		t.Errorf("expected Content-Type to be text/markdown, got %s", w.Header().Get("Content-Type"))
	}

	if w.Body.String() != "# Test\n\nThis is test content." {
		t.Errorf("expected body to match input markdown")
	}
}

func TestExportHandlerPDF(t *testing.T) {
	svc := services.NewSearchService()
	handler := NewSearchHandler(svc)

	reqBody := models.ExportRequest{
		Markdown: "# Test\n\nThis is test content.",
		Format:   "pdf",
	}
	body, _ := json.Marshal(reqBody)

	req := httptest.NewRequest("POST", "/api/export", strings.NewReader(string(body)))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	handler.Export(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("expected status 200, got %d", w.Code)
	}

	if w.Header().Get("Content-Type") != "application/pdf" {
		t.Errorf("expected Content-Type to be application/pdf, got %s", w.Header().Get("Content-Type"))
	}
}

func TestExportHandlerInvalidFormat(t *testing.T) {
	svc := services.NewSearchService()
	handler := NewSearchHandler(svc)

	reqBody := models.ExportRequest{
		Markdown: "# Test",
		Format:   "invalid",
	}
	body, _ := json.Marshal(reqBody)

	req := httptest.NewRequest("POST", "/api/export", strings.NewReader(string(body)))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	handler.Export(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected status 400, got %d", w.Code)
	}
}
