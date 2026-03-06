---
date: 2026-03-06
tags: [openclaw, gmail, feishu, ai, automation, nodejs]
title: Gmail 自动总结并发送到飞书
---

## 概述

自动读取 Gmail 邮件（最近24小时），使用 AI 总结并分类，通过飞书机器人发送到私聊。适合用来处理订阅邮件、技术资讯等非紧急邮件，避免遗漏重要信息。

### 功能特性

- **自动读取**：每天定时读取 Gmail（最近24小时）
- **智能过滤**：自动过滤验证码、登录提醒等噪音邮件
- **AI 总结**：使用 Claude 分析邮件内容，生成中文摘要
- **智能分类**：自动分类为 科技/工具/产品/安全/资讯/社交/其他
- **原文链接**：每封邮件附带 Gmail 原文链接
- **飞书推送**：每天早上 11 点自动发送到飞书私聊

### 效果预览

```
📬 邮件日报 2026/3/6

🔧 科技 3
1. Code Mode Tooling ⚙️, Agentic BI Eval...
   TLDR Data 日报，涵盖了代码模式工具、智能体BI评估的缺陷以及GitHub搜索架构的技术动态。
   🔗 https://mail.google.com/mail/u/...（点击查看原文）

🛠 工具 2
1. Google Workspace CLI 🛠, indexing lar...
   TLDR Dev 开发周刊，介绍了Google Workspace CLI工具...
   🔗 https://mail.google.com/mail/u/...（点击查看原文）

📊 共 13 封邮件
```

---

## 前置要求

1. **Gmail 账号** + 两步验证已开启
2. **飞书企业自建应用**（用于发送消息）
3. **Node.js 18+** 已安装
4. **Anthropic API Key**（Claude）

---

## 快速开始

### 1. 生成 Gmail 应用专用密码

1. 访问 https://myaccount.google.com/apppasswords
2. 选择「邮件」→「其他（自定义名称）」
3. 输入名称如 `OpenClaw`
4. 复制生成的 16 位密码

### 2. 配置 Gmail 凭证

```bash
# 创建凭证文件
cat > ~/.openclaw/credentials/gmail.json << 'EOF'
{
  "user": "your-email@gmail.com",
  "password": "xxxx xxxx xxxx xxxx"
}
EOF
```

### 3. 安装依赖

```bash
cd ~/.openclaw/agents/gmail-summary
npm install imap @anthropic-ai/sdk mailparser
```

### 4. 配置飞书推送

编辑 `send-to-feishu.js`，设置你的飞书 `chat_id`：

```javascript
const chatId = 'oc_xxxxxxxxxxxxxx'; // 你的飞书会话 ID
```

### 5. 配置定时任务

```bash
# 添加到系统 crontab
(crontab -l 2>/dev/null; echo "0 11 * * * ~/.openclaw/agents/gmail-summary/run.sh >> ~/.openclaw/agents/gmail-summary/cron.log 2>&1") | crontab -
```

---

## 项目结构

```
~/.openclaw/agents/gmail-summary/
├── gmail-summary.js      # 读取 Gmail 并生成 JSON
├── send-to-feishu.js     # 读取 JSON 并发送到飞书
├── run.sh                # 完整流程脚本
├── emails.json           # 邮件数据（中间文件）
├── cron.log              # 定时任务日志
└── package.json          # Node.js 依赖
```

---

## 核心代码

### 1. Gmail 读取与过滤（gmail-summary.js）

```javascript
const Imap = require('imap');
const { simpleParser } = require('mailparser');

// 邮件黑名单 - 过滤验证码等噪音
const BLACKLIST = {
  subjects: [
    /login code/i,
    /verification code/i,
    /验证码/i,
    /sign-in attempt/i,
  ],
  senders: [
    /accounts\.google\.com/,
    /security@/,
  ]
};

// IMAP 配置
const CONFIG = {
  gmail: {
    user: 'your-email@gmail.com',
    password: 'app-password',
    host: 'imap.gmail.com',
    port: 993,
    tls: true,
    tlsOptions: { rejectUnauthorized: false }  // 绕过 SSL 证书问题
  },
  hoursAgo: 24
};
```

### 2. AI 总结与分类

```javascript
const Anthropic = require('@anthropic-ai/sdk');

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

const prompt = `请分析以下邮件列表，为每封邮件提供：
1. 分类（科技/工具/产品/安全/资讯/社交/其他）
2. 一句话中文摘要（说明这封邮件在讲什么，有什么价值）

请以 JSON 格式返回。`;

const response = await anthropic.messages.create({
  model: 'claude-opus-4-5-20251101',
  max_tokens: 4000,
  messages: [{ role: 'user', content: prompt }]
});
```

### 3. 飞书消息推送（send-to-feishu.js）

```javascript
// 获取 tenant_access_token
async function getToken() {
  const data = JSON.stringify({
    app_id: appId,
    app_secret: appSecret
  });

  const req = https.request({
    hostname: 'open.feishu.cn',
    path: '/open-apis/auth/v3/tenant_access_token/internal',
    method: 'POST',
    headers: { 'Content-Type': 'application/json' }
  });
  // ...
}

// 发送文本消息
async function sendText(token, chatId, text) {
  const payload = JSON.stringify({
    receive_id: chatId,
    msg_type: 'text',
    content: JSON.stringify({ text })  // 注意：content 必须是 JSON 字符串
  });

  // POST to /open-apis/im/v1/messages?receive_id_type=chat_id
}
```

---

## 常见问题与解决方案

### Q1: SSL 证书错误 (DEPTH_ZERO_SELF_SIGNED_CERT)

**解决方案**：在 IMAP 配置中添加：
```javascript
tlsOptions: { rejectUnauthorized: false }
```

### Q2: 飞书 API 错误 9499 (Invalid parameter type: content)

**原因**：content 参数必须是 JSON 字符串，不能直接传对象

**解决方案**：
```javascript
// ❌ 错误
content: { text: message }

// ✅ 正确
content: JSON.stringify({ text })
```

### Q3: 邮件主题乱码 (=?utf-8?Q?=...?)

**解决方案**：使用 `mailparser` 库自动处理编码
```bash
npm install mailparser
```

```javascript
const { simpleParser } = require('mailparser');
const parsed = await simpleParser(rawEmail);
// parsed.subject 会自动解码
```

### Q4: 如何获取飞书 chat_id？

**方法**：调用飞书 API 获取会话列表
```bash
curl -X GET "https://open.feishu.cn/open-apis/im/v1/chats?user_id_type=open_id" \
  -H "Authorization: Bearer $TOKEN"
```

---

## 手动运行

```bash
# 完整流程：读取 → 总结 → 发送
~/.openclaw/agents/gmail-summary/run.sh

# 或分步执行
cd ~/.openclaw/agents/gmail-summary
node gmail-summary.js      # 读取邮件并总结
node send-to-feishu.js     # 发送到飞书
```

---

## 技术栈

- **Node.js** - 运行环境
- **imap** - Gmail IMAP 连接
- **mailparser** - 邮件解析（处理 MIME、UTF-8 编码）
- **@anthropic-ai/sdk** - Claude AI 总结
- **飞书开放平台 API** - 消息推送
