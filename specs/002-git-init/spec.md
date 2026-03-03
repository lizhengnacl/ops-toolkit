# Git 一键初始化工具 功能规格说明

> 版本: 1.0.0-draft
> 日期: 2026-03-03
> 状态: 草稿

---

## 1. 概述

### 1.1 产品定位

`git-init.sh` 是一个**单文件、零依赖**的 Bash 脚本，用于在新机器环境下**一键初始化完整的 Git 开发环境**。无需提前 clone 任何仓库，直接通过 curl 即可运行，解决了 "git clone 需要 Git 配置，而配置 Git 又需要先 clone 仓库" 的鸡生蛋蛋生鸡问题。

### 1.2 核心价值

- **零依赖启动**：单文件脚本，curl 即可运行，无需提前安装任何工具（除 Git 和 Bash 外）
- **完整配置**：从用户信息、SSH Key、全局忽略文件到 Git 别名，一站式搞定
- **多账户支持**：通过目录自动切换 Git 账户，适应工作/个人多场景
- **验证保障**：配置完成后自动验证 SSH 连接，确保可用

### 1.3 目标用户

- 刚拿到新电脑的开发者
- 需要在多台机器间同步 Git 配置的工程师
- 经常切换工作环境的自由职业者
- 需要快速上手新开发环境的团队成员

---

## 2. 用户故事

### US-001: 新机器快速配置 Git 环境

> 作为一名 **刚换新电脑的开发者**，
> 我希望 **通过一条 curl 命令完成所有 Git 相关配置**，
> 以便于 **立即可以 git clone 仓库开始工作，而不用手动一步步配置**。

**验收条件：**
- 命令格式：`curl -fsSL https://example.com/git-init.sh | bash`
- 交互式引导输入必要信息
- 配置完成后显示成功摘要

### US-002: 多账户自动切换

> 作为一名 **同时有工作和个人 Git 账户的开发者**，
> 我希望 **在不同目录下自动使用对应的 Git 账户**，
> 以便于 **不用每次 commit 前都手动切换 user.name 和 user.email**。

**验收条件：**
- 支持配置多个 Git 账户
- 每个账户关联特定的工作目录
- 使用 Git 的 includeIf 机制实现自动切换
- 在关联目录下自动使用对应账户

### US-003: 配置导入导出

> 作为一名 **需要在多台机器间同步配置的开发者**，
> 我希望 **将当前 Git 配置导出为文件，在新机器上一键导入**，
> 以便于 **不用重复输入相同的配置信息**。

**验收条件：**
- 导出格式为可直接执行的 Shell 脚本
- 导出文件包含所有配置信息（不包含私钥）
- 导入时可跳过交互式引导，直接应用配置

### US-004: 配置有效性验证

> 作为一名 **刚完成配置的开发者**，
> 我希望 **工具自动验证 Git 配置是否正确可用**，
> 以便于 **在真正使用前发现问题并修复**。

**验收条件：**
- 验证 SSH Key 是否能成功连接到 GitHub/GitLab
- 验证 Git 基本配置项是否完整
- 验证失败时提供清晰的错误信息和解决建议

---

## 3. 功能性需求

### 3.1 安装与入口

#### FR-001: curl 一键运行

提供一行命令即可运行的方式：

```bash
curl -fsSL https://raw.githubusercontent.com/lizhengnacl/ops-toolkit/main/scripts/git-init.sh | bash
```

**要求：**
- 脚本自包含，无外部依赖（除 Bash 4.0+ 和 Git）
- 自动检测系统环境
- 友好的错误提示

### 3.2 交互式配置流程

#### FR-002: 主账户配置

引导用户配置主 Git 账户：

```
🚀 Git 一键初始化工具
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 主账户配置
────────────────────────────────────────
请输入 Git 用户名: [张三]
请输入 Git 邮箱: [zhangsan@example.com]
```

#### FR-003: SSH Key 生成

检测并生成 SSH Key：

```
🔑 SSH Key 配置
────────────────────────────────────────
检测到已存在 SSH Key (~/.ssh/id_ed25519)
请选择操作:
  1) 使用现有 Key
  2) 备份并生成新 Key
  3) 跳过 SSH Key 配置

请输入选项 [1]:
```

