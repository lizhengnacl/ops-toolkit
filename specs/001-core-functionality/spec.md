# ops-toolkit 功能规格说明

> 版本: 1.0.0-draft
> 日期: 2026-03-02
> 状态: 草稿

---

## 1. 概述

### 1.1 产品定位

`ops-toolkit` 是一款面向个人开发者的命令行工具，专注于**新环境的快速初始化**。通过交互式选择和幂等执行，帮助开发者在 macOS/Linux 系统上快速配置基础开发环境。

### 1.2 核心价值

- **效率提升**：一键完成繁琐的环境配置工作
- **幂等安全**：可重复执行，自动跳过已配置项
- **简洁易用**：交互式引导，无需记忆复杂参数

### 1.3 目标用户

- 个人开发者
- 频繁更换开发环境的工程师
- 需要在多台机器间同步基础配置的用户

---

## 2. 用户故事

### US-001: 全新机器环境初始化

> 作为一名 **刚换新电脑的开发者**，
> 我希望 **通过一条命令完成基础开发环境配置**，
> 以便于 **快速进入开发状态，而不是花费半天时间手动配置**。

**验收条件：**
- 执行 `ops-toolkit init` 后，通过交互式选择需要的组件
- 自动检测操作系统类型（macOS/Linux）
- 完成后显示成功配置的组件摘要

### US-002: 增量配置补充

> 作为一名 **已有部分开发环境的开发者**，
> 我希望 **重复运行工具时能智能跳过已配置项**，
> 以便于 **安全地补充缺失的配置而不产生冲突**。

**验收条件：**
- 检测 Git 是否已配置 user.name/user.email
- 检测 SSH key 是否已存在
- 检测 zsh 插件是否已安装
- 已存在的配置项在交互界面中标记为 `[已安装]`

### US-003: 部分失败继续执行

> 作为一名 **正在初始化环境的开发者**，
> 我希望 **某个组件安装失败时能继续安装其他组件**，
> 以便于 **最大化完成度，而不是因为一个小问题全部中止**。

**验收条件：**
- 单个组件失败时记录错误并继续
- 执行完成后汇总显示成功/失败列表
- 失败项提供错误原因和可能的解决方案

---

## 3. 功能性需求

### 3.1 安装与入口

#### FR-001: curl 安装

提供一行命令安装方式：

```bash
curl -fsSL https://raw.githubusercontent.com/user/ops-toolkit/main/install.sh | bash
```

**要求：**
- 自动检测系统类型
- 安装到 `~/.local/bin/` 或 `$HOME/.ops-toolkit/bin/`
- 自动添加到 PATH（如需要）
- 支持卸载命令 `ops-toolkit uninstall`

#### FR-002: 主命令结构

```
ops-toolkit
├── init          # 交互式环境初始化（主命令）
├── list          # 列出所有可用组件
├── version       # 显示版本信息
├── help          # 显示帮助信息
└── uninstall     # 卸载工具
```

### 3.2 交互式初始化 (init)

#### FR-003: 系统检测

自动检测并显示当前系统信息：

```
🔍 检测到系统: macOS Sonoma (arm64)
📦 正在扫描已安装组件...
```

#### FR-004: 组件分类与选择

按类别展示可初始化的组件，用户通过多选方式选择：

```
🛠  ops-toolkit init
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

请选择要初始化的组件 (空格选择, 回车确认):

  Shell 与 Git
  ─────────────────────────────────────
  [x] Git 配置 (user.name, user.email) [已配置]
  [ ] SSH Key 生成
  [ ] zsh 配置 (oh-my-zsh, 插件)
  [ ] bash 增强配置

  编辑器配置
  ─────────────────────────────────────
  [ ] Vim 基础配置
  [ ] Neovim 配置
  [ ] VS Code 常用扩展

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
已选择 3 个组件, 按回车开始安装...
```

#### FR-005: 幂等性检测

每个组件执行前进行状态检测：

