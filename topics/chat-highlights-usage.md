---
date: 2026-03-04
source: Claude
tags: [pkm, productivity, shell, alias]
title: Chat Highlights 使用手册
---

## 两个快捷命令

| 命令 | 作用 |
|------|------|
| `ch-new` | 从剪贴板创建新笔记 |
| `ch-cd` | 进入笔记目录 |

## 使用流程

```bash
# 1. 复制聊天内容到剪贴板
# 2. 运行
ch-new
# 3. 输入标题、标签，选择目录
```

## 仓库链接

https://github.com/myjourney1992/chat-highlights

---

## 工作流程

**下次添加笔记只需两步：**

1. 复制内容 → 运行 `ch-new` → 填几个选项
2. `ch-cd` 然后 `git push`

## Alias 配置

```bash
# 在 ~/.zshrc 中
alias ch-new='/Users/zhoulili/huoban/zll/chat-highlights/new.sh'
alias ch-cd='cd /Users/zhoulili/huoban/zll/chat-highlights'
```
