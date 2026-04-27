package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/you/learning_search/models"
	"net/http"
	"os"
	"strings"
)

// SearchService 搜索服务
type SearchService struct {
	apiKey  string
	apiBase string
	model   string
}

// NewSearchService 创建搜索服务
func NewSearchService() *SearchService {
	apiKey := ""
	apiBase := "https://api.openai.com/v1"
	model := "gpt-4o"
	// 尝试从 .env 文件读取
	if _, err := os.Stat(".env"); err == nil {
		data, err := os.ReadFile(".env")
		if err == nil {
			lines := strings.Split(string(data), "\n")
			for _, line := range lines {
				line = strings.TrimSpace(line)
				if line == "" || strings.HasPrefix(line, "#") {
					continue
				}
				parts := strings.SplitN(line, "=", 2)
				if len(parts) == 2 {
					key := strings.TrimSpace(parts[0])
					value := strings.TrimSpace(parts[1])
					switch key {
					case "OPENAI_API_KEY":
						apiKey = value
					case "OPENAI_API_BASE":
						apiBase = value
					case "OPENAI_MODEL":
						model = value
					}
				}
			}
		}
	}
	// 如果 .env 中没找到，尝试读环境变量
	if apiKey == "" {
		apiKey = os.Getenv("OPENAI_API_KEY")
	}
	if envBase := os.Getenv("OPENAI_API_BASE"); envBase != "" {
		apiBase = envBase
	}
	if envModel := os.Getenv("OPENAI_MODEL"); envModel != "" {
		model = envModel
	}
	if apiKey == "" {
		fmt.Println("WARN: OPENAI_API_KEY not set in .env or environment")
	}
	return &SearchService{
		apiKey:  apiKey,
		apiBase: apiBase,
		model:   model,
	}
}

// Search 搜索问题，返回核心答案和关键词列表
func (s *SearchService) Search(question string) (*models.SearchResponse, error) {
	// TODO: 调用 LLM API 生成答案和关键词
	// 这里先用占位实现，后续接入真实 API
	prompt := fmt.Sprintf(`你是一个专业的学习助手。用户问题：%s

请给出：
1. 核心简明答案（300字以内）
2. 列出需要进一步解释的关键词（5-10个）

返回格式必须是JSON：
{
  "answer": "核心答案内容",
  "keywords": ["关键词1", "关键词2"]
}`, question)

	// 调用 OpenAI API
	response, err := s.callOpenAI(prompt)
	if err != nil {
		// 开发环境返回示例数据
		if s.apiKey == "" {
			return &models.SearchResponse{
				Answer: fmt.Sprintf("这是关于%s的核心答案。这里包含若干需要进一步解释的关键词。", question),
				Keywords: []string{
					"概念定义",
					"基本原理",
					"应用场景",
					"优缺点",
				},
			}, nil
		}
		return nil, err
	}

	var result models.SearchResponse
	err = json.Unmarshal([]byte(response), &result)
	if err != nil {
		return nil, fmt.Errorf("parse response failed: %w", err)
	}

	return &result, nil
}

// Explain 解释关键词
func (s *SearchService) Explain(keyword string) (*models.ExplainResponse, error) {
	prompt := fmt.Sprintf(`请详细解释关键词"%s"，适合学习者理解，使用Markdown格式，包含定义、原理和举例。`, keyword)

	response, err := s.callOpenAI(prompt)
	if err != nil {
		if s.apiKey == "" {
			return &models.ExplainResponse{
				Explanation: fmt.Sprintf("# %s\n\n这是%s的详细解释。\n\n## 定义\n\n这里是定义部分...\n\n## 示例\n\n- 示例1\n- 示例2", keyword, keyword),
			}, nil
		}
		return nil, err
	}

	return &models.ExplainResponse{
		Explanation: response,
	}, nil
}

