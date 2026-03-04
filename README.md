# Chat Highlights

> 存储聊天中的高光时刻 / 知识卡片

## 目录结构

```
chat-highlights/
├── topics/       # 主题笔记（AI编程、架构、Flutter等）
├── snippets/     # 代码片段
├── quotes/       # 金句/观点
└── new.sh        # 从剪贴板创建新笔记的脚本
```

## 快速开始

### 添加新笔记（macOS）

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
# 在 GitHub 搜索框输入：关键词 repo:your-username/chat-highlights
```

## 标签索引

| 标签 | 说明 | 笔记数 |
|------|------|--------|
| `ai-coding` | AI 编程 / Agent | 1 |
| `agentic` | Agentic Workflow | 1 |
| `tdd` | 测试驱动开发 | 1 |
| `architecture` | 架构设计 | - |
| `flutter` | Flutter 相关 | - |

## 最近更新

- 2026-03-04: [Addy Osmani - Factory Model](topics/factory-model-ai-coding.md)
