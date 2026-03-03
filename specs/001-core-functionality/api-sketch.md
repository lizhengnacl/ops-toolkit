# ops-toolkit API 设计草图

> 版本: 1.0.0-draft
> 日期: 2026-03-02
> 状态: 草稿

---

## 1. 包结构设计

```
ops-toolkit/
│
├── install.sh                    # 安装入口脚本
├── uninstall.sh                  # 卸载脚本
│
├── bin/
│   └── ops-toolkit               # CLI 主入口 (用户调用入口)
│
├── lib/                          # 核心库
│   ├── init.sh                   # init 子命令入口
│   ├── list.sh                   # list 子命令入口
│   │
│   ├── core/
│   │   ├── constants.sh          # 全局常量定义
│   │   ├── logging.sh            # 日志系统
│   │   ├── utils.sh              # 通用工具函数
│   │   └── validation.sh         # 参数校验函数
│   │
│   ├── system/
│   │   ├── detect.sh             # 系统检测 (OS, arch, package manager)
│   │   └── prerequisites.sh      # 依赖检查 (curl, git 等)
│   │
│   ├── ui/
│   │   ├── interactive.sh        # 交互式选择界面
│   │   ├── output.sh             # 输出格式化 (颜色, 表格)
│   │   └── progress.sh           # 进度显示
│   │
│   └── component/
│       ├── registry.sh           # 组件注册表
│       ├── executor.sh           # 组件执行器
│       └── detector.sh           # 组件状态检测器
│
├── components/                   # 内置组件实现
│   │
│   ├── _base.sh                  # 组件基类 (提供通用函数)
│   │
│   ├── shell-git/                # Shell 与 Git 类别
│   │   ├── _category.sh          # 类别元数据
│   │   ├── git-config.sh
│   │   ├── ssh-key.sh
│   │   ├── zsh-ohmyzsh.sh
│   │   ├── zsh-plugins.sh
│   │   └── bash-enhanced.sh
│   │
│   └── editor/                   # 编辑器配置类别
│       ├── _category.sh
│       ├── vim-basic.sh
│       ├── neovim-config.sh
│       └── vscode-extensions.sh
│
├── configs/                      # 配置模板
│   ├── git/
│   │   └── gitconfig.template
│   ├── zsh/
│   │   └── zshrc.append
│   ├── bash/
│   │   └── bashrc.append
│   └── vim/
│       └── vimrc.template
│
├── tests/                        # 测试脚本
│   ├── helpers/
│   │   └── test-utils.sh         # 测试工具函数
│   ├── unit/
│   │   ├── test_logging.sh
│   │   ├── test_detect.sh
│   │   └── test_utils.sh
│   └── integration/
│       └── test_init_flow.sh
│
├── scripts/                      # 开发辅助脚本
│   ├── lint.sh                   # 运行 ShellCheck
│   └── test.sh                   # 运行测试
│
└── docs/                         # 文档
    ├── components.md             # 组件开发指南
    └── contributing.md           # 贡献指南
```

---

## 2. 核心模块接口

### 2.1 CLI 主入口 (`bin/ops-toolkit`)

```bash
# 用法
ops-toolkit <command> [options]

# 命令
init        交互式环境初始化
list        列出所有可用组件
version     显示版本信息
help        显示帮助信息
uninstall   卸载工具

# 全局选项
-v, --verbose    显示详细输出
-q, --quiet      静默模式
--no-color       禁用颜色输出
```

### 2.2 核心库接口

#### `lib/core/constants.sh`

```bash
# 版本信息
readonly VERSION="1.0.0"
readonly SCRIPT_NAME="ops-toolkit"

# 安装路径
readonly INSTALL_DIR="${HOME}/.local/lib/ops-toolkit"
readonly BIN_DIR="${HOME}/.local/bin"
readonly LOG_DIR="${HOME}/.cache/ops-toolkit/logs"
readonly CONFIG_DIR="${HOME}/.config/ops-toolkit"

# 日志级别
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3

# 支持的操作系统
readonly SUPPORTED_OS=("macos" "ubuntu" "debian" "centos")
```

