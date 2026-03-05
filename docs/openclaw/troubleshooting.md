# OpenClaw + 飞书故障排查指南

> 常见问题及解决方案

## 快速检查清单

机器人不回复？按顺序检查：

1. ✅ Gateway 是否正在运行？
2. ✅ 日志是否显示 WebSocket 已连接？
3. ✅ 飞书权限是否已批准？
4. ✅ 应用是否已发布？
5. ✅ 企业管理员是否已批准？（企业应用）
6. ✅ 事件订阅是否正确配置？

---

## 问题 1：Gateway 启动失败

**症状**：`Gateway failed to start: gateway already running`

**原因**：端口被占用或旧进程未退出

**解决**：
```bash
# 查找占用端口的进程
lsof -i :18789

# 强制停止
lsof -i :18789 -t | xargs kill -9

# 重新启动
openclaw gateway --port 18789
```

---

## 问题 2：HTTP 401 authentication_error: invalid x-api-key

**症状**：日志显示 `HTTP 401 authentication_error: invalid x-api-key`

**原因分析**：
1. 如果使用 API 代理，配置中的 `baseUrl` 可能仍是官方地址
2. API Key 无效或已过期

**解决方法**：

1. 检查 `openclaw.json` 中的 `baseUrl`：
   ```json
   "baseUrl": "https://your-proxy.com/api"  // 应该是代理地址
   ```

2. 验证 API Key 是否正确：
   ```bash
   curl -H "x-api-key: your-api-key" \
        https://your-proxy.com/api/v1/models
   ```

3. 重启 Gateway：
   ```bash
   lsof -i :18789 -t | xargs kill -9
   openclaw gateway --port 18789
   ```

---

## 问题 3：500 No available Claude accounts support the requested model

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

2. 修改 `openclaw.json` 使用代理支持的模型：
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

---

## 问题 4：机器人回复语言不正确

**症状**：机器人用英文回复，但希望用中文回复

**解决方法**：编辑 `~/.openclaw/workspace/SOUL.md` 添加语言偏好：

```bash
vim ~/.openclaw/workspace/SOUL.md
```

在 `Core Truths` 部分添加：

```markdown
## Core Truths

**Always reply in Simplified Chinese (简体中文).** 无论用户用什么语言提问，都用简体中文回答。
```

重启 Gateway：
```bash
lsof -i :18789 -t | xargs kill -9
openclaw gateway --port 18789
```

**注意**：不要在 `openclaw.json` 中添加 `systemPrompt`，这是无效的配置键。

---

## 问题 5：配置错误

**症状**：`Config invalid` 或 `Unrecognized key`

**解决**：
```bash
openclaw doctor --fix
```

---

## 问题 6：duplicate plugin id 警告

**症状**：日志显示 `plugin feishu: duplicate plugin id detected`

**说明**：这是正常警告，不影响使用。OpenClaw 会自动处理。

---

## 问题 7：机器人不回复消息

**检查清单**：

1. **Gateway 是否正在运行？**
   ```bash
   lsof -i :18789 | grep LISTEN
   ```

2. **日志是否显示 WebSocket 已连接？**
   ```bash
   tail -20 /tmp/openclaw/openclaw-*.log | grep "WebSocket"
   ```

3. **飞书权限是否已批准？**（绿色状态）

4. **应用是否已发布？**

5. **企业管理员是否已批准？**（企业应用）

6. **事件订阅是否正确配置？**
   - 订阅方式：长连接模式
   - 已订阅：`im.message.receive_v1`

---

## 日志关键词

### 正常运行的日志

收到消息时：
```json
{"0":"[feishu] feishu[default]: received message..."}
```

WebSocket 连接成功：
```json
{"0":"[feishu] feishu[default]: WebSocket client started"}
{"0":"[ws] ws client ready"}
```

### 异常日志

认证错误：
```json
{"error":"HTTP 401 authentication_error: invalid x-api-key"}
```

模型不支持：
```json
{"error":"500 No available Claude accounts support the requested model"}
```

如果长时间只有配置警告（每分钟一次），说明飞书没有推送消息，需要检查飞书配置。

---

## 获取更多帮助

- 查看实时日志：`tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log`
- 检查配置：`openclaw doctor`
- 查看通道状态：`openclaw channels status`
