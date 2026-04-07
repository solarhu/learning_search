# 递进式学习搜索工具

递进式学习搜索 - 帮助用户循序渐进学习新知识，支持自动关键词提取+用户自定义标注，最后生成结构化学习文档可导出。

## 核心功能

- 🎯 **递进式搜索**：用户提问 → 核心答案 → 点击关键词逐步深入理解 → 生成完整结构化文档
- ✨ **用户自定义标注**：支持用户长按添加自定义关键词，可标注个性化需求
- 🔄 **双模式**：搜索探索模式 / 完整文档学习模式
- 💾 **导出**：支持 Markdown / PDF 两种格式下载

## 技术架构

- **前端**：Flutter 跨端，一套代码同时支持 Web + 鸿蒙
- **后端**：Go RESTful API，集成 OpenAI 兼容接口
- **LLM**：调用 OpenAI 兼容接口生成内容

## 开发状态

✅ **MVP 核心功能已全部开发完成**，当前开发分支 `dev`

| 功能 | 状态 |
|------|------|
| 递进式搜索 + 自动关键词 | ✅ 完成 |
| 用户自定义标注 | ✅ 完成 |
| 生成完整文档 + 思维导图 | ✅ 完成 |
| 双模式切换 | ✅ 完成 |
| Markdown / PDF 导出 | ✅ 完成 |
| **鸿蒙适配** | ⚠️ 框架已创建，等待编译测试 |
| 文档持久化 | ⚠️ 待开发 |

## 项目结构

```
learning_search/
├── lib/                # Flutter 共享代码
├── server/             # Go 后端
├── web/                # Web 配置
├── ohos/               # 鸿蒙项目配置（Flutter 全跨端）
└── docs/               # 设计文档+开发记录
```

## 构建运行

### 前端 Flutter
```bash
flutter pub get
flutter build web --release
# 构建鸿蒙
# flutter build ohos --release
```

### 后端 Go
```bash
cd server
go build -o server main.go
export OPENAI_API_KEY=your-key
./server
```

## 更多文档

- [设计文档](./docs/design.md)
- [开发记录](./docs/DEVELOPMENT.md)
- [技能说明](./docs/SKILL.md)