#### `lib/core/logging.sh`

```bash
# 描述: 初始化日志系统
# 参数:
#   $1 - 日志级别 (DEBUG|INFO|WARN|ERROR)
# 返回: 0
log_init() { ... }

# 描述: 输出 DEBUG 级别日志
# 参数: $* - 日志内容
log_debug() { ... }

# 描述: 输出 INFO 级别日志
# 参数: $* - 日志内容
log_info() { ... }

# 描述: 输出 WARN 级别日志
# 参数: $* - 日志内容
log_warn() { ... }

# 描述: 输出 ERROR 级别日志
# 参数: $* - 日志内容
log_error() { ... }

# 描述: 写入日志文件
# 参数: $* - 日志内容
log_to_file() { ... }
```

#### `lib/core/utils.sh`

```bash
# 描述: 检查命令是否存在
# 参数: $1 - 命令名称
# 返回: 0 存在, 1 不存在
command_exists() { ... }

# 描述: 安全创建目录
# 参数: $1 - 目录路径
# 返回: 0 成功, 1 失败
ensure_dir() { ... }

# 描述: 备份文件
# 参数:
#   $1 - 源文件路径
#   $2 - 备份目录 (可选)
# 返回: 备份文件路径
backup_file() { ... }

# 描述: 带超时执行命令
# 参数:
#   $1 - 超时秒数
#   $2 - 命令
# 返回: 命令退出码
run_with_timeout() { ... }

# 描述: 获取当前时间戳
# 返回: ISO 8601 格式时间戳
timestamp() { ... }
```

#### `lib/system/detect.sh`

```bash
# 描述: 检测操作系统类型
# 返回: macos|ubuntu|debian|centos|unknown
detect_os() { ... }

# 描述: 检测 CPU 架构
# 返回: x86_64|arm64|unknown
detect_arch() { ... }

# 描述: 检测包管理器
# 返回: brew|apt|dnf|yum|unknown
detect_package_manager() { ... }

# 描述: 获取系统完整信息
# 返回: JSON 格式系统信息
get_system_info() { ... }

# 描述: 检查系统是否支持
# 返回: 0 支持, 1 不支持
is_supported_os() { ... }
```

### 2.3 组件系统接口

#### `lib/component/registry.sh`

```bash
# 描述: 获取所有已注册组件
# 返回: 组件 ID 数组
get_all_components() { ... }

# 描述: 获取指定类别的组件
# 参数: $1 - 类别名称
# 返回: 组件 ID 数组
get_components_by_category() { ... }

# 描述: 获取组件元数据
# 参数: $1 - 组件 ID
# 返回: 组件信息 (名称、描述、依赖等)
get_component_meta() { ... }

# 描述: 获取所有类别
# 返回: 类别名称数组
get_categories() { ... }
```

#### `lib/component/detector.sh`

```bash
# 描述: 检测组件是否已安装
# 参数: $1 - 组件 ID
# 返回: 0 已安装, 1 未安装
is_component_installed() { ... }

# 描述: 批量检测组件状态
# 参数: $@ - 组件 ID 列表
# 返回: 关联数组 {component_id: status}
detect_components_status() { ... }
```

#### `lib/component/executor.sh`

```bash
# 描述: 执行单个组件
# 参数:
#   $1 - 组件 ID
#   $2 - 选项 (force: 强制重新安装)
# 返回: 0 成功, 1 失败, 2 跳过
execute_component() { ... }

# 描述: 批量执行组件
# 参数:
#   $1 - 组件 ID 数组
#   $2 - 选项
# 返回: 执行结果摘要
execute_components() { ... }
```

### 2.4 UI 接口

#### `lib/ui/output.sh`

