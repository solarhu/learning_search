package models

import (
	"github.com/jung-kurt/gofpdf"
)

// SearchRequest 搜索请求
type SearchRequest struct {
	Question string `json:"question"`
}

// SearchResponse 搜索响应
type SearchResponse struct {
	Answer      string   `json:"answer"`
	Keywords    []string `json:"keywords"`
}

// ExplainRequest 解释请求
type ExplainRequest struct {
	Keyword string `json:"keyword"`
}

// ExplainResponse 解释响应
type ExplainResponse struct {
	Explanation string `json:"explanation"`
}

// ExplainCustomRequest 自定义解释请求
type ExplainCustomRequest struct {
	Keyword     string `json:"keyword"`
	UserNote    string `json:"user_note"`
}

// GenerateDocumentRequest 生成文档请求
type GenerateDocumentRequest struct {
	Question     string            `json:"question"`
	Explanations map[string]string `json:"explanations"`
}

// GenerateDocumentResponse 生成文档响应
type GenerateDocumentResponse struct {
	Markdown string `json:"markdown"`
	Mindmap  string `json:"mindmap"`
}

// ExportRequest 导出请求
type ExportRequest struct {
	Markdown string `json:"markdown"`
	Format   string `json:"format"` // pdf, md
}

// ExportResponse 导出响应
type ExportResponse struct {
	DownloadURL string `json:"download_url"`
}

// GeneratePDF 从 Markdown 生成简单 PDF
// 注意：这是基础版本，只处理简单的文本换行，不支持完整 Markdown 格式
func GeneratePDF(markdown string) *gofpdf.Fpdf {
	pdf := gofpdf.New("P", "mm", "A4", "")
	pdf.AddPage()
	pdf.SetFont("Arial", "", 12)

	// 简单按行分割渲染
	lines := splitLines(markdown)
	for _, line := range lines {
		if len(line) == 0 {
			pdf.Ln(5)
			continue
		}
		// 处理标题
		if len(line) > 0 && line[0] == '#' {
			level := 0
			for level < len(line) && line[level] == '#' {
				level++
			}
			pdf.SetFont("Arial", "B", float64(14 + (6 - level)))
			pdf.Ln(2)
			pdf.Cell(0, 5, line[level:])
			pdf.SetFont("Arial", "", 12)
		} else if len(line) > 0 && line[0] == '-' {
			// 列表项
			pdf.Cell(5, 5, "-")
			pdf.MoveTo(10, pdf.GetY())
			pdf.MultiCell(190, 5, line[1:], "", "L", false)
		} else {
			// 普通文本
			pdf.MultiCell(190, 5, line, "", "L", false)
		}
		pdf.Ln(2)
	}
	return pdf
}

func splitLines(s string) []string {
	var lines []string
	start := 0
	for i, c := range s {
		if c == '\n' {
			lines = append(lines, s[start:i])
			start = i + 1
		}
	}
	if start < len(s) {
		lines = append(lines, s[start:])
	}
	return lines
}
