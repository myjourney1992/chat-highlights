# Feishu MCP 切换到 lark-cli 操作文档

> 记录如何把 Codex 中的 Feishu MCP 改为通过 `lark-cli` 调用飞书能力。

## 目标

- 不再让 Codex 通过 `@larksuiteoapi/lark-mcp` 加载 `feishu` MCP。
- 本机统一使用官方 `lark-cli` 访问飞书开放能力。
- 兼容已有仓库脚本中对 `lark-cli` 的依赖，例如 MR 通知、联系人搜索、群消息发送。

## 当前结论

本次切换后的状态：

| 项目 | 状态 |
|------|------|
| Codex `feishu` MCP | 已从全局 MCP 配置移除 |
| `lark-cli` | 已安装，版本 `1.0.19` |
| CLI 配置 | 已绑定 OpenClaw 的飞书应用配置 |
| User token | 已登录，`lark-cli doctor` 通过 |
| 文档搜索 | `lark-cli docs +search` 可用 |
| 联系人搜索 | `lark-cli contact +search-user` 可用 |
| IM dry-run | `lark-cli im +messages-send --dry-run` 可用 |

注意：当前正在运行的 Codex 会话可能仍然保留启动时加载的 MCP 工具列表。移除 MCP 后，需要新开 Codex 会话，工具列表才会真正刷新。

## 前置条件

- Node.js 已安装，且 `npm` 可用。
- OpenClaw 已经配置过飞书应用，通常位于 `~/.openclaw/feishu` 或 OpenClaw 的配置目录中。
- 需要能访问 `open.feishu.cn` 和 `accounts.feishu.cn`。
- 如需推送到 GitHub，还需要 GitHub CLI 或 Git 凭据有效。

## 1. 检查现有 Feishu MCP

```bash
codex mcp list
codex mcp get feishu
```

如果存在类似输出，说明 Codex 仍配置了 Feishu MCP：

```text
feishu
  enabled: true
  transport: stdio
  command: /path/to/npx
  args: -y @larksuiteoapi/lark-mcp mcp ...
```

## 2. 安装 lark-cli

官方 CLI 包是 `@larksuite/cli`，安装后可执行文件名是 `lark-cli`。

```bash
npm install -g @larksuite/cli
lark-cli --version
```

期望输出示例：

```text
lark-cli version 1.0.19
```

不要安装 `@larksuiteoapi/lark-cli`，该包名不可用。

## 3. 移除 Codex Feishu MCP

```bash
codex mcp remove feishu
codex mcp list
```

验证点：

- `codex mcp list` 中不再出现 `feishu`。
- 如果当前 Codex 会话里仍能看到 `mcp__feishu__` 工具，这是会话启动时的旧工具注册表，重开 Codex 会话即可刷新。

## 4. 绑定 OpenClaw 飞书配置

推荐从 OpenClaw 绑定已有飞书应用配置，避免把 App Secret 放进命令参数或 shell 历史。

```bash
lark-cli config bind --source openclaw --identity user-default
```

成功后会生成类似配置：

```text
~/.lark-cli/openclaw/config.json
```

如果普通 `lark-cli` 命令仍提示 `not configured`，说明 CLI 默认读取的是 local workspace。可以把 OpenClaw workspace 的配置同步为默认配置：

```bash
cp ~/.lark-cli/openclaw/config.json ~/.lark-cli/config.json
```

然后检查：

```bash
lark-cli config show
lark-cli auth status
```

安全注意：

- 不要在文档、日志或命令历史里记录 App Secret。
- 如果必须手动初始化，使用 `--app-secret-stdin`，不要把 secret 写在命令参数里。

```bash
lark-cli config init --app-id <APP_ID> --app-secret-stdin --brand feishu
```

## 5. 完成用户授权

交互式终端可以直接执行：

```bash
lark-cli auth login --recommend
```

Agent 环境中更适合使用 device flow：

```bash
lark-cli auth login --recommend --no-wait --json
```

该命令会输出：

- `verification_url`
- `device_code`

处理方式：

1. 把 `verification_url` 发给用户，让用户在自己的浏览器中完成授权。
2. Agent 或当前终端继续执行：

```bash
lark-cli auth login --device-code <DEVICE_CODE>
```

授权成功后检查：

```bash
lark-cli auth status
lark-cli doctor
```

期望 `lark-cli doctor` 中关键项为：

```text
config_file: pass
app_resolved: pass
token_exists: pass
token_local: pass
token_verified: pass
endpoint_open: pass
```

## 6. 补充常用 scope

`--recommend` 不一定会拿到所有日常需要的 scope。根据本次验证，下面两个能力需要单独补授权：