**要求：**
- 默认使用 ed25519 算法
- 支持选择算法（ed25519 / rsa 4096）
- 生成时询问密钥密码（可选）
- 生成后自动将公钥复制到剪贴板（如系统支持）

#### FR-004: 全局 .gitignore 配置

配置全局忽略文件：

```
📄 全局 .gitignore 配置
────────────────────────────────────────
请选择 .gitignore 模板:
  1) 使用通用模板（推荐）
  2) 使用自定义模板
  3) 跳过 .gitignore 配置

请输入选项 [1]:
```

**通用模板应包含：**
- macOS: `.DS_Store`, `._*`
- 编辑器: `.vscode/`, `.idea/`, `*.swp`, `*.swo`
- 编程语言: `node_modules/`, `__pycache__/`, `*.pyc`
- 环境变量: `.env`, `.env.local`

#### FR-005: Git 别名配置

配置常用 Git 别名：

```
⚡ Git 别名配置
────────────────────────────────────────
是否配置常用 Git 别名? [Y/n]:
```

**默认别名列表：**
| 别名 | 命令 | 说明 |
|------|------|------|
| `st` | `status` | 状态 |
| `co` | `checkout` | 检出 |
| `br` | `branch` | 分支 |
| `ci` | `commit` | 提交 |
| `lg` | `log --color --graph --pretty=format:...` | 美化日志 |
| `unstage` | `reset HEAD --` | 取消暂存 |
| `last` | `log -1 HEAD` | 最后一次提交 |

#### FR-006: 多账户配置

支持配置额外的 Git 账户：

```
👥 多账户配置
────────────────────────────────────────
是否配置额外的 Git 账户? [y/N]: y

请输入账户名称（例如：工作）: [工作]
请输入 Git 用户名: [李四]
请输入 Git 邮箱: [lisi@company.com]
请输入关联的工作目录（例如：~/work）: [~/work]

是否继续添加账户? [y/N]:
```

**实现方式：**
- 使用 Git 的 `includeIf` 机制
- 在 `~/.gitconfig` 中添加条件包含配置
- 每个账户对应独立的配置文件（如 `~/.gitconfig-work`）

### 3.3 配置验证

#### FR-007: SSH 连接测试

配置完成后自动验证 SSH 连接：

```
✅ 验证配置
────────────────────────────────────────
正在测试 GitHub SSH 连接...
Hi username! You've successfully authenticated...

正在测试 GitLab SSH 连接...
Hi username! You've successfully authenticated...
```

**要求：**
- 测试连接到 GitHub (`ssh -T git@github.com`)
- 测试连接到 GitLab (`ssh -T git@gitlab.com`)
- 连接失败时提供解决建议
- 询问用户是否要添加其他 Git 托管平台

### 3.4 配置导入导出

#### FR-008: 配置导出

支持将当前配置导出为 Shell 脚本：

```bash
./git-init.sh --export ~/git-config-backup.sh
```

**导出内容：**
- Git 用户配置（user.name, user.email）
- 多账户配置信息
- 全局 .gitignore 内容（不包含私钥）
- Git 别名配置

**导出格式：**
- 可直接执行的 Shell 脚本
- 包含 `GIT_INIT_CONFIG_*` 环境变量
- 执行时可跳过交互式引导

#### FR-009: 配置导入

支持从导出文件导入配置：

```bash
curl -fsSL https://example.com/git-init.sh | bash -s -- --import ~/git-config-backup.sh
```

**要求：**
- 跳过交互式引导，直接应用配置
- 验证导入配置的有效性
- 导入前提示用户确认

### 3.5 命令行参数

#### FR-010: 完整参数列表

```
git-init.sh [选项]

选项:
  -h, --help          显示帮助信息
  -v, --version       显示版本信息
  -e, --export <文件> 导出配置到文件
  -i, --import <文件> 从文件导入配置
  -y, --yes           自动确认所有提示
  --no-ssh            跳过 SSH Key 配置
  --no-gitignore      跳过 .gitignore 配置
  --no-aliases        跳过 Git 别名配置
  --no-verify         跳过配置验证
```

