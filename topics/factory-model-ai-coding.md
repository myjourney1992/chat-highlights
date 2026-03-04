---
date: 2026-03-04
source: ChatGPT
tags: [ai-coding, agentic, tdd, verification]
title: Addy Osmani - Factory Model
---

## 核心观点

> 软件工程的历史就是抽象层不断上移——从写指令到写函数/对象/服务/云，直到今天进入下一阶段：**从"写代码"变成"编排会写代码的系统/代理"**。

## 三代 AI 编程工具

| 代次 | 类型 | 特征 |
|------|------|------|
| 1️⃣ | 智能补全 | Copilot 类，逐行/逐块补全 |
| 2️⃣ | 同步 Agent | 对话式改代码，你在场监督 |
| 3️⃣ | **自治 Agent** | 自己跑完装依赖→写测试→查资料→反复修→给PR |

## Factory Model（工厂模型）

你不是在"写功能"，而是在**搭建一套工厂**：
- 测试框架
- 脚本工具
- 文档规范
- 环境配置

让一批 agent 并行产出，你负责：
- ✅ 审核
- ✅ 反馈
- ✅ 把关质量

## 关键洞察

> **瓶颈不再是生成（generation），而是验证（verification）**

这意味着：
- 测试会变得更重要
- CI/CD 门禁是生命线
- Code Review 仍然必要

## 实践建议

### 在 Agentic Workflow 里，Red/Green TDD "接近必选项"

让 agent 先写**会失败的测试**，再最小实现到全绿。

为什么？否则 agent 很容易写出"看着对、测试也过了但其实测错了东西"的代码。

### 与 Flutter+GetX 工作方式结合

保留现有的门禁三件套：
```bash
flutter analyze  # 静态分析
dart format .    # 代码格式
flutter test     # 测试
```

再把 Red/Green TDD 作为 agent 的默认开工指令。

---

## 链接

- [原文：The Factory Model](https://addyosmani.com/blog/factory-model/)
- [作者推特](https://twitter.com/addyosmani)