| 能力 | 缺失 scope | 验证命令 |
|------|------------|----------|
| 文档搜索 | `search:docs:read` | `lark-cli docs +search --query "用户媒体"` |
| 联系人搜索 | `contact:user:search` | `lark-cli contact +search-user --query "周丽丽"` |

补授权命令：

```bash
lark-cli auth login --scope "search:docs:read contact:user:search"
```

如果仍采用 device flow：

```bash
lark-cli auth login --scope "search:docs:read contact:user:search" --no-wait --json
lark-cli auth login --device-code <DEVICE_CODE>
```

## 7. 最小验证清单

### MCP 已移除

```bash
codex mcp list
codex mcp get feishu
```

期望：

- `codex mcp list` 不包含 `feishu`。
- `codex mcp get feishu` 返回 `No MCP server named 'feishu' found`。

### CLI 健康检查

```bash
lark-cli doctor
```

期望：

```json
{
  "ok": true,
  "workspace": "local"
}
```

### 文档搜索

```bash
lark-cli docs +search --query "用户媒体" --format json --page-size 3
```

期望：

- 返回 `ok: true`。
- `data.results` 中有飞书文档结果。

### 联系人搜索

```bash
lark-cli contact +search-user --query "周丽丽" --format json
```

期望：

- 返回 `ok: true`。
- 能拿到目标用户的 `open_id`。

### IM 发送 dry-run

```bash
lark-cli im +messages-send \
  --chat-id oc_xxxxxxxxxxxxxx \
  --text "lark-cli dry-run validation" \
  --dry-run \
  --as bot
```

期望：

- 只打印 API 请求，不真实发送消息。
- 能看到 `/open-apis/im/v1/messages` 和 `receive_id_type=chat_id`。

## 常见问题

### 1. `lark-cli doctor` 提示 `config.json` 不存在

说明 CLI 默认 workspace 未配置。

处理：

```bash
lark-cli config bind --source openclaw --identity user-default
cp ~/.lark-cli/openclaw/config.json ~/.lark-cli/config.json
```

### 2. `keychain unavailable` 或 `keychain not initialized`

通常是沙箱或非交互环境无法访问 macOS Keychain。

处理：

- 在正常终端执行 `lark-cli config bind ...`。
- 或给当前执行环境授权访问 Keychain。
- 不要改用明文 secret 文件，除非能保证本机文件权限和密钥管理策略。

### 3. 当前 Codex 会话仍看到 Feishu MCP 工具

这是会话级工具注册表没有热刷新。

处理：

```bash
codex mcp list
```

只要全局列表里没有 `feishu`，说明配置已移除。新开 Codex 会话后工具列表会刷新。

### 4. `missing required scope(s)`

按报错提示补单个 scope，不要盲目重复 `--recommend`。

示例：

```bash
lark-cli auth login --scope "search:docs:read"
lark-cli auth login --scope "contact:user:search"
```

### 5. GitHub 上传失败

如果上传文档时出现：

```text
Failed to connect to 127.0.0.1 port 7890
```

说明 Git 全局代理指向了本机代理，但代理未运行。临时绕过：

```bash
git -c http.proxy= -c https.proxy= ls-remote https://github.com/<owner>/<repo>.git HEAD
```

如果 `gh auth status` 提示 token invalid，需要重新登录：

```bash
gh auth login -h github.com
```

## 本次实际操作记录

```bash
# 查看 MCP
codex mcp list
codex mcp get feishu

# 安装 CLI
npm install -g @larksuite/cli
lark-cli --version

# 移除 Feishu MCP
codex mcp remove feishu
codex mcp list

# 绑定 OpenClaw 配置
lark-cli config bind --source openclaw --identity user-default
cp ~/.lark-cli/openclaw/config.json ~/.lark-cli/config.json

# 授权
lark-cli auth login --recommend --no-wait --json
lark-cli auth login --device-code <DEVICE_CODE>

# 补 scope
lark-cli auth login --scope "search:docs:read contact:user:search" --no-wait --json
lark-cli auth login --device-code <DEVICE_CODE>

# 验证
lark-cli doctor
lark-cli docs +search --query "用户媒体" --format json --page-size 3
lark-cli contact +search-user --query "周丽丽" --format json
lark-cli im +messages-send --chat-id oc_xxx --text "lark-cli dry-run validation" --dry-run --as bot
```

## 维护建议

- 后续飞书操作默认优先使用 `lark-cli`，不要重新添加 Feishu MCP。
- 需要新增飞书能力时，先运行目标命令；如果报 `missing_scope`，只补精确 scope。
- 涉及发送消息、改文档、改权限等写操作时，先用 `--dry-run` 或只读命令验证参数。
- 定期检查：

```bash
lark-cli auth status
lark-cli doctor
```