// ExplainCustom 带用户标注的自定义解释
func (s *SearchService) ExplainCustom(keyword, userNote string) (*models.ExplainResponse, error) {
	prompt := fmt.Sprintf(`请解释关键词"%s"，用户提供了个性化标注：%s。请结合用户标注给出更贴合需求的解释，使用Markdown格式。`, keyword, userNote)

	response, err := s.callOpenAI(prompt)
	if err != nil {
		return nil, err
	}

	return &models.ExplainResponse{
		Explanation: response,
	}, nil
}

// GenerateDocument 生成完整学习文档
func (s *SearchService) GenerateDocument(req models.GenerateDocumentRequest) (*models.GenerateDocumentResponse, error) {
	// 构建提示词
	var buf bytes.Buffer
	buf.WriteString(fmt.Sprintf("原始问题：%s\n\n", req.Question))
	buf.WriteString("已收集的关键词解释：\n\n")
	for k, v := range req.Explanations {
		buf.WriteString(fmt.Sprintf("## %s\n%s\n\n", k, v))
	}
	buf.WriteString(`请基于以上内容生成：
1. 一份完整的Markdown格式学习文档，结构清晰，适合深度学习
2. 一份思维导图Markdown格式（使用-缩进表示层级）

返回格式必须是JSON：
{
  "markdown": "完整文档内容",
  "mindmap": "思维导图内容"
}
`)

	response, err := s.callOpenAI(buf.String())
	if err != nil {
		if s.apiKey == "" {
			// 返回示例数据
			md := fmt.Sprintf("# %s\n\n## 概述\n\n这是关于%s的完整学习文档。\n\n", req.Question, req.Question)
			for k, v := range req.Explanations {
				md += fmt.Sprintf("## %s\n\n%s\n\n", k, v)
			}
			md += "## 总结\n\n本文整理了相关知识点，供进一步学习。\n"

			mindmap := fmt.Sprintf("- %s\n  - 概述\n", req.Question)
			for k := range req.Explanations {
				mindmap += fmt.Sprintf("  - %s\n", k)
			}
			mindmap += "  - 总结\n"

			return &models.GenerateDocumentResponse{
				Markdown: md,
				Mindmap:  mindmap,
			}, nil
		}
		return nil, err
	}

	var result models.GenerateDocumentResponse
	err = json.Unmarshal([]byte(response), &result)
	if err != nil {
		return nil, fmt.Errorf("parse response failed: %w", err)
	}

	return &result, nil
}

// callOpenAI 调用 OpenAI API
func (s *SearchService) callOpenAI(prompt string) (string, error) {
	if s.apiKey == "" {
		return "", fmt.Errorf("OPENAI_API_KEY not configured")
	}

	type OpenAIRequest struct {
		Model    string `json:"model"`
		Messages []struct {
			Role    string `json:"role"`
			Content string `json:"content"`
		} `json:"messages"`
		Temperature float64 `json:"temperature"`
	}

	request := OpenAIRequest{
		Model:       s.model,
		Temperature: 0.7,
	}
	request.Messages = append(request.Messages, struct {
		Role    string `json:"role"`
		Content string `json:"content"`
	}{
		Role:    "user",
		Content: prompt,
	})

	body, err := json.Marshal(request)
	if err != nil {
		return "", err
	}

	req, err := http.NewRequest("POST", s.apiBase+"/chat/completions", bytes.NewReader(body))
	if err != nil {
		return "", err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+s.apiKey)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	var openAIResp struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
		Error struct {
			Message string `json:"message"`
		} `json:"error"`
	}

	err = json.NewDecoder(resp.Body).Decode(&openAIResp)
	if err != nil {
		return "", err
	}

	if openAIResp.Error.Message != "" {
		return "", fmt.Errorf("openai error: %s", openAIResp.Error.Message)
	}

	if len(openAIResp.Choices) == 0 {
		return "", fmt.Errorf("no response from openai")
	}

	return openAIResp.Choices[0].Message.Content, nil
}
