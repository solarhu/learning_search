package models

import (
	"testing"
)

func TestSplitLines(t *testing.T) {
	tests := []struct {
		input    string
		expected []string
	}{
		{
			input:    "line1\nline2\nline3",
			expected: []string{"line1", "line2", "line3"},
		},
		{
			input:    "single line",
			expected: []string{"single line"},
		},
		{
			input:    "",
			expected: []string{},
		},
		{
			input:    "line1\n\nline3",
			expected: []string{"line1", "", "line3"},
		},
	}

	for _, test := range tests {
		result := splitLines(test.input)
		if len(result) != len(test.expected) {
			t.Errorf("for input '%s', expected %d lines, got %d", test.input, len(test.expected), len(result))
			continue
		}
		for i, line := range result {
			if line != test.expected[i] {
				t.Errorf("for input '%s', line %d: expected '%s', got '%s'", test.input, i, test.expected[i], line)
			}
		}
	}
}

func TestGeneratePDF(t *testing.T) {
	markdown := `# Title

## Subtitle

This is content.

- List item 1
- List item 2

## Another section

More content here.
`

	pdf := GeneratePDF(markdown)
	if pdf == nil {
		t.Error("expected PDF to not be nil")
	}

	if pdf.Error() != nil {
		t.Errorf("PDF generation error: %v", pdf.Error())
	}
}

func TestGeneratePDFWithEmptyInput(t *testing.T) {
	pdf := GeneratePDF("")
	if pdf == nil {
		t.Error("expected PDF to not be nil even with empty input")
	}
}

func TestGeneratePDFWithOnlyHeaders(t *testing.T) {
	markdown := `# Header 1
## Header 2
### Header 3`

	pdf := GeneratePDF(markdown)
	if pdf == nil {
		t.Error("expected PDF to not be nil")
	}
}