```bash
# 描述: 打印标题
# 参数: $1 - 标题文本
print_title() { ... }

# 描述: 打印分隔线
# 参数: $1 - 字符 (可选, 默认 ─)
print_separator() { ... }

# 描述: 打印成功消息
# 参数: $1 - 消息
print_success() { ... }

# 描述: 打印错误消息
# 参数: $1 - 消息
print_error() { ... }

# 描述: 打印警告消息
# 参数: $1 - 消息
print_warning() { ... }

# 描述: 打印信息消息
# 参数: $1 - 消息
print_info() { ... }
```

#### `lib/ui/interactive.sh`

```bash
# 描述: 显示多选菜单
# 参数:
#   $1 - 标题
#   $2 - 选项数组 (格式: "id|name|status")
#   $3 - 默认选中项 (可选)
# 返回: 选中的 ID 数组
select_multiple() { ... }

# 描述: 显示确认提示
# 参数:
#   $1 - 提示信息
#   $2 - 默认值 (y/n)
# 返回: 0 确认, 1 取消
confirm() { ... }

# 描述: 显示输入提示
# 参数:
#   $1 - 提示信息
#   $2 - 默认值 (可选)
# 返回: 用户输入
prompt_input() { ... }
```

---

## 3. 组件接口规范

每个组件脚本必须实现以下接口：

### 3.1 必需函数

```bash
# 组件元数据 (必需)
# 必须定义以下变量
readonly COMPONENT_ID="git-config"
readonly COMPONENT_NAME="Git 配置"
readonly COMPONENT_DESC="配置 Git 用户信息和常用别名"
readonly COMPONENT_CATEGORY="shell-git"
readonly COMPONENT_DEPS=()  # 依赖的其他组件 ID

# 描述: 检测组件是否已安装
# 返回: 0 已安装, 1 未安装
component_detect() {
  # 实现检测逻辑
}

# 描述: 安装/配置组件
# 参数:
#   $1 - 选项 (可选: --force 强制重新安装)
# 返回: 0 成功, 1 失败
component_install() {
  # 实现安装逻辑
}
```

### 3.2 可选函数

```bash
# 描述: 卸载组件 (可选)
# 返回: 0 成功, 1 失败
component_uninstall() {
  # 实现卸载逻辑
}

# 描述: 获取组件状态详情 (可选)
# 返回: 状态描述文本
component_status() {
  # 返回详细状态信息
}

# 描述: 安装后提示 (可选)
# 返回: 提示文本数组
component_post_install_message() {
  echo "请运行 source ~/.zshrc 使配置生效"
}
```

### 3.3 组件模板

```bash
#!/usr/bin/env bash
#
# 组件: git-config
# 描述: 配置 Git 用户信息和常用别名
# 作者: ops-toolkit
# 日期: 2026-03-02
#

set -euo pipefail

# ============================================================================
# 组件元数据
# ============================================================================

readonly COMPONENT_ID="git-config"
readonly COMPONENT_NAME="Git 配置"
readonly COMPONENT_DESC="配置 Git 用户信息和常用别名"
readonly COMPONENT_CATEGORY="shell-git"
readonly COMPONENT_DEPS=()

# ============================================================================
# 组件接口实现
# ============================================================================

# 描述: 检测是否已配置
# 返回: 0 已配置, 1 未配置
component_detect() {
  local user_name
  user_name="$(git config --global user.name 2>/dev/null || echo "")"

  if [[ -n "${user_name}" ]]; then
    return 0
  fi
  return 1
}

# 描述: 执行配置
# 参数: $1 - 选项 (--force 强制重新配置)
# 返回: 0 成功, 1 失败
component_install() {
  local force="${1:-}"
  local user_name
  local user_email

  # 如果已配置且非强制模式，跳过
  if component_detect && [[ "${force}" != "--force" ]]; then
    log_info "Git 已配置，跳过"
    return 0
  fi

  # 交互式获取用户信息
  user_name="$(prompt_input "请输入 Git 用户名:")"
  user_email="$(prompt_input "请输入 Git 邮箱:")"

  # 配置 Git
  git config --global user.name "${user_name}"
  git config --global user.email "${user_email}"

  # 配置常用别名
  git config --global alias.co checkout
  git config --global alias.br branch
  git config --global alias.ci commit
  git config --global alias.st status

  log_info "Git 配置完成"
  return 0
}

# 描述: 获取状态详情
# 返回: 状态文本
component_status() {
  local user_name
  local user_email

  user_name="$(git config --global user.name 2>/dev/null || echo "未配置")"
  user_email="$(git config --global user.email 2>/dev/null || echo "未配置")"

  echo "用户名: ${user_name}"
  echo "邮箱: ${user_email}"
}
```

