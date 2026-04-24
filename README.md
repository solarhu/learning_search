# 递进式学习搜索工具

递进式学习搜索 - 帮助用户循序渐进学习新知识，支持自动关键词提取+用户自定义标注，最后生成结构化学习文档可导出。

## 核心功能

- 🎯 **递进式搜索**：用户提问 → 核心答案 → 点击关键词逐步深入理解 → 生成完整结构化文档
- ✨ **用户自定义标注**：支持用户长按添加自定义关键词，可标注个性化需求
- 🔄 **双模式**：搜索探索模式 / 完整文档学习模式
- 💾 **导出**：支持 Markdown / PDF 两种格式下载

## 技术架构

- **前端**：Flutter 跨端，一套代码同时支持 Web + 鸕蒙
- **后端**：Go RESTful API，集成 OpenAI 兼容接口
- **LLM**：调用 OpenAI 兼容接口生成内容

## 运行模式

### Mock 模式（演示）
无后端 API 时自动启用，使用内置模拟数据。
- 输入 `openclaw是什么` 可查看完整示例
- 适合 Vercel 演示、UI 测试

### AI 模式（生产）
配置后端 API 后启用，调用真实 AI 服务。

## API 地址配置（按优先级）

1. **编译时环境变量**
   ```bash
   flutter build web --dart-define=API_BASE_URL=https://your-api.com
   ```

2. **配置文件**（移动端/鸿蒙）
   ```json
   // api_config.json
   {"api_url": "https://your-api.com"}
   ```

3. **UI 设置界面**
   点击右上角设置图标，输入 API 地址

## 部署方式

### Vercel（演示）
1. 连接 GitHub 仓库到 Vercel
2. 自动部署前端（Mock 模式）
3. 访问部署地址测试

### 云服务器（生产）

#### 后端部署
```bash
cd server

# 创建环境配置
cp .env.example .env
# 编辑 .env 设置 OPENAI_API_KEY

# Docker 部署
docker-compose up -d

# 或直接运行
go build -o server main.go
./server
```

#### 环境变量
| 变量 | 说明 | 默认值 |
|------|------|--------|
| OPENAI_API_KEY | OpenAI API 密钥 | 必填 |
| OPENAI_API_BASE | API 地址 | https://api.openai.com/v1 |
| OPENAI_MODEL | 模型名称 | gpt-4o |
| PORT | 服务端口 | 8081 |

#### 前端配置后端地址
```bash
flutter build web --dart-define=API_BASE_URL=https://your-server.com
```

## 开发状态

✅ **MVP 核心功能已全部开发完成**

| 功能 | 状态 |
|------|------|
| 递进式搜索 + 自动关键词 | ✅ 完成 |
| 用户自定义标注 | ✅ 完成 |
| 生成完整文档 + 思维导图 | ✅ 完成 |
| 双模式切换 | ✅ 完成 |
| Markdown / PDF 导出 | ✅ 完成 |
| Mock 模式演示 | ✅ 完成 |
| API 地址配置 | ✅ 完成 |
| Docker 部署 | ✅ 完成 |
| **鸿蒙适配** | ⚠️ 框架已创建，等待编译测试 |
| 文档持久化 | ⚠️ 待开发 |

## 项目结构

```
learning_search/
├── lib/                # Flutter 共享代码
│   ├── api/            # API 客户端 + Mock 服务
│   ├── domain/         # 业务逻辑
│   ├── models/         # 数据模型
│   ├── widgets/        # UI 组件
│   └── main.dart       # 入口
├── server/             # Go 后端
│   ├── Dockerfile      # Docker 配置
│   ├── docker-compose.yml
│   └── main.go         # 入口
├── web/                # Web 配置
├── ohos/               # 鸕蒙项目配置
├── docs/               # 设计文档+开发记录
└── vercel.json         # Vercel 部署配置
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