| 组件 | 检测逻辑 |
|------|----------|
| Git 配置 | `git config --global user.name` 是否有值 |
| SSH Key | `~/.ssh/id_ed25519` 或 `id_rsa` 是否存在 |
| oh-my-zsh | `~/.oh-my-zsh` 目录是否存在 |
| Vim 配置 | `~/.vimrc` 是否存在且包含特定标记 |
| VS Code 扩展 | `code --list-extensions` 是否包含目标扩展 |

### 3.3 组件执行

#### FR-006: 执行流程

```
🚀 开始初始化...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✓ Git 配置        跳过 (已配置)
  ✓ SSH Key 生成    完成 (ed25519)
  ✓ zsh 配置        完成 (oh-my-zsh + zsh-autosuggestions)
  ✓ Vim 基础配置    完成

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 完成 3 项, 跳过 1 项, 失败 0 项

💡 提示: 请运行 source ~/.zshrc 使 zsh 配置生效
```

#### FR-007: 错误处理

- 单个组件失败时继续执行后续组件
- 记录失败原因到日志文件 `~/.ops-toolkit/logs/`
- 最终汇总显示失败项及建议

```
⚠️ 部分组件安装失败:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✗ VS Code 扩展
    原因: code 命令未找到
    建议: 请在 VS Code 中安装 shell command

查看详细日志: ~/.ops-toolkit/logs/init-20260302.log
```

### 3.4 内置组件清单

#### FR-008: Shell 与 Git 类

| 组件 ID | 名称 | macOS | Linux | 描述 |
|---------|------|-------|-------|------|
| `git-config` | Git 基础配置 | ✓ | ✓ | 配置 user.name, user.email, 常用别名 |
| `ssh-key` | SSH Key | ✓ | ✓ | 生成 ed25519 密钥对 |
| `zsh-ohmyzsh` | oh-my-zsh | ✓ | ✓ | 安装 oh-my-zsh 框架 |
| `zsh-plugins` | zsh 插件 | ✓ | ✓ | 安装 autosuggestions, syntax-highlighting |
| `bash-enhanced` | bash 增强 | ✓ | ✓ | 配置 bash 历史记录、补全增强 |

#### FR-009: 编辑器配置类

| 组件 ID | 名称 | macOS | Linux | 描述 |
|---------|------|-------|-------|------|
| `vim-basic` | Vim 基础 | ✓ | ✓ | 基础 .vimrc 配置 |
| `neovim-config` | Neovim 配置 | ✓ | ✓ | LazyVim 或基础配置 |
| `vscode-extensions` | VS Code 扩展 | ✓ | ✓ | 安装常用开发扩展 |

---

## 4. 非功能性需求

### 4.1 性能要求

| 指标 | 要求 |
|------|------|
| 启动时间 | < 500ms（到显示交互界面） |
| 单组件检测 | < 100ms |
| 完整初始化 | < 5 分钟（网络正常情况下） |

### 4.2 可靠性

- **幂等保证**：所有组件可安全重复执行
- **回滚机制**：配置文件修改前自动备份
- **原子操作**：关键配置使用临时文件 + mv 确保原子性

### 4.3 兼容性

| 系统 | 最低版本 |
|------|----------|
| macOS | 12.0 (Monterey) |
| Ubuntu | 20.04 LTS |
| Debian | 11 |
| CentOS/RHEL | 8 |

### 4.4 安全性

- SSH Key 使用 ed25519 算法（更安全更快）
- 敏感信息（如 Git token）不记录到日志
- 下载外部资源时验证 HTTPS 证书

### 4.5 可维护性

- 遵循 CLAUDE.md 中定义的 Shell 脚本规范
- 每个组件独立文件，便于维护
- 日志级别支持 DEBUG/INFO/WARN/ERROR

---

## 5. 验收标准

### 5.1 功能验收

| 编号 | 场景 | 预期结果 |
|------|------|----------|
| AC-001 | 全新 macOS 执行 init | 交互式选择后，所有选中组件配置成功 |
| AC-002 | 重复执行 init | 已配置项自动跳过，标记为 `[已配置]` |
| AC-003 | 某组件安装失败 | 继续执行其他组件，最终汇总失败信息 |
| AC-004 | 不支持的系统 | 友好提示 "当前系统不支持" |
| AC-005 | 无网络连接 | 提示网络错误，本地组件可继续 |

