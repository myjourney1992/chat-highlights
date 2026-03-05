# OpenClaw 高级配置与增强功能

> 让你的机器人更强大、更个性化

## 目录

- [本地服务运行](#本地服务运行)
- [自定义机器人身份](#自定义机器人身份)
- [记忆系统](#记忆系统)
- [心跳检测](#心跳检测)
- [技能扩展](#技能扩展)

---

## 本地服务运行

### 长连接模式说明

**好消息**：OpenClaw 使用**长连接模式**，不需要公网地址！

```
你的机器(本地) ──主动连接──> 飞书服务器
                    ↑
            长连接建立后，飞书可以随时推送消息
```

### 运行方式对比

| 方式 | 优点 | 缺点 | 推荐场景 |
|-----|------|------|---------|
| 本地运行 | 数据完全本地，隐私安全 | 电脑关机则不可用 | 个人使用 |
| 服务器运行 | 24/7 在线，稳定 | 需要服务器 | 频繁使用 |

### 本地运行技巧

```bash
# 开机自动启动（macOS）
# 1. 创建启动脚本
cat > ~/start-openclaw.sh << 'EOF'
#!/bin/bash
openclaw gateway --port 18789
EOF

chmod +x ~/start-openclaw.sh

# 2. 添加到登录项（系统偏好设置 -> 用户与群组 -> 登录项）
```

### 服务器运行（可选）

如果你有服务器（如 VPS），可以部署在那里：

```bash
# 1. 安装 Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 2. 安装 OpenClaw
npm install -g openclaw

# 3. 复制配置文件
scp ~/.openclaw/* user@server:~/.openclaw/

# 4. 使用 PM2 保持运行
npm install -g pm2
pm2 start "openclaw gateway --port 18789" --name openclaw
pm2 save
pm2 startup
```

---

## 自定义机器人身份

编辑 `~/.openclaw/workspace/IDENTITY.md`：

```markdown
- **Name:** 小飞
- **Creature:** AI 助手
- **Vibe:** 友好、专业、简洁、偶尔幽默
- **Emoji:** 🤖
- **Avatar:** (可选，头像路径)
```

### 修改示例

```bash
vim ~/.openclaw/workspace/IDENTITY.md
```

修改后重启 Gateway：
```bash
lsof -i :18789 -t | xargs kill -9
openclaw gateway --port 18789
```

---

## 记忆系统

OpenClaw 支持长期和短期记忆，让机器人记住重要信息。

### 创建记忆目录

```bash
mkdir -p ~/.openclaw/workspace/memory
```

### 记忆文件结构

```
~/.openclaw/workspace/
├── memory/
│   ├── 2026-03-05.md    # 每日记忆
│   ├── 2026-03-06.md
│   └── ...
└── MEMORY.md            # 长期记忆（人工精选）
```

### 每日记忆格式

```markdown
# 2026-03-05

## 重要对话

- 用户提到最近在学习 Flutter
- 讨论了 OpenClaw 配置问题

## 待办事项

- [ ] 更新配置文档
- [ ] 添加故障排查指南

## 其他记录

今天解决了 API 代理配置问题，用户现在可以正常使用机器人了。
```

### MEMORY.md 长期记忆

```markdown
# MEMORY.md - 长期记忆

## 用户信息

- 姓名：张三
- 职业：程序员
- 技术栈：Flutter, Node.js

## 偏好设置

- 语言：简体中文
- 回复风格：简洁、专业
```

### 让机器人自动记录

在 `SOUL.md` 中添加：

```markdown
## 记忆规则

**记录重要信息。** 当用户提到重要事项（如偏好、任务、约定），记录到 `memory/YYYY-MM-DD.md`。
**定期整理。** 每周将重要信息从每日记忆迁移到 MEMORY.md。
```

---

## 心跳检测

心跳检测让机器人定期主动检查，而不是被动等待消息。

### 配置心跳检测

编辑 `~/.openclaw/workspace/HEARTBEAT.md`：

```markdown
# HEARTBEAT.md - 定期检查任务

## 每日检查

- [ ] 检查今日天气
- [ ] 检查日历今日事件
- [ ] 检查是否有重要邮件

## 回复规则

- **无事发生**：回复 `HEARTBEAT_OK`
- **有重要事项**：简洁说明
- **夜间 (23:00-08:00)**：直接回复 `HEARTBEAT_OK`
```

### 心跳频率

心跳由外部触发（如定时任务或飞书定时消息），机器人收到后会执行检查。

### 手动触发测试

在飞书发送心跳消息（需配置触发器）：
```
@heartbeat
```

---

## 技能扩展

OpenClaw 支持通过 skills 扩展功能。

### 查看已有技能

```bash
openclaw skills list
```

### 安装新技能

```bash
# 从 GitHub 安装
openclaw skills install github:user/repo

# 从本地安装
openclaw skills install /path/to/skill
```

### 常用技能类型

| 技能 | 功能 |
|-----|------|
| 搜索 | 网络搜索能力 |
| 日历 | 读取/创建日程 |
| 天气 | 查询天气 |
| 代码执行 | 执行代码片段 |

### 自定义技能（高级）

创建自定义技能目录：

```bash
mkdir -p ~/.openclaw/skills/my-skill
cd ~/.openclaw/skills/my-skill
```

创建 `SKILL.md`：

```markdown
# 我的技能

## 描述

这是一个示例技能。

## 使用方法

用户说"xxx"时，执行此技能。
```

---

## 调试技巧

### 查看实时日志

```bash
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log
```

### 测试配置

```bash
openclaw doctor
openclaw channels status --probe
```

### 查看 agent 状态

```bash
openclaw agents list
openclaw agents logs
```

---

## 完整配置示例

```bash
~/.openclaw/
├── openclaw.json           # 主配置
├── workspace/
│   ├── SOUL.md             # 行为准则
│   ├── IDENTITY.md         # 身份设定
│   ├── HEARTBEAT.md        # 心跳任务
│   ├── MEMORY.md           # 长期记忆
│   └── memory/             # 每日记忆
│       ├── 2026-03-05.md
│       └── ...
└── skills/                 # 自定义技能
    └── my-skill/
```

---

## 更多文档

- [配置教程](./setup.md)
- [原理说明](./how-it-works.md)
- [故障排查](./troubleshooting.md)
