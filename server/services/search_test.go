package services

import (
	"os"
	"testing"

	"github.com/you/learning_search/models"
)

func TestNewSearchService(t *testing.T) {
	originalApiKey := os.Getenv("OPENAI_API_KEY")
	originalApiBase := os.Getenv("OPENAI_API_BASE")
	originalModel := os.Getenv("OPENAI_MODEL")

	defer func() {
		os.Setenv("OPENAI_API_KEY", originalApiKey)
		os.Setenv("OPENAI_API_BASE", originalApiBase)
		os.Setenv("OPENAI_MODEL", originalModel)
	}()

	os.Setenv("OPENAI_API_KEY", "test-key")
	os.Setenv("OPENAI_API_BASE", "https://test.api.com/v1")
	os.Setenv("OPENAI_MODEL", "test-model")

	svc := NewSearchService()

	if svc.apiKey != "test-key" {
		t.Errorf("expected apiKey to be 'test-key', got '%s'", svc.apiKey)
	}
	if svc.apiBase != "https://test.api.com/v1" {
		t.Errorf("expected apiBase to be 'https://test.api.com/v1', got '%s'", svc.apiBase)
	}
	if svc.model != "test-model" {
		t.Errorf("expected model to be 'test-model', got '%s'", svc.model)
	}
}

func TestNewSearchServiceWithEnvFile(t *testing.T) {
	envContent := `OPENAI_API_KEY=file-key
OPENAI_API_BASE=https://file.api.com/v1
OPENAI_MODEL=file-model`

	tmpFile, err := os.CreateTemp("", ".env")
	if err != nil {
		t.Fatal(err)
	}
	defer os.Remove(tmpFile.Name())

	if _, err := tmpFile.Write([]byte(envContent)); err != nil {
		t.Fatal(err)
	}
	tmpFile.Close()

	originalDir, err := os.Getwd()
	if err != nil {
		t.Fatal(err)
	}
	defer os.Chdir(originalDir)

	if err := os.Chdir(os.TempDir()); err != nil {
		t.Fatal(err)
	}

	os.Rename(tmpFile.Name(), ".env")
	defer os.Remove(".env")

	svc := NewSearchService()

	if svc.apiKey != "file-key" {
		t.Errorf("expected apiKey to be 'file-key', got '%s'", svc.apiKey)
	}
	if svc.apiBase != "https://file.api.com/v1" {
		t.Errorf("expected apiBase to be 'https://file.api.com/v1', got '%s'", svc.apiBase)
	}
	if svc.model != "file-model" {
		t.Errorf("expected model to be 'file-model', got '%s'", svc.model)
	}
}

func TestSearchWithEmptyApiKey(t *testing.T) {
	svc := &SearchService{
		apiKey:  "",
		apiBase: "https://api.openai.com/v1",
		model:   "gpt-4o",
	}

	result, err := svc.Search("test question")
	if err != nil {
		t.Errorf("expected no error with empty apiKey, got: %v", err)
	}
	if result == nil {
		t.Error("expected result to not be nil")
	}
	if result.Answer == "" {
		t.Error("expected answer to not be empty")
	}
	if len(result.Keywords) == 0 {
		t.Error("expected keywords to not be empty")
	}
}

func TestExplainWithEmptyApiKey(t *testing.T) {
	svc := &SearchService{
		apiKey:  "",
		apiBase: "https://api.openai.com/v1",
		model:   "gpt-4o",
	}

	result, err := svc.Explain("test keyword")
	if err != nil {
		t.Errorf("expected no error with empty apiKey, got: %v", err)
	}
	if result == nil {
		t.Error("expected result to not be nil")
	}
	if result.Explanation == "" {
		t.Error("expected explanation to not be empty")
	}
}

func TestGenerateDocumentWithEmptyApiKey(t *testing.T) {
	svc := &SearchService{
		apiKey:  "",
		apiBase: "https://api.openai.com/v1",
		model:   "gpt-4o",
	}

	req := models.GenerateDocumentRequest{
		Question:     "test question",
		Explanations: map[string]string{"keyword1": "explanation1"},
	}

	result, err := svc.GenerateDocument(req)
	if err != nil {
		t.Errorf("expected no error with empty apiKey, got: %v", err)
	}
	if result == nil {
		t.Error("expected result to not be nil")
	}
	if result.Markdown == "" {
		t.Error("expected markdown to not be empty")
	}
	if result.Mindmap == "" {
		t.Error("expected mindmap to not be empty")
	}
}

func TestCallOpenAIWithEmptyApiKey(t *testing.T) {
	svc := &SearchService{
		apiKey:  "",
		apiBase: "https://api.openai.com/v1",
		model:   "gpt-4o",
	}

	_, err := svc.callOpenAI("test prompt")
	if err == nil {
		t.Error("expected error with empty apiKey")
	}
	if err.Error() != "OPENAI_API_KEY not configured" {
		t.Errorf("expected specific error message, got: %s", err.Error())
	}
}