---

## 4. 非功能性需求

### 4.1 性能要求

| 指标 | 要求 |
|------|------|
| 启动时间 | < 1 秒 |
| 完整配置流程 | < 2 分钟（不包含用户输入时间） |
| SSH 连接测试 | < 10 秒（超时时间） |

### 4.2 可靠性

- **幂等执行**：可安全重复运行，已配置项自动跳过
- **备份机制**：修改配置文件前自动备份（`~/.gitconfig.bak`）
- **原子操作**：关键配置使用临时文件 + mv 确保原子性
- **错误恢复**：单个步骤失败时，已完成的配置保持有效

### 4.3 兼容性

| 系统 | 最低版本 |
|------|----------|
| macOS | 10.15 (Catalina) |
| Ubuntu | 18.04 LTS |
| Debian | 10 |
| CentOS/RHEL | 7 |
| Git | 2.0+ |
| Bash | 4.0+ |

### 4.4 安全性

- SSH 私钥文件权限正确设置（600）
- 导出文件不包含 SSH 私钥
- 不记录敏感信息到日志
- 提示用户妥善保管导出的配置文件

### 4.5 可维护性

- 单文件脚本，不超过 500 行
- 清晰的函数划分和注释
- 遵循 Shell 脚本最佳实践
- 通过 ShellCheck 静态检查

---

## 5. 验收标准

### 5.1 功能验收

| 编号 | 场景 | 预期结果 |
|------|------|----------|
| AC-001 | 全新 macOS 执行脚本 | 交互式引导完成所有配置，SSH 连接测试通过 |
| AC-002 | 已存在 SSH Key | 询问用户如何处理，支持使用现有/备份新建/跳过 |
| AC-003 | 配置多账户 | 在关联目录下自动使用对应账户的 user.name/email |
| AC-004 | 导出配置 | 生成可执行的 Shell 脚本，包含所有配置信息 |
| AC-005 | 导入配置 | 跳过交互式引导，直接应用配置并验证 |
| AC-006 | 重复执行脚本 | 已配置项自动跳过，幂等执行 |
| AC-007 | SSH 连接失败 | 显示清晰错误信息和解决建议 |
| AC-008 | 无网络连接 | 本地配置仍可完成，仅跳过网络验证 |

### 5.2 质量验收

- [ ] 通过 ShellCheck 静态检查
- [ ] 在 macOS 和 Ubuntu 上完成端到端测试
- [ ] 配置文件修改前自动备份
- [ ] 提供清晰的错误信息和解决建议
- [ ] 脚本自包含，无外部依赖（除 Git 和 Bash）

---

## 6. 输出格式示例

### 6.1 完整执行流程示例

```
$ curl -fsSL https://example.com/git-init.sh | bash

🚀 Git 一键初始化工具 v1.0.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 主账户配置
────────────────────────────────────────
请输入 Git 用户名: 张三
请输入 Git 邮箱: zhangsan@example.com

🔑 SSH Key 配置
────────────────────────────────────────
未检测到 SSH Key
请选择 SSH 算法:
  1) ed25519（推荐）
  2) rsa 4096
请输入选项 [1]:
请输入密钥密码（留空则无密码）:
生成 SSH Key 中...
✅ SSH Key 已生成: ~/.ssh/id_ed25519
📋 公钥已复制到剪贴板

📄 全局 .gitignore 配置
────────────────────────────────────────
请选择 .gitignore 模板:
  1) 使用通用模板（推荐）
  2) 使用自定义模板
  3) 跳过 .gitignore 配置
请输入选项 [1]:
✅ 全局 .gitignore 已配置

⚡ Git 别名配置
────────────────────────────────────────
是否配置常用 Git 别名? [Y/n]:
✅ Git 别名已配置

👥 多账户配置
────────────────────────────────────────
是否配置额外的 Git 账户? [y/N]: y

请输入账户名称（例如：工作）: 工作
请输入 Git 用户名: 李四
请输入 Git 邮箱: lisi@company.com
请输入关联的工作目录（例如：~/work）: ~/work

是否继续添加账户? [y/N]:
✅ 多账户配置已完成

✅ 验证配置
────────────────────────────────────────
正在测试 GitHub SSH 连接...
Hi zhangsan! You've successfully authenticated...

正在测试 GitLab SSH 连接...
Hi zhangsan! You've successfully authenticated...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 Git 配置完成！

📋 配置摘要:
  • 用户: 张三 <zhangsan@example.com>
  • SSH Key: ed25519 (~/.ssh/id_ed25519)
  • 全局 .gitignore: 已配置
  • Git 别名: 已配置
  • 额外账户: 1 个（工作）

💡 提示:
  • 请将公钥添加到 GitHub/GitLab
  • 在 ~/work 目录下会自动使用工作账户
  • 使用 --export 可以导出配置备份
```

