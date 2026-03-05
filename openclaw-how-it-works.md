# OpenClaw + 飞书机器人原理说明

## 整体架构原理

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   飞书用户      │ ──> │   飞书服务器    │ ──> │  OpenClaw本地   │
│  (你/群成员)    │     │  (消息推送)     │     │   (Gateway)     │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                          │
                                                          │ WebSocket 长连接
                                                          │ (已订阅 im.message.receive_v1)
                                                          │
                     ┌─────────────────┐                 │
                     │  代理 API 服务  │ <─────────────┘
                     │ (likecode...)   │     HTTP 请求
                     └────────┬────────┘
                              │
                              │ 转发请求
                              │
                     ┌────────▼────────┐
                     │ Anthropic API   │
                     │ (Claude 官方)   │
                     └─────────────────┘
```

## 数据流解析

| 步骤 | 说明 |
|-----|------|
| 1️⃣ 用户发消息 | 你在飞书 @机器人 或私聊发送消息 |
| 2️⃣ 飞书推送 | 飞书通过 **WebSocket 长连接** 推送消息到 OpenClaw |
| 3️⃣ OpenClaw 处理 | 读取 `SOUL.md` 等配置，构建请求 |
| 4️⃣ 代理转发 | 请求发送到代理 API |
| 5️⃣ 调用 Claude | 代理转发请求到 Anthropic 官方 API |
| 6️⃣ 返回响应 | Claude 回复 → 代理 → OpenClaw → 飞书 → 你 |

## 关键配置文件

```
~/.openclaw/
├── openclaw.json           # 主配置：API 地址、模型、飞书凭证
├── workspace/
│   ├── SOUL.md             # 机器人"灵魂"：行为准则、语言偏好
│   ├── IDENTITY.md         # 身份设定
│   ├── AGENTS.md           # 工作区规则
│   ├── TOOLS.md            # 工具说明
│   └── memory/             # 记忆目录（可选）
└── agents/main/agent/
    ├── models.json         # 模型配置
    └── auth-profiles.json  # 认证配置
```

## 各文件作用

### openclaw.json

全局配置文件，定义：

```json
{
  "models": {
    "providers": {
      "anthropic": {
        "baseUrl": "https://your-proxy.com/api",  // API 地址（代理或官方）
        "apiKey": "your-api-key",                  // API 密钥
        "models": [...]                            // 支持的模型列表
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-opus-4-5-20251101"  // 默认模型
      }
    }
  },
  "channels": {
    "feishu": {
      "appId": "cli_xxx",      // 飞书 App ID
      "appSecret": "xxx"       // 飞书 App Secret
    }
  },
  "gateway": {
    "port": 18789,             // Gateway 监听端口
    "mode": "local"            // 运行模式
  }
}
```

### workspace/SOUL.md

机器人的"灵魂"，定义行为准则。每次对话都会读取此文件。

示例内容：

```markdown
## Core Truths

**Always reply in Simplified Chinese (简体中文).** 无论用户用什么语言提问，都用简体中文回答。

**Be genuinely helpful, not performatively helpful.** 跳过客套话，直接提供帮助。
```

### workspace/IDENTITY.md

定义机器人身份：

```markdown
- **Name:** 助手小飞
- **Creature:** AI 助手
- **Vibe:** 友好、专业、简洁
- **Emoji:** 🤖
```

## 为什么不需要公网地址？

OpenClaw 使用**长连接模式**：

1. OpenClaw 启动时，主动连接飞书服务器
2. 连接建立后保持活跃（WebSocket）
3. 飞书有消息时，直接通过这个连接推送
4. 不需要飞书"回调"你的本地服务

这与传统的 Webhook 模式相反：

| 模式 | 方向 | 需要公网地址 |
|-----|------|-------------|
| Webhook | 飞书 → 你 | ✅ 需要 |
| 长连接 | 你 → 飞书 | ❌ 不需要 |

## API 代理的作用

```
直接访问 Anthropic API:
  你的机器 → api.anthropic.com (可能被墙/需要外网)

通过代理访问:
  你的机器 → 代理服务器 → api.anthropic.com
```

**代理的好处**：
- 无需外网访问
- 可能更低的延迟
- 统一管理多个 API Key

**配置代理**：
只需修改 `openclaw.json` 中的 `baseUrl`：
```json
"baseUrl": "https://your-proxy.com/api"
```

## 消息处理流程

```
用户消息: "@机器人 今天天气怎么样？"
    ↓
飞书推送: WebSocket → OpenClaw
    ↓
OpenClaw 解析:
  - 读取 SOUL.md (中文回复)
  - 读取 workspace 配置
  - 构建 Anthropic API 请求
    ↓
发送到代理: POST https://proxy.com/api/v1/messages
    ↓
代理转发: → Anthropic API
    ↓
Claude 处理: 生成回复
    ↓
返回路径: Claude → 代理 → OpenClaw → 飞书 → 用户
    ↓
最终回复: "抱歉，我无法查询实时天气..."
```

## 常用命令速查

```bash
# 启动 Gateway
openclaw gateway --port 18789

# 查看状态
openclaw channels status

# 查看日志
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log

# 停止 Gateway
openclaw gateway stop

# 强制停止
lsof -i :18789 -t | xargs kill -9

# 检查配置
openclaw doctor
```

## 故障排查清单

机器人不回复？按顺序检查：

1. **Gateway 是否运行？**
   ```bash
   lsof -i :18789 | grep LISTEN
   ```

2. **WebSocket 是否连接？**
   ```bash
   tail -20 /tmp/openclaw/openclaw-*.log | grep "WebSocket"
   ```

3. **飞书权限是否批准？**
   - 登录飞书开放平台
   - 检查权限是否显示绿色"已批准"

4. **事件订阅是否正确？**
   - 订阅方式：长连接模式
   - 已订阅：`im.message.receive_v1`

5. **API 认证是否通过？**
   ```bash
   # 测试代理 API
   curl -H "x-api-key: your-key" \
        https://your-proxy.com/api/v1/models
   ```

## 总结

| 要点 | 说明 |
|-----|------|
| 架构 | 本地 Gateway + 飞书长连接 + API 代理 |
| 核心文件 | `openclaw.json` (配置) + `SOUL.md` (行为) |
| 网络要求 | 本地无需公网地址（长连接模式） |
| 认证方式 | API Key（支持代理） |
| 可定制性 | 通过 workspace 文件定义机器人个性 |