### 5.2 质量验收

- [ ] 通过 ShellCheck 静态检查
- [ ] 在 macOS 和 Ubuntu 上完成端到端测试
- [ ] 日志文件格式规范，便于问题排查
- [ ] 提供清晰的错误信息和解决建议

---

## 6. 输出格式示例

### 6.1 正常执行输出

```
$ ops-toolkit init

🔍 检测到系统: macOS Sonoma 14.3 (arm64)
📦 正在扫描已安装组件...

🛠  请选择要初始化的组件:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Shell 与 Git
  ─────────────────────────────────────
  [x] Git 配置                    [已配置]
  [ ] SSH Key 生成
  [x] zsh 配置 (oh-my-zsh)
  [ ] bash 增强配置

  编辑器配置
  ─────────────────────────────────────
  [ ] Vim 基础配置
  [ ] Neovim 配置
  [ ] VS Code 常用扩展

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
已选择 2 个组件, 按回车开始安装...

🚀 开始初始化...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✓ Git 配置         跳过 (已配置)
  ✓ SSH Key 生成     完成 (ed25519)
  ✓ zsh 配置         完成

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 完成 2 项, 跳过 1 项, 失败 0 项

💡 提示:
  - SSH 公钥已复制到剪贴板，请添加到 GitHub/GitLab
  - 请运行 source ~/.zshrc 使 zsh 配置生效
```

### 6.2 列出组件输出

```
$ ops-toolkit list

📦 可用组件列表
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Shell 与 Git
  ─────────────────────────────────────
  git-config        Git 基础配置 (user.name, user.email)
  ssh-key           SSH Key 生成 (ed25519)
  zsh-ohmyzsh       oh-my-zsh 框架
  zsh-plugins       zsh 插件 (autosuggestions, syntax-highlighting)
  bash-enhanced     bash 增强配置

  编辑器配置
  ─────────────────────────────────────
  vim-basic         Vim 基础配置
  neovim-config     Neovim 配置 (LazyVim)
  vscode-extensions VS Code 常用扩展

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
共 8 个组件 | 使用 ops-toolkit init 开始配置
```

### 6.3 版本信息输出

```
$ ops-toolkit version

ops-toolkit v1.0.0
  系统支持: macOS, Linux
  组件数量: 8
  安装路径: ~/.local/bin/ops-toolkit
```

---

## 7. 目录结构

```
ops-toolkit/
├── install.sh              # curl 安装脚本
├── uninstall.sh            # 卸载脚本
├── ops-toolkit             # CLI 入口脚本
├── lib/
│   ├── core.sh             # 核心函数库
│   ├── ui.sh               # 交互式 UI 函数
│   ├── detect.sh           # 系统检测函数
│   └── logger.sh           # 日志函数
├── components/
│   ├── shell-git/
│   │   ├── git-config.sh
│   │   ├── ssh-key.sh
│   │   ├── zsh-ohmyzsh.sh
│   │   ├── zsh-plugins.sh
│   │   └── bash-enhanced.sh
│   └── editor/
│       ├── vim-basic.sh
│       ├── neovim-config.sh
│       └── vscode-extensions.sh
├── configs/
│   ├── git/.gitconfig.template
│   ├── zsh/.zshrc.append
│   └── vim/.vimrc.template
├── tests/
│   ├── test_detect.sh
│   └── test_components.sh
├── specs/
│   └── 001-core-functionality/
│       └── spec.md
├── CLAUDE.md
├── constitution.md
└── README.md
```

---

## 8. 里程碑规划

| 阶段 | 内容 | 状态 |
|------|------|------|
| M1 | CLI 框架 + 系统检测 | 待开始 |
| M2 | Shell 与 Git 组件 | 待开始 |
| M3 | 编辑器配置组件 | 待开始 |
| M4 | 安装脚本 + 文档 | 待开始 |

---

## 9. 待讨论事项

- [ ] 是否需要支持配置文件导入导出（后续版本）？
- [ ] 是否需要支持远程扩展脚本（后续版本）？
- [ ] 日志文件保留策略（默认 7 天？）

---

*文档版本: 1.0.0-draft | 最后更新: 2026-03-02*