---

## 4. 类别元数据格式

每个类别目录下的 `_category.sh` 文件：

```bash
#!/usr/bin/env bash
#
# 类别: shell-git
# 描述: Shell 环境与 Git 配置
#

readonly CATEGORY_ID="shell-git"
readonly CATEGORY_NAME="Shell 与 Git"
readonly CATEGORY_DESC="Shell 环境配置和 Git 版本控制设置"
readonly CATEGORY_ORDER=1  # 显示顺序
```

---

## 5. 数据结构

### 5.1 组件注册信息

```bash
# 组件元数据结构
declare -A COMPONENT_META=(
  ["id"]="git-config"
  ["name"]="Git 配置"
  ["desc"]="配置 Git 用户信息和常用别名"
  ["category"]="shell-git"
  ["deps"]=""  # 逗号分隔的依赖 ID
  ["status"]="unknown"  # unknown|installed|not_installed
)
```

### 5.2 系统信息

```bash
# 系统信息结构
declare -A SYSTEM_INFO=(
  ["os"]="macos"
  ["os_version"]="14.3"
  ["arch"]="arm64"
  ["package_manager"]="brew"
  ["supported"]="true"
)
```

### 5.3 执行结果

```bash
# 执行结果结构
declare -A EXEC_RESULT=(
  ["component_id"]="git-config"
  ["status"]="success"  # success|skipped|failed
  ["message"]="配置完成"
  ["duration"]="1.2s"
)
```

---

## 6. 错误码定义

| 错误码 | 含义 |
|--------|------|
| 0 | 成功 |
| 1 | 通用错误 |
| 2 | 参数错误 |
| 10 | 不支持的操作系统 |
| 11 | 缺少依赖 |
| 20 | 组件检测失败 |
| 21 | 组件安装失败 |
| 22 | 组件依赖未满足 |
| 30 | 网络错误 |
| 31 | 权限错误 |

---

## 7. 配置文件格式

### 7.1 组件配置模板

`configs/git/gitconfig.template`:

```ini
# ops-toolkit managed - do not edit this line
[user]
    name = {{USER_NAME}}
    email = {{USER_EMAIL}}

[alias]
    co = checkout
    br = branch
    ci = commit
    st = status
    lg = log --oneline --graph --decorate

[core]
    editor = vim
    autocrlf = input

[push]
    default = simple
```

### 7.2 Shell 配置追加

`configs/zsh/zshrc.append`:

```bash
# ops-toolkit managed - start
# oh-my-zsh plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# 常用别名
alias ll='ls -la'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'
# ops-toolkit managed - end
```

---

## 8. 日志文件格式

日志文件位置: `~/.cache/ops-toolkit/logs/init-YYYYMMDD-HHMMSS.log`

```
[2026-03-02 14:30:15] [INFO]  ops-toolkit v1.0.0 starting
[2026-03-02 14:30:15] [INFO]  Detected system: macOS 14.3 (arm64)
[2026-03-02 14:30:16] [INFO]  Scanning installed components...
[2026-03-02 14:30:16] [DEBUG] component_detect: git-config -> installed
[2026-03-02 14:30:16] [DEBUG] component_detect: ssh-key -> not_installed
[2026-03-02 14:30:18] [INFO]  Executing component: ssh-key
[2026-03-02 14:30:20] [INFO]  SSH key generated: /Users/user/.ssh/id_ed25519
[2026-03-02 14:30:20] [INFO]  Execution completed: 2 installed, 1 skipped, 0 failed
```

---

*文档版本: 1.0.0-draft | 最后更新: 2026-03-02*
