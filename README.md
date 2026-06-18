# Chat Highlights

> 存储聊天中的高光时刻 / 知识卡片

## 目录结构

```
chat-highlights/
├── topics/       # 主题笔记（AI编程、架构、Flutter等）
├── docs/         # 项目文档
│   └── openclaw/ # OpenClaw 飞书机器人文档
├── snippets/     # 代码片段
├── quotes/       # 金句/观点
└── new.sh        # 从剪贴板创建新笔记的脚本
```

## OpenClaw 多平台机器人

本地优先的 AI 助手网关，支持多平台消息集成。

| 文档 | 说明 |
|-----|------|
| [飞书配置教程](./docs/openclaw/setup.md) | 安装配置 OpenClaw + 飞书 |
| [企业微信配置教程](./docs/openclaw/wecom-setup.md) | 安装配置 OpenClaw + 企业微信（WebSocket 长连接）|
| [原理说明](./docs/openclaw/how-it-works.md) | 架构、数据流、关键文件 |
| [高级配置](./docs/openclaw/advanced.md) | 身份、记忆、心跳、技能扩展 |
| [故障排查](./docs/openclaw/troubleshooting.md) | 常见问题及解决方案 |
| [Feishu MCP 切换到 lark-cli](./docs/openclaw/feishu-mcp-to-cli.md) | Codex Feishu MCP 下线，统一改用 `lark-cli` |

### 快速开始

```bash
# 安装
npm install -g openclaw

# 配置 ~/.openclaw/openclaw.json

# 启动
openclaw gateway --port 18789
```

## 知识笔记

### 快速添加笔记（macOS）

```bash
# 1. 复制内容到剪贴板
# 2. 运行脚本，按提示输入标签和标题
./new.sh
```

### 搜索笔记

```bash
# 本地搜索
grep -r "关键词" topics/

# GitHub 搜索（推送后）
# 在 GitHub 搜索框输入：关键词 repo:myjourney1992/chat-highlights
```

## 标签索引

| 标签 | 说明 | 笔记数 |
|------|------|--------|
| `ai-coding` | AI 编程 / Agent | 1 |
| `agentic` | Agentic Workflow | 1 |
| `tdd` | 测试驱动开发 | 1 |
| `architecture` | 架构设计 | - |
| `flutter` | Flutter 相关 | - |
| `troubleshooting` | 排障笔记 | 1 |

## 最近更新

### OpenClaw 文档
- 2026-04-27: [Feishu MCP 切换到 lark-cli](./docs/openclaw/feishu-mcp-to-cli.md)
- 2026-03-05: [配置教程](./docs/openclaw/setup.md)
- 2026-03-05: [原理说明](./docs/openclaw/how-it-works.md)
- 2026-03-05: [故障排查](./docs/openclaw/troubleshooting.md)

### 知识笔记
- 2026-06-18: [Claude 桌面 App 连 VPN 闪动 — Cloudflare WARP 根治方案](./topics/20260618-claude-app-cloudflare-warp.md)
- 2026-03-04: [Addy Osmani - Factory Model](./topics/factory-model-ai-coding.md)
