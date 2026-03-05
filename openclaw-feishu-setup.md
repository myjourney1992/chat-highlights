# OpenClaw + 飞书集成配置指南

## 概述

OpenClaw 是一个本地优先的 AI 助手网关，支持多平台消息集成。本文档记录如何配置 OpenClaw 与飞书（Lark）的集成。

## 前置要求

- Node.js 18+ 已安装
- 飞书企业账号（需要企业管理员权限）
- Anthropic API Key

## 安装步骤

### 1. 安装 OpenClaw

```bash
npm install -g openclaw
```

### 2. 安装本地隧道工具（用于本地开发）

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
        "baseUrl": "https://api.anthropic.com",
        "apiKey": "your-anthropic-api-key",
        "models": [
          {
            "id": "claude-opus-4-6",
            "name": "Claude Opus 4.6"
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-opus-4-6"
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
| `agents.defaults.systemPrompt` | 系统提示词，可设置机器人人设/语言偏好 |
| `gateway.port` | Gateway 监听端口（默认 18789） |
| `gateway.mode` | 运行模式（local 表示本地模式） |

### 使用 API 代理

如果你使用 API 代理（如第三方 API 服务），需要修改 `baseUrl`：

```json
"models": {
  "providers": {
    "anthropic": {
      "baseUrl": "https://your-proxy.com/api",
      "apiKey": "your-proxy-api-key",
      "models": [...]
    }
  }
}
```

### 查询代理支持的模型列表

使用代理时，可以先用 curl 查询支持的模型：

```bash
curl -H "x-api-key: your-api-key" \
     -H "anthropic-version: 2023-06-01" \
     https://your-proxy.com/api/v1/models
```

返回的 `data.id` 就是可用的模型名称，需要在配置中使用完全一致的名称。

### 设置中文回复

在 `agents.defaults` 中添加 `systemPrompt`：

```json
"agents": {
  "defaults": {
    "model": {
      "primary": "anthropic/claude-opus-4-5-20251101"
    },
    "systemPrompt": "你是一个友好的 AI 助手。请始终用简体中文回复用户。"
  }
}

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

### 1. 启动 Gateway

```bash
openclaw gateway --port 18789
```

成功启动后会看到类似输出：

```
🦞 OpenClaw 2026.2.25
[feishu] feishu[default]: WebSocket client started
[info]: [ '[ws]', 'ws client ready' ]
```

### 2. 启动本地隧道（可选，用于公网访问）

如果需要公网访问（如飞书 Webhook 回调）：

```bash
lt --port 18789
```

会显示类似输出：

```
your url is: https://beige-jokes-train.loca.lt
```

### 3. 查看日志

```bash
# 实时查看日志
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log

# 查看最新 20 条
tail -20 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log
```

## 常用命令

### 检查 Gateway 状态

```bash
lsof -i :18789 | grep LISTEN
```

### 停止 Gateway

```bash
openclaw gateway stop
```

### 强制停止（如果 stop 不生效）

```bash
# 找到进程 PID
lsof -i :18789

# 强制杀死
kill -9 <PID>
```

### 检查通道状态

```bash
openclaw channels status
```

### 检查 Agent 列表

```bash
openclaw agents list
```

### 验证配置

```bash
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

## 故障排查

### 问题 1：Gateway 启动失败

**症状**：`Gateway failed to start: gateway already running`

**解决**：
```bash
# 查找占用端口的进程
lsof -i :18789

# 强制停止
kill -9 <PID>

# 重新启动
openclaw gateway --port 18789
```

### 问题 2：机器人不回复消息

**检查清单**：

1. ✅ Gateway 是否正在运行？
   ```bash
   lsof -i :18789 | grep LISTEN
   ```

2. ✅ 日志是否显示 WebSocket 已连接？
   ```bash
   tail -20 /tmp/openclaw/openclaw-*.log | grep "WebSocket"
   ```

3. ✅ 飞书权限是否已批准？（绿色状态）

4. ✅ 应用是否已发布？

5. ✅ 企业管理员是否已批准？（企业应用）

6. ✅ 事件订阅是否正确配置？
   - 订阅方式：长连接模式
   - 已订阅：`im.message.receive_v1`

### 问题 3：日志显示配置错误

**症状**：`Config invalid` 或 `Unrecognized key`

**解决**：
```bash
openclaw doctor --fix
```

### 问题 4：duplicate plugin id 警告

**症状**：日志显示 `plugin feishu: duplicate plugin id detected`

**说明**：这是正常警告，不影响使用。OpenClaw 会自动处理。

### 问题 5：HTTP 401 authentication_error: invalid x-api-key

**症状**：日志显示 `HTTP 401 authentication_error: invalid x-api-key`

**原因分析**：
1. 如果你使用 API 代理，配置中的 `baseUrl` 可能仍是官方地址 `https://api.anthropic.com`
2. 代理服务需要的认证方式可能与官方不同

**解决方法**：
1. 确认 `baseUrl` 是否指向代理地址
2. 检查 `apiKey` 是否正确（代理服务提供的密钥）
3. 重启 Gateway：
   ```bash
   lsof -i :18789 -t | xargs kill -9
   openclaw gateway --port 18789
   ```

### 问题 6：500 No available Claude accounts support the requested model

**症状**：日志显示 `500 No available Claude accounts support the requested model: xxx`

**原因分析**：
- 代理服务支持的模型列表与官方不同
- 配置中的模型 ID 在代理服务中不存在

**解决方法**：
1. 先查询代理支持的模型列表：
   ```bash
   curl -H "x-api-key: your-api-key" \
        -H "anthropic-version: 2023-06-01" \
        https://your-proxy.com/api/v1/models | jq '.data[].id'
   ```

2. 修改配置使用代理支持的模型：
   ```json
   "models": [
     {
       "id": "claude-opus-4-5-20251101",  // 使用代理支持的模型 ID
       "name": "Claude Opus 4.5"
     }
   ],
   "agents": {
     "defaults": {
       "model": {
         "primary": "anthropic/claude-opus-4-5-20251101"
       }
     }
   }
   ```

3. 重启 Gateway

### 问题 7：机器人回复语言不正确（如回复英文但想要中文）

**症状**：机器人用英文回复，但希望用中文回复

**解决方法**：在配置中添加 `systemPrompt`：

```json
"agents": {
  "defaults": {
    "model": {
      "primary": "anthropic/claude-opus-4-5-20251101"
    },
    "systemPrompt": "你是一个友好的 AI 助手。请始终用简体中文回复用户。"
  }
}
```

重启 Gateway 后生效。

## 日志关键词

收到消息时，日志会出现类似：

```json
{"0":"[feishu] feishu[default]: received message..."}
```

如果长时间只有配置警告（每分钟一次），说明飞书没有推送消息，需要检查飞书配置。

## 配置文件备份

建议备份配置文件：

```bash
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak
```

## 参考资源

- OpenClaw 文档：https://docs.openclaw.ai/
- 飞书开放平台：https://open.feishu.cn/
- Anthropic API：https://docs.anthropic.com/

## 更新日志

- 2026-03-04：初始版本，记录 OpenClaw + 飞书集成配置
