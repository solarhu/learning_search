# 技能说明

## 项目简介

**递进式学习搜索工具** - 帮助用户逐步深入学习新知识，支持自动关键词提取+用户自定义标注，最后生成结构化学习文档并可导出。

## 核心技能点

### 1. 产品技能
- 递进式学习交互设计：先给核心答案，用户逐步深入，避免信息过载
- 支持用户自定义标注，满足个性化学习需求
- 双模式设计：搜索探索模式 / 完整文档学习模式
- 导出功能：支持 Markdown / PDF 两种格式保存学习成果

### 2. 技术技能
- **Flutter 跨端开发**：一套代码同时支持 Web + 鸿蒙
- **Go 后端开发**：RESTful API，集成 OpenAI 兼容接口
- **条件导入处理**：Flutter Web 下载功能使用条件导入兼容多平台
- **Prompt Engineering**：针对 LLM 设计了结构化输出提示词，保证 JSON 格式正确

## 开发技能

### Git 分支管理
- `master`: 稳定主线
- `dev`: 当前开发分支
- 功能开发：从 `dev` 拉特性分支，开发完成 PR 合并

### 项目结构
```
lib/
├── domain/        # 业务逻辑
├── models/        # 数据模型
├── api/           # API 客户端
├── widgets/       # UI 组件
├── utils/         # 工具类（条件导入处理下载）
└── main.dart      # 入口

server/
├── main.go
├── handlers/      # HTTP 处理器
├── services/      # 业务逻辑
└── models/        # 数据模型

docs/
├── design.md      # 设计文档
├── DEVELOPMENT.md # 开发记录
└── SKILL.md       # 技能说明（本文档）
```

## 已掌握技能清单

- [x] Flutter 跨端项目脚手架搭建
- [x] Flutter 条件导入处理平台差异
- [x] Go RESTful API 开发
- [x] LLM Prompt 工程
- [x] Git 分支管理规范
- [x] 交互式搜索体验设计
- [x] 用户自定义标注功能实现
- [x] Markdown / PDF 导出功能

## 待学习/待开发

- [ ] Flutter 鸿蒙适配开发
- [ ] 持久化存储方案设计
- [ ] 生产环境部署

