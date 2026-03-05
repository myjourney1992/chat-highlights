# OpenClaw + 飞书集成配置指南

> 本地优先的 AI 助手网关，支持多平台消息集成

## 概述

OpenClaw 是一个本地优先的 AI 助手网关，支持多平台消息集成。本文档记录如何配置 OpenClaw 与飞书（Lark）的集成。

## 前置要求

- Node.js 18+ 已安装
- 飞书企业账号（需要企业管理员权限）
- Anthropic API Key（或代理服务密钥）

## 安装步骤

### 1. 安装 OpenClaw

```bash
npm install -g openclaw
```

### 2. 安装本地隧道工具（可选，用于本地开发）

```bash
npm install -g localtunnel
```

## 配置文件

OpenClaw 配置文件位置：`~/.openclaw/openclaw.json`

### 完整配置示例

```json
{
  "meta": {
    "lastTouchedVersion": "2026.2.25",
    "lastTouchedAt": "2026-03-04T11:40:24.791Z"
  },
  "models": {
    "providers": {
      "anthropic": {
        "baseUrl": "https://your-proxy.com/api",
        "apiKey": "your-api-key",
        "models": [
          {
            "id": "claude-opus-4-5-20251101",
            "name": "Claude Opus 4.5"
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-opus-4-5-20251101"
      },
      "compaction": {
        "mode": "safeguard"
      }
    }
  },
  "commands": {
    "native": "auto",
    "nativeSkills": "auto",
    "restart": true,
    "ownerDisplay": "raw"
  },
  "channels": {
    "feishu": {
      "appId": "cli_xxxxxxxxxxxxx",
      "appSecret": "your-app-secret"
    }
  },
  "gateway": {
    "port": 18789,
    "mode": "local"
  },
  "plugins": {
    "entries": {
      "feishu": {
        "enabled": true
      }
    }
  }
}
```

### 配置说明

| 配置项 | 说明 |
|--------|------|
| `models.providers.anthropic.baseUrl` | API 地址，使用代理时填代理地址 |
| `models.providers.anthropic.apiKey` | Anthropic API 密钥或代理密钥 |
| `channels.feishu.appId` | 飞书应用的 App ID |
| `channels.feishu.appSecret` | 飞书应用的 App Secret |
| `gateway.port` | Gateway 监听端口（默认 18789） |
| `gateway.mode` | 运行模式（local 表示本地模式） |

## 飞书开放平台配置

### 1. 创建应用

1. 访问 [飞书开放平台](https://open.feishu.cn/)
2. 进入**开发者后台**
3. 创建**企业自建应用**

### 2. 获取凭证

- **App ID**：应用概览页面获取
- **App Secret**：应用概览页面获取

### 3. 配置权限（权限管理）

在**权限管理**页面，开通并批准以下权限：

| 权限名称 | 说明 |
|----------|------|
| `im:message` | 发送消息 |
| `im:message:group_at_msg` | 接收群组@消息 |
| `im:chat` | 访问聊天信息 |
| `im:conversation` | 访问会话 |

⚠️ **重要**：权限必须显示为绿色"已批准"状态

### 4. 配置事件订阅

在**事件与回调**页面：

- **订阅方式**：选择**长连接模式**
- **已订阅事件**：
  - ✅ `im.message.receive_v1`（接收消息）

### 5. 发布应用

1. 进入**版本管理与发布**
2. 点击**创建版本**
3. 填写版本号（如 1.0.0）
4. 点击**发布**

### 6. 企业管理员批准（企业应用）

如果是企业应用，需要企业管理员操作：

- **飞书管理后台** → **应用管理** → **企业自建应用**
- 找到你的应用 → **批准启用**

## 启动 OpenClaw

### 启动 Gateway

```bash
openclaw gateway --port 18789
```

成功启动后会看到类似输出：

```
🦞 OpenClaw 2026.2.25
[feishu] feishu[default]: WebSocket client started
[info]: [ '[ws]', 'ws client ready' ]
```

### 查看日志

```bash
# 实时查看日志
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log

# 查看最新 20 条
tail -20 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log
```

## 常用命令

```bash
# 检查 Gateway 状态
lsof -i :18789 | grep LISTEN

# 停止 Gateway
openclaw gateway stop

# 强制停止（如果 stop 不生效）
lsof -i :18789 -t | xargs kill -9

# 检查通道状态
openclaw channels status

# 检查配置
openclaw doctor
```

## 使用方法

### 1. 添加机器人到群聊

- 在飞书群聊中
- 点击**添加成员** → **添加应用**
- 搜索你的应用名称 → 添加

### 2. 与机器人对话

在群聊中：
- 直接艾特机器人：`@机器人 你的问题`
- 或发送消息给机器人

### 3. 私聊机器人

- 在飞书搜索你的应用名称
- 打开聊天窗口直接发送消息

## 配置文件备份

建议备份配置文件：

```bash
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak
```

## 参考资源

- [原理说明](./how-it-works.md)
- [故障排查](./troubleshooting.md)
- OpenClaw 文档：https://docs.openclaw.ai/
- 飞书开放平台：https://open.feishu.cn/
- Anthropic API：https://docs.anthropic.com/
