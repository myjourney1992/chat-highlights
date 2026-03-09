# OpenClaw + 企业微信集成配置指南

> 本地优先的 AI 助手网关，支持企业微信智能机器人 WebSocket 长连接

## 概述

OpenClaw 是一个本地优先的 AI 助手网关，支持多平台消息集成。本文档记录如何配置 OpenClaw 与企业微信的集成。

**核心优势**：企业微信支持 **WebSocket 长连接模式**，无需公网 IP，本地即可运行。

## 前置要求

- Node.js 18+ 已安装
- 企业微信账号（个人或企业均可）
- Anthropic API Key（或代理服务密钥）

## 安装步骤

### 1. 安装 OpenClaw

```bash
npm install -g openclaw
```

### 2. 安装企业微信插件

```bash
openclaw plugins install @openclaw-china/wecom
```

## 配置文件

OpenClaw 配置文件位置：`~/.openclaw/openclaw.json`

### 企业微信配置示例

```json
{
  "channels": {
    "wecom": {
      "enabled": true,
      "botId": "aib-xxxxxxxxxxxxxxxxxxx",
      "secret": "xxxxxxxxxxxxxxxxxxxx"
    }
  },
  "plugins": {
    "entries": {
      "wecom": {
        "enabled": true
      }
    }
  }
}
```

### 配置说明

| 配置项 | 说明 |
|--------|------|
| `channels.wecom.enabled` | 是否启用企业微信通道 |
| `channels.wecom.botId` | 企业微信智能机器人的 Bot ID |
| `channels.wecom.secret` | 企业微信智能机器人的 Secret |
| `gateway.port` | Gateway 监听端口（默认 18789） |
| `gateway.mode` | 运行模式（local 表示本地模式） |

## 企业微信后台配置

### 1. 创建智能机器人

1. 登录 [企业微信管理后台](https://work.weixin.qq.com/)
2. 进入**「安全与管理」** → **「管理工具」** → **「智能机器人」**
3. 点击**「新建机器人」**
4. 选择**「API 模式」**
5. 填写机器人名称（如 `AI助手`）和简介
6. 点击**「创建」**

### 2. 获取凭证

在机器人详情页获取：
- **BotID**：类似 `aib-xxxxxxxxxxxxxxxxxxx` 格式
- **Secret**：机器人密钥

### 3. 添加到应用

1. 在企业微信 APP 中
2. 进入**「工作台」**
3. 找到你创建的智能机器人
4. 点击添加到常用应用

### 4. 测试连接

在企业微信中给智能机器人发送消息，确认能收到回复。

## 使用命令行配置

```bash
# 启用企业微信通道
openclaw config set channels.wecom.enabled true

# 设置 Bot ID
openclaw config set channels.wecom.botId "aib-xxxxxxxxxxxxxxxxxxx"

# 设置 Secret
openclaw config set channels.wecom.secret "xxxxxxxxxxxxxxxxxxxx"

# 查看配置
openclaw config get channels.wecom
```

## 启动 OpenClaw

### 启动 Gateway

```bash
openclaw gateway --port 18789
```

成功启动后会看到类似输出：

```
🦞 OpenClaw 2026.2.25
[wecom] Establishing WebSocket connection...
[wecom] Connecting to WebSocket: wss://openws.work.weixin.qq.com...
[wecom] WebSocket connection established, sending auth...
[wecom] Authentication successful
[wecom] [wecom] ws authenticated for account default
[wecom] [DEBUG] Heartbeat timer started, interval: 30000ms
```

### 查看日志

```bash
# 实时查看日志
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log

# 查看企业微信相关日志
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | grep wecom
```

## 常用命令

```bash
# 检查 Gateway 状态
lsof -i :18789 | grep LISTEN

# 停止 Gateway
openclaw gateway stop

# 重启 Gateway
openclaw gateway restart

# 检查通道状态
openclaw channels status

# 检查配置
openclaw doctor

# 详细通道状态（带探测）
openclaw channels status --probe
```

## 使用方法

### 1. 私聊机器人

- 在企业微信中搜索你的机器人名称
- 打开聊天窗口直接发送消息

### 2. 群聊中使用

- 在企业微信群聊中
- 点击**添加成员** → **添加应用**
- 搜索你的机器人名称 → 添加
- 在群聊中 @机器人即可对话

## 验证连接状态

### 正常运行的标志

查看日志应看到：
```
[wecom] [DEBUG] Heartbeat sent
[wecom] [DEBUG] Received heartbeat ack
```

### 通道状态

```bash
openclaw channels status
```

正常输出：
```
- WeCom default: enabled, configured
```

## 关联个人微信（可选）

企业微信支持通过「微信插件」关联个人微信：

### 步骤

1. 企业微信管理后台 → **「我的企业」** → **「微信插件」**
2. 启用微信插件功能
3. 获取邀请二维码
4. 用个人微信扫码关联

### 限制

- 只能接收文本消息
- 部分功能可能受限
- 建议直接使用企业微信 APP 获得完整体验

## 故障排查

### 连接失败

1. 检查 Bot ID 和 Secret 是否正确
2. 确认智能机器人在企业微信后台已启用
3. 查看日志：`tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | grep wecom`

### 机器人无响应

1. 检查 Gateway 是否运行：`openclaw channels status`
2. 检查模型配置：`openclaw config get agents.defaults.model`
3. 查看完整日志排查问题

### 心跳超时

如果看到心跳超时错误：
- 检查网络连接
- 重启 Gateway：`openclaw gateway restart`

## 参考资源

- [OpenClaw 文档](https://docs.openclaw.ai/)
- [企业微信开放平台](https://work.weixin.qq.com/)
- [企业微信智能机器人文档](https://developer.work.weixin.qq.com/document/path/101039)
- [OpenClaw 中国插件仓库](https://github.com/BytePioneer-AI/openclaw-china)