### 6.2 导出配置文件示例

```bash
#!/usr/bin/env bash
# Git 配置导出文件
# 生成时间: 2026-03-03
# 使用方法: ./git-init.sh --import this-file.sh

export GIT_INIT_CONFIG_MAIN_NAME="张三"
export GIT_INIT_CONFIG_MAIN_EMAIL="zhangsan@example.com"

export GIT_INIT_CONFIG_SSH_ALGORITHM="ed25519"
export GIT_INIT_CONFIG_SSH_KEY_PATH="~/.ssh/id_ed25519"

export GIT_INIT_CONFIG_GITIGNORE_TEMPLATE="default"
export GIT_INIT_CONFIG_GITIGNORE_CONTENT="$(cat <<'EOF'
.DS_Store
node_modules/
.env
.vscode/
EOF
)"

export GIT_INIT_CONFIG_ALIASES="yes"

export GIT_INIT_CONFIG_EXTRA_ACCOUNTS="$(cat <<'EOF'
name=work,email=lisi@company.com,dir=~/work
EOF
)"

export GIT_INIT_CONFIG_VERIFY="yes"
```

### 6.3 帮助信息示例

```
$ ./git-init.sh --help

Git 一键初始化工具 v1.0.0

在新机器环境下一键初始化完整的 Git 开发环境。

用法:
  git-init.sh [选项]

选项:
  -h, --help          显示此帮助信息
  -v, --version       显示版本信息
  -e, --export <文件> 导出配置到文件
  -i, --import <文件> 从文件导入配置
  -y, --yes           自动确认所有提示
  --no-ssh            跳过 SSH Key 配置
  --no-gitignore      跳过 .gitignore 配置
  --no-aliases        跳过 Git 别名配置
  --no-verify         跳过配置验证

示例:
  # 交互式配置
  curl -fsSL https://example.com/git-init.sh | bash

  # 导出配置
  ./git-init.sh --export ~/git-config.sh

  # 导入配置
  ./git-init.sh --import ~/git-config.sh

  # 跳过 SSH Key 配置
  ./git-init.sh --no-ssh

项目地址: https://github.com/lizhengnacl/ops-toolkit
```

---

## 7. 目录结构

```
ops-toolkit/
├── scripts/
│   └── git-init.sh          # Git 一键初始化脚本（新增）
├── specs/
│   └── 002-git-init/
│       └── spec.md          # 本文档
├── configs/
│   └── git/
│       ├── gitconfig.template
│       └── gitignore.template  # 全局 .gitignore 模板（新增）
└── tests/
    └── integration/
        └── test_git_init.sh    # git-init.sh 测试（新增）
```

---

## 8. 里程碑规划

| 阶段 | 内容 | 状态 |
|------|------|------|
| M1 | 基础框架 + 主账户配置 | 待开始 |
| M2 | SSH Key 生成 + .gitignore 配置 | 待开始 |
| M3 | Git 别名 + 多账户配置 | 待开始 |
| M4 | 配置验证 + 导入导出 | 待开始 |
| M5 | 测试 + 文档 | 待开始 |

---

## 9. 待讨论事项

- [ ] 是否需要支持 GPG 签名配置？
- [ ] 是否需要支持 GitHub CLI 登录？
- [ ] 是否需要支持从云端同步配置（如 GitHub Gist）？
- [ ] 配置备份保留策略（默认保留 3 个备份？）

---

*文档版本: 1.0.0-draft | 最后更新: 2026-03-03*
