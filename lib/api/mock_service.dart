class MockDataService {
  static const String _demoQuestion = 'openclaw是什么';

  static bool isDemoQuestion(String question) {
    final normalized = question.toLowerCase().trim();
    return normalized.contains('openclaw') || normalized == _demoQuestion;
  }

  static MockSearchResponse getSearchResponse(String question) {
    if (!isDemoQuestion(question)) {
      return MockSearchResponse(
        answer: '这是关于「$question」的模拟答案。要获取真实答案，请配置后端 API 地址。\n\n'
            '主要包含以下几个方面需要深入学习：概念定义、基本原理、应用场景等。\n\n'
            '点击关键词可以获取详细解释。',
        keywords: ['概念定义', '基本原理', '应用场景', '注意事项'],
      );
    }

    return MockSearchResponse(
      answer: 'OpenClaw 是一个开源的 AI 辅助编程工具，专注于提供智能化的代码开发体验。\n\n'
          '它通过集成先进的 AI 模型，帮助开发者更高效地编写、理解和优化代码。'
          '主要特点包括智能代码补全、代码解释、错误诊断等功能。',
      keywords: [
        'AI辅助编程',
        '代码补全',
        '智能开发',
        '开源项目',
        '开发效率',
      ],
    );
  }

  static String getExplanation(String keyword, {String? userNote}) {
    final explanations = <String, String>{
      'AI辅助编程': '''# AI辅助编程

## 定义

AI辅助编程是指利用人工智能技术来增强和优化软件开发过程的方法。OpenClaw 正是这一领域的代表性工具。

## 核心原理

AI辅助编程主要基于以下技术：

1. **大语言模型（LLM）**：理解代码语义和上下文
2. **代码分析引擎**：解析代码结构和依赖关系
3. **上下文感知**：根据项目环境提供个性化建议

## 主要功能

- 智能代码补全
- 代码错误检测和修复建议
- 代码重构和优化建议
- 自然语言转代码
- 代码解释和文档生成

## 应用场景

- 快速原型开发
- 学习新语言或框架
- 代码审查和优化
- 技术文档编写''',

      '代码补全': '''# 代码补全

## 定义

代码补全是 AI辅助编程的核心功能之一，能够根据上下文自动预测并生成代码片段。

## 工作原理

1. **上下文分析**：分析当前文件和项目代码
2. **模式识别**：识别编码模式和常见结构
3. **预测生成**：基于 AI 模型预测下一步代码
4. **语法验证**：确保生成的代码符合语法规则

## 优势

- 减少重复性编码工作
- 降低语法错误概率
- 加速开发流程
- 帮助学习最佳实践

## 实际应用示例

```python
# 输入: def calculate_
# AI 补全建议:
def calculate_average(numbers):
    """计算数字列表的平均值"""
    if not numbers:
        return 0
    return sum(numbers) / len(numbers)
```''',

      '智能开发': '''# 智能开发

## 定义

智能开发是一种新型的软件开发方式，通过 AI 技术赋能开发者，实现更高效、更智能的代码创作流程。

## 核心理念

- **人机协作**：AI 是助手，而非替代
- **渐进增强**：逐步提升开发能力
- **透明可控**：开发者始终掌握决策权

## 关键能力

### 1. 智能理解
- 理解代码意图和业务逻辑
- 识别潜在的 bug 和安全漏洞

### 2. 智能生成
- 根据描述生成代码
- 自动生成测试用例

### 3. 智能优化
- 性能优化建议
- 代码质量评估

## 未来趋势

- 更深度的项目理解
- 多模态交互（代码+图表+文档）
- 团队协作智能化''',

      '开源项目': '''# 开源项目

## 定义

OpenClaw 作为开源项目，意味着其源代码完全公开，任何人都可以查看、使用、修改和分发。

## 开源的意义

### 对开发者
- 学习优秀代码实践
- 参与社区贡献
- 积累技术影响力

### 对用户
- 透明可信，无隐藏行为
- 可定制化修改
- 社区支持和维护

### 对行业
- 促进技术传播
- 降低创新门槛
- 催生生态系统

## 开源许可证

OpenClaw 采用开源许可证，用户可以：
- 自由使用软件
- 研究源代码
- 分发副本
- 修改并发布改进版本

## 如何参与

- 提交 Issue 反馈问题
- 提交 Pull Request 贡献代码
- 参与社区讨论
- 编写文档和教程''',

      '开发效率': '''# 开发效率

## 定义

开发效率是指软件开发过程中单位时间内产出的有效代码量和质量。

## AI 如何提升开发效率

### 时间节省
| 传统方式 | AI辅助 | 节省比例 |
|---------|--------|---------|
| 编写样板代码 | 自动生成 | 70% |
| 查阅文档 | 直接问答 | 60% |
| 调试排错 | 智能诊断 | 50% |

### 质量提升
- 减少人为错误
- 遵循最佳实践
- 代码一致性更好

## 实际数据

研究表明，使用 AI辅助编程工具后：
- 代码编写速度提升 **40-60%**
- Bug 数量减少 **25-30%**
- 新人上手时间缩短 **50%**

## 最佳实践

1. **明确需求**：向 AI 描述清晰的需求
2. **逐步细化**：从大框架到小细节
3. **审查验证**：始终审查 AI 生成的代码
4. **持续学习**：理解 AI 为什么这样写''',

      '概念定义': '''# 概念定义

## 关于「$keyword」

这是模拟的概念解释。在实际使用中，AI 会根据具体问题和上下文生成详细解释。

## 如何获取真实解释

1. 配置后端 API 地址
2. 设置 OpenAI API Key
3. 重新搜索问题

## 提示

真实模式下，解释内容会：
- 针具体问题深度定制
- 包含实际代码示例
- 提供相关参考资料''',

      '基本原理': '''# 基本原理

## 关于「$keyword」

这是模拟的基本原理说明。在实际使用中，AI 会详细阐述相关技术原理。

## 核心要点

- 基础概念理解
- 技术架构分析
- 实现机制说明
- 关键算法解析

## 建议学习路径

1. 先理解基础概念
2. 再深入技术原理
3. 最后结合实践''',

      '应用场景': '''# 应用场景

## 关于「$keyword」

这是模拟的应用场景介绍。在实际使用中，AI 会列举具体的应用案例。

## 典型应用

- 企业级应用开发
- 移动端应用
- Web 前端项目
- 数据分析平台
- 自动化工具开发

## 行业案例

不同行业对技术的应用方式各有特点，建议结合实际需求深入了解.''',

      '注意事项': '''# 注意事项

## 关于「$keyword」

这是模拟的注意事项提醒。在实际使用中，AI 会根据具体技术提供实用建议。

## 常见注意点

### 安全相关
- 数据安全保护
- 权限控制
- 输入验证

### 性能相关
- 资源占用
- 响应时间
- 并发处理

### 维护相关
- 代码规范
- 文档完整性
- 版本管理''',
    };

    String explanation = explanations[keyword] ?? '''# $keyword

## 定义

关于「$keyword」的基础解释。

## 详细说明

这是模拟数据。要获取真实的详细解释，请：
1. 配置后端 API 地址
2. 设置有效的 OpenAI API Key

## 配置方法

参见 README.md 中的部署说明章节。''';

    if (userNote != null && userNote.isNotEmpty) {
      explanation = '''# $keyword

## 您的关注点

根据您的标注："$userNote"

以下是针对性的解释：

${explanations[keyword] ?? '这是关于「$keyword」的基础解释，结合您的需求理解。'}

## 个性化建议

基于您的关注点，建议重点学习上述内容中的相关部分。''';
    }

    return explanation;
  }

  static MockGenerateDocumentResponse generateDocument(
    String question,
    Map<String, String> explanations,
  ) {
    final isDemo = isDemoQuestion(question);

    String markdown;
    String mindmap;

    if (isDemo) {
      markdown = '''# OpenClaw 学习文档

## 概述

本文档系统整理了关于 OpenClaw 的学习内容，帮助您全面了解这一 AI辅助编程工具。

## 核心内容

### 什么是 OpenClaw

OpenClaw 是一个开源的 AI 辅助编程工具，专注于提供智能化的代码开发体验。通过集成先进的 AI 模型，帮助开发者更高效地编写、理解和优化代码。

''';

      for (final entry in explanations.entries) {
        markdown += '''### ${entry.key}

${entry.value}

''';
      }

      markdown += '''## 总结

OpenClaw 作为新一代 AI辅助编程工具，通过智能代码补全、错误诊断等功能，显著提升开发效率。作为开源项目，它为开发者提供了学习、贡献和定制的机会。

## 学习建议

1. **实践为主**：在实际项目中体验 AI辅助功能
2. **循序渐进**：从基础补全到复杂任务
3. **保持思考**：理解 AI 建议，而非盲目接受
4. **参与社区**：贡献代码，反馈问题

## 延伸阅读

- OpenClaw 官方文档
- AI辅助编程最佳实践
- 大语言模型技术原理''';

      mindmap = '''- OpenClaw
  - 核心概念
    - AI辅助编程
    - 开源项目
    - 智能开发
  - 主要功能
    - 代码补全
    - 错误诊断
    - 代码解释
  - 应用价值
    - 提升开发效率
    - 降低错误率
    - 加速学习
  - 使用建议
    - 实践为主
    - 保持思考
    - 参与社区''';
    } else {
      markdown = '''# $question 学习文档

## 概述

这是模拟生成的学习文档。要获取真实的 AI 生成内容，请配置后端 API。

''';

      for (final entry in explanations.entries) {
        markdown += '''### ${entry.key}

${entry.value}

''';
      }

      markdown += '''## 总结

本文档整理了关于「$question」的学习要点。

## 提示

当前为模拟数据模式。配置 API 后可获得更详细、更智能的内容。''';

      mindmap = '''- $question
  - 概述
''';
      for (final key in explanations.keys) {
        mindmap += '''  - $key
''';
      }
      mindmap += '''  - 总结
  - 配置API获取真实内容''';
    }

    return MockGenerateDocumentResponse(
      markdown: markdown,
      mindmap: mindmap,
    );
  }
}

class MockSearchResponse {
  final String answer;
  final List<String> keywords;

  MockSearchResponse({required this.answer, required this.keywords});
}

class MockGenerateDocumentResponse {
  final String markdown;
  final String mindmap;

  MockGenerateDocumentResponse({required this.markdown, required this.mindmap});
}