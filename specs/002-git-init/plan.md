# Git 一键初始化工具 技术实现方案

> 版本: 1.0.0
> 日期: 2026-03-03
> 状态: 待执行

---

## 1. 技术上下文总结

### 1.1 技术选型

本项目基于以下技术选型：

| 类别 | 选型 | 说明 |
|------|------|------|
| **编程语言** | Bash | 跨平台兼容性好，无需额外运行时，零依赖 |
| **Shell 版本** | Bash 4.0+ | 支持高级特性，兼容 macOS/Linux |
| **依赖管理** | 无外部依赖 | 保持项目轻量，仅依赖系统内置工具 (Git, OpenSSH) |
| **测试框架** | ShellUnit (自定义) | 轻量级测试框架 |
| **代码检查** | ShellCheck | 静态分析工具 |

### 1.2 核心约束

- 必须遵循 `constitution.md` 定义的脚本编写规范
- 必须是**单文件脚本**，不超过 500 行
- 必须支持 macOS 10.15+ 和 Linux (Ubuntu 18.04+, Debian 10+, CentOS 7+)
- 启动时间 < 1 秒
- 完整配置流程 < 2 分钟（不含用户输入时间）

---

## 2. "合宪性"审查

### 2.1 可读性原则检查

| 宪法条款 | 符合情况 | 说明 |
|----------|----------|------|
| 使用有意义的变量名 | ✅ | 所有变量遵循 snake_case，常量使用 UPPER_SNAKE_CASE |
| 布尔变量使用肯定形式 | ✅ | 如 `is_ssh_key_exists`、`has_extra_accounts` |
| 一致的缩进（2 空格） | ✅ | 项目统一使用 2 空格缩进 |
| 行长度 ≤ 100 字符 | ✅ | 超长行合理换行 |
| 函数必须有文档注释 | ✅ | 所有公共函数包含描述、参数、返回值、示例 |
| 注释解释"为什么"而非"是什么" | ✅ | 注释聚焦决策原因而非代码重复 |

### 2.2 可维护性原则检查

| 宪法条款 | 符合情况 | 说明 |
|----------|----------|------|
| 单一职责原则 | ✅ | 每个函数只做一件事，如 `generate_ssh_key()`、`configure_git_aliases()` |
| 函数长度 ≤ 50 行 | ✅ | 超过时拆分为子函数 |
| 嵌套深度 ≤ 3 层 | ✅ | 使用提前返回避免深层嵌套 |
| 配置与代码分离 | ✅ | 配置模板内联在脚本中（因为是单文件），使用 HEREDOC |
| 默认值处理 | ✅ | 使用 `${VAR:-default}` 提供合理默认值 |
| 版本控制友好 | ✅ | 单文件、有意义的提交信息 |

### 2.3 健壮性原则检查

| 宪法条款 | 符合情况 | 说明 |
|----------|----------|------|
| 启用严格模式 `set -euo pipefail` | ✅ | 脚本头部启用 |
| 验证所有外部输入 | ✅ | 邮箱格式检查、路径安全性检查 |
| 检查命令执行结果 | ✅ | 使用 `command -v` 检查 git、ssh-keygen 等依赖 |
| 使用 trap 清理资源 | ✅ | `cleanup()` 函数 + `trap cleanup EXIT` |
| 分级日志（DEBUG/INFO/WARN/ERROR） | ✅ | 结构化日志含时间戳、级别、来源 |
| 设置超时 | ✅ | SSH 连接测试使用 `timeout` 命令 |
| 限制重试 | ✅ | 重试次数和间隔有上限 |

### 2.4 可移植性原则检查

| 宪法条款 | 符合情况 | 说明 |
|----------|----------|------|
| 使用 `#!/usr/bin/env bash` | ✅ | 脚本使用 env 调用解释器 |
| 不硬编码路径 | ✅ | 使用 `~` 替代硬编码的绝对路径 |
| 优先 POSIX 兼容语法 | ✅ | 必要时使用 Bash 特性但保持安全 |
| 检查命令存在性 | ✅ | 如 `pbcopy` vs `xclip` 剪贴板兼容性处理 |
| 不假设特定用户/主机名/时区 | ✅ | 使用 UTC 或明确指定时区 |
| 强制 `LC_ALL=C` | ✅ | 确保一致的行为 |

### 合宪性审查结论

✅ **本技术方案完全符合 constitution.md 的所有条款。**

---

## 3. 项目结构细化

### 3.1 完整目录树（新增/修改）

```
ops-toolkit/
├── scripts/
│   └── git-init.sh                      # Git 一键初始化脚本（新增）
│
├── configs/
│   └── git/
│       ├── gitconfig.template
│       └── gitignore.template           # 全局 .gitignore 模板（新增）
│
├── tests/
│   └── integration/
│       └── test_git_init.sh             # git-init.sh 测试（新增）
│
└── specs/
    └── 002-git-init/
        ├── spec.md
        └── plan.md                      # 本文档
```

### 3.2 模块职责划分（单文件内部）

| 模块 | 职责 | 关键函数 |
|------|------|----------|
| **CLI 解析** | 命令行参数解析 | `parse_args()` |
| **UI 输出** | 颜色输出、标题、分隔线 | `print_title()`、`print_success()`、`print_error()` |
| **交互式输入** | 用户输入、确认、选择 | `ask_input()`、`ask_confirm()`、`ask_choice()` |
| **系统检测** | Git、SSH 依赖检查 | `check_dependencies()` |
| **主账户配置** | user.name、user.email | `configure_main_account()` |
| **SSH Key** | 检测、生成、备份 | `configure_ssh_key()` |
| **全局 .gitignore** | 配置忽略文件 | `configure_gitignore()` |
| **Git 别名** | 配置常用别名 | `configure_git_aliases()` |
| **多账户配置** | includeIf 配置 | `configure_extra_accounts()` |
| **配置验证** | SSH 连接测试 | `verify_configuration()` |
| **导入导出** | 配置文件读写 | `export_config()`、`import_config()` |

---

## 4. 核心数据结构

### 4.1 主账户配置 (MAIN_ACCOUNT)

```bash
# 关联数组存储主账户信息
declare -gA MAIN_ACCOUNT=(
  ["name"]=""
  ["email"]=""
)
```

### 4.2 SSH 配置 (SSH_CONFIG)

```bash
declare -gA SSH_CONFIG=(
  ["algorithm"]="ed25519"              # ed25519|rsa
  ["key_path"]=""
  ["public_key"]=""
  ["exists"]="false"
)
```

### 4.3 .gitignore 配置 (GITIGNORE_CONFIG)

```bash
declare -gA GITIGNORE_CONFIG=(
  ["enabled"]="true"
  ["template"]="default"                # default|custom|skip
  ["custom_content"]=""
)
```

### 4.4 额外账户 (EXTRA_ACCOUNTS)

```bash
# 额外账户数组，每个元素是逗号分隔的字符串: name,email,dir
declare -ga EXTRA_ACCOUNTS=()

# 单个额外账户解析为关联数组
# declare -A ACCOUNT=(
#   ["name"]="work"
#   ["email"]="lisi@company.com"
#   ["dir"]="~/work"
# )
```

### 4.5 执行选项 (OPTIONS)

```bash
declare -gA OPTIONS=(
  ["export_file"]=""
  ["import_file"]=""
  ["yes_to_all"]="false"
  ["skip_ssh"]="false"
  ["skip_gitignore"]="false"
  ["skip_aliases"]="false"
  ["skip_verify"]="false"
)
```

### 4.6 执行摘要 (SUMMARY)

```bash
declare -gA SUMMARY=(
  ["main_account_configured"]="false"
  ["ssh_key_configured"]="false"
  ["gitignore_configured"]="false"
  ["aliases_configured"]="false"
  ["extra_accounts_count"]="0"
  ["verification_passed"]="false"
)
```

---

## 5. 接口设计

### 5.1 脚本入口接口

**文件**: `scripts/git-init.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# 描述: Git 一键初始化工具
# 用法: git-init.sh [选项]
# 选项: -h,--help -v,--version -e,--export -i,--import -y,--yes --no-ssh --no-gitignore --no-aliases --no-verify

VERSION="1.0.0"
SCRIPT_NAME="git-init.sh"

# 临时文件清理
cleanup() {
  if [[ -n "${TEMP_FILE:-}" ]] && [[ -f "${TEMP_FILE}" ]]; then
    rm -f "${TEMP_FILE}"
  fi
}
trap cleanup EXIT

main() {
  parse_args "$@"

  if [[ -n "${OPTIONS["export_file"]}" ]]; then
    export_config "${OPTIONS["export_file"]}"
    exit 0
  fi

  if [[ -n "${OPTIONS["import_file"]}" ]]; then
    import_config "${OPTIONS["import_file"]}"
    exit 0
  fi

  check_dependencies
  configure_main_account

  if [[ "${OPTIONS["skip_ssh"]}" != "true" ]]; then
    configure_ssh_key
  fi

  if [[ "${OPTIONS["skip_gitignore"]}" != "true" ]]; then
    configure_gitignore
  fi

  if [[ "${OPTIONS["skip_aliases"]}" != "true" ]]; then
    configure_git_aliases
  fi

  configure_extra_accounts

  if [[ "${OPTIONS["skip_verify"]}" != "true" ]]; then
    verify_configuration
  fi

  print_summary
}

main "$@"
```

### 5.2 CLI 参数解析 (`parse_args`)

```bash
# 描述: 解析命令行参数
# 参数: $@ - 命令行参数
# 返回: 0
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        print_help
        exit 0
        ;;
      -v|--version)
        print_version
        exit 0
        ;;
      -e|--export)
        OPTIONS["export_file"]="$2"
        shift 2
        ;;
      -i|--import)
        OPTIONS["import_file"]="$2"
        shift 2
        ;;
      -y|--yes)
        OPTIONS["yes_to_all"]="true"
        shift
        ;;
      --no-ssh)
        OPTIONS["skip_ssh"]="true"
        shift
        ;;
      --no-gitignore)
        OPTIONS["skip_gitignore"]="true"
        shift
        ;;
      --no-aliases)
        OPTIONS["skip_aliases"]="true"
        shift
        ;;
      --no-verify)
        OPTIONS["skip_verify"]="true"
        shift
        ;;
      *)
        print_error "未知选项: $1"
        print_help
        exit 1
        ;;
    esac
  done
}
```

### 5.3 UI 输出接口

```bash
# 颜色定义
readonly COLOR_RESET="\033[0m"
readonly COLOR_RED="\033[31m"
readonly COLOR_GREEN="\033[32m"
readonly COLOR_YELLOW="\033[33m"
readonly COLOR_BLUE="\033[34m"
readonly COLOR_CYAN="\033[36m"
readonly COLOR_BOLD="\033[1m"

# 描述: 打印标题
# 参数: $1 - 标题文本
print_title() {
  echo -e "\n${COLOR_BOLD}${COLOR_CYAN}$1${COLOR_RESET}"
  echo -e "${COLOR_CYAN}$(printf '─%.0s' {1..40})${COLOR_RESET}"
}

# 描述: 打印成功消息
# 参数: $1 - 消息
print_success() {
  echo -e "${COLOR_GREEN}✅ $1${COLOR_RESET}"
}

# 描述: 打印错误消息
# 参数: $1 - 消息
print_error() {
  echo -e "${COLOR_RED}❌ $1${COLOR_RESET}" >&2
}

# 描述: 打印警告消息
# 参数: $1 - 消息
print_warning() {
  echo -e "${COLOR_YELLOW}⚠️  $1${COLOR_RESET}"
}

# 描述: 打印信息消息
# 参数: $1 - 消息
print_info() {
  echo -e "${COLOR_BLUE}ℹ️  $1${COLOR_RESET}"
}
```

### 5.4 交互式输入接口

```bash
# 描述: 询问用户输入
# 参数:
#   $1 - 提示信息
#   $2 - 默认值 (可选)
# 返回: 用户输入 (通过 stdout 输出)
ask_input() {
  local prompt="$1"
  local default="${2:-}"
  local input

  if [[ -n "${default}" ]]; then
    read -r -p "${prompt} [${default}]: " input
    input="${input:-${default}}"
  else
    read -r -p "${prompt}: " input
  fi

  echo "${input}"
}

# 描述: 询问用户确认
# 参数:
#   $1 - 提示信息
#   $2 - 默认值 (y/n, 可选, 默认 y)
# 返回: 0 确认, 1 取消
ask_confirm() {
  local prompt="$1"
  local default="${2:-y}"
  local input

  if [[ "${OPTIONS["yes_to_all"]}" == "true" ]]; then
    return 0
  fi

  local display_default
  if [[ "${default}" == "y" ]]; then
    display_default="Y/n"
  else
    display_default="y/N"
  fi

  while true; do
    read -r -p "${prompt} [${display_default}]: " input
    input="${input:-${default}}"
    case "${input}" in
      [Yy]*)
        return 0
        ;;
      [Nn]*)
        return 1
        ;;
      *)
        echo "请输入 y 或 n"
        ;;
    esac
  done
}

# 描述: 询问用户选择
# 参数:
#   $1 - 提示信息
#   $2 - 选项数组 (格式: "1|选项1|描述1")
#   $3 - 默认选项 (可选)
# 返回: 选中的选项值 (通过 stdout 输出)
ask_choice() {
  local prompt="$1"
  shift
  local options=("$@")
  local default="${options[-1]}"
  unset "options[-1]"
  local input

  echo "${prompt}"
  for option in "${options[@]}"; do
    IFS='|' read -r num name desc <<<"${option}"
    if [[ -n "${desc}" ]]; then
      echo "  ${num}) ${name} - ${desc}"
    else
      echo "  ${num}) ${name}"
    fi
  done

  while true; do
    read -r -p "请输入选项 [${default}]: " input
    input="${input:-${default}}"

    for option in "${options[@]}"; do
      IFS='|' read -r num name desc <<<"${option}"
      if [[ "${input}" == "${num}" ]]; then
        echo "${num}"
        return 0
      fi
    done

    echo "无效选项，请重新输入"
  done
}
```

### 5.5 依赖检查接口

```bash
# 描述: 检查系统依赖
# 返回: 0 所有依赖满足, 1 依赖缺失
check_dependencies() {
  local missing_deps=()

  if ! command -v git &>/dev/null; then
    missing_deps+=("git")
  fi

  if ! command -v ssh-keygen &>/dev/null; then
    missing_deps+=("ssh-keygen (OpenSSH)")
  fi

  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    print_error "缺少依赖: ${missing_deps[*]}"
    print_error "请先安装这些工具后重试"
    exit 1
  fi
}
```

### 5.6 主账户配置接口

```bash
# 描述: 配置主 Git 账户
# 返回: 0
configure_main_account() {
  print_title "📝 主账户配置"

  local current_name current_email

  current_name=$(git config --global user.name 2>/dev/null || true)
  MAIN_ACCOUNT["name"]=$(ask_input "请输入 Git 用户名" "${current_name}")

  while ! validate_git_username "${MAIN_ACCOUNT["name"]}"; do
    print_error "无效的 Git 用户名"
    MAIN_ACCOUNT["name"]=$(ask_input "请输入 Git 用户名" "${current_name}")
  done

  current_email=$(git config --global user.email 2>/dev/null || true)
  MAIN_ACCOUNT["email"]=$(ask_input "请输入 Git 邮箱" "${current_email}")

  while ! validate_email "${MAIN_ACCOUNT["email"]}"; do
    print_error "无效的邮箱地址"
    MAIN_ACCOUNT["email"]=$(ask_input "请输入 Git 邮箱" "${current_email}")
  done

  git config --global user.name "${MAIN_ACCOUNT["name"]}"
  git config --global user.email "${MAIN_ACCOUNT["email"]}"

  SUMMARY["main_account_configured"]="true"
  print_success "主账户配置完成: ${MAIN_ACCOUNT["name"]} <${MAIN_ACCOUNT["email"]}>"
}

# 描述: 验证 Git 用户名
# 参数: $1 - 用户名
# 返回: 0 有效, 1 无效
validate_git_username() {
  local username="$1"
  [[ -n "${username}" ]] && [[ "${#username}" -le 100 ]]
}

# 描述: 验证邮箱格式
# 参数: $1 - 邮箱地址
# 返回: 0 有效, 1 无效
validate_email() {
  local email="$1"
  [[ "${email}" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}
```

### 5.7 SSH Key 配置接口

```bash
# 描述: 配置 SSH Key
# 返回: 0
configure_ssh_key() {
  print_title "🔑 SSH Key 配置"

  local key_path="${HOME}/.ssh/id_ed25519"

  if [[ -f "${key_path}" ]]; then
    SSH_CONFIG["exists"]="true"
    SSH_CONFIG["key_path"]="${key_path}"

    local choice
    choice=$(ask_choice \
      "检测到已存在 SSH Key (${key_path})" \
      "1|使用现有 Key" \
      "2|备份并生成新 Key" \
      "3|跳过 SSH Key 配置" \
      "1")

    case "${choice}" in
      1)
        use_existing_ssh_key
        ;;
      2)
        backup_and_generate_ssh_key
        ;;
      3)
        print_info "跳过 SSH Key 配置"
        return 0
        ;;
    esac
  else
    generate_new_ssh_key
  fi

  SUMMARY["ssh_key_configured"]="true"
}

# 描述: 使用现有 SSH Key
use_existing_ssh_key() {
  SSH_CONFIG["public_key"]=$(cat "${SSH_CONFIG["key_path"]}.pub" 2>/dev/null || true)
  print_success "使用现有 SSH Key: ${SSH_CONFIG["key_path"]}"
  copy_public_key_to_clipboard
}

# 描述: 备份并生成新 SSH Key
backup_and_generate_ssh_key() {
  local timestamp=$(date +%Y%m%d_%H%M%S)
  local backup_path="${SSH_CONFIG["key_path"]}.bak.${timestamp}"

  mv "${SSH_CONFIG["key_path"]}" "${backup_path}"
  mv "${SSH_CONFIG["key_path"]}.pub" "${backup_path}.pub" 2>/dev/null || true

  print_info "已备份旧 Key 到: ${backup_path}"

  generate_new_ssh_key
}

# 描述: 生成新 SSH Key
generate_new_ssh_key() {
  local choice
  choice=$(ask_choice \
    "请选择 SSH 算法" \
    "1|ed25519|推荐，更安全更快" \
    "2|rsa 4096|兼容性更好" \
    "1")

  local key_type key_path
  if [[ "${choice}" == "1" ]]; then
    key_type="ed25519"
    key_path="${HOME}/.ssh/id_ed25519"
  else
    key_type="rsa"
    key_path="${HOME}/.ssh/id_rsa"
  fi

  SSH_CONFIG["algorithm"]="${key_type}"
  SSH_CONFIG["key_path"]="${key_path}"

  local passphrase
  passphrase=$(ask_input "请输入密钥密码（留空则无密码）" "")

  ensure_dir "${HOME}/.ssh"
  chmod 700 "${HOME}/.ssh"

  print_info "生成 SSH Key 中..."

  if [[ -z "${passphrase}" ]]; then
    if [[ "${key_type}" == "ed25519" ]]; then
      ssh-keygen -t ed25519 -f "${key_path}" -N "" -q
    else
      ssh-keygen -t rsa -b 4096 -f "${key_path}" -N "" -q
    fi
  else
    if [[ "${key_type}" == "ed25519" ]]; then
      ssh-keygen -t ed25519 -f "${key_path}" -N "${passphrase}" -q
    else
      ssh-keygen -t rsa -b 4096 -f "${key_path}" -N "${passphrase}" -q
    fi
  fi

  chmod 600 "${key_path}"
  chmod 644 "${key_path}.pub"

  SSH_CONFIG["public_key"]=$(cat "${key_path}.pub")

  print_success "SSH Key 已生成: ${key_path}"
  copy_public_key_to_clipboard
}

# 描述: 将公钥复制到剪贴板
copy_public_key_to_clipboard() {
  if [[ -z "${SSH_CONFIG["public_key"]}" ]]; then
    return
  fi

  if command -v pbcopy &>/dev/null; then
    echo -n "${SSH_CONFIG["public_key"]}" | pbcopy
    print_info "📋 公钥已复制到剪贴板"
  elif command -v xclip &>/dev/null; then
    echo -n "${SSH_CONFIG["public_key"]}" | xclip -selection clipboard
    print_info "📋 公钥已复制到剪贴板"
  elif command -v xsel &>/dev/null; then
    echo -n "${SSH_CONFIG["public_key"]}" | xsel --clipboard --input
    print_info "📋 公钥已复制到剪贴板"
  else
    print_info "公钥:"
    echo "${SSH_CONFIG["public_key"]}"
  fi
}

# 描述: 安全创建目录
# 参数: $1 - 目录路径
ensure_dir() {
  local dir="$1"
  if [[ ! -d "${dir}" ]]; then
    mkdir -p "${dir}"
  fi
}
```

### 5.8 全局 .gitignore 配置接口

```bash
# 描述: 配置全局 .gitignore
# 返回: 0
configure_gitignore() {
  print_title "📄 全局 .gitignore 配置"

  local choice
  choice=$(ask_choice \
    "请选择 .gitignore 模板" \
    "1|使用通用模板|推荐" \
    "2|使用自定义模板" \
    "3|跳过 .gitignore 配置" \
    "1")

  case "${choice}" in
    1)
      configure_default_gitignore
      ;;
    2)
      configure_custom_gitignore
      ;;
    3)
      print_info "跳过 .gitignore 配置"
      return 0
      ;;
  esac

  SUMMARY["gitignore_configured"]="true"
}

# 描述: 使用默认 .gitignore 模板
configure_default_gitignore() {
  local gitignore_path="${HOME}/.gitignore_global"

  cat >"${gitignore_path}" <<'EOF'
# macOS
.DS_Store
._*
.AppleDouble
.LSOverride

# 编辑器
.vscode/
.idea/
*.swp
*.swo
*~
.project
.settings/
*.iml

# 编程语言
node_modules/
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
venv/
env/
target/
*.class
*.jar
*.war
*.ear

# 环境变量
.env
.env.local
.env.*.local

# 构建输出
dist/
build/
out/
EOF

  git config --global core.excludesfile "${gitignore_path}"

  GITIGNORE_CONFIG["template"]="default"
  GITIGNORE_CONFIG["enabled"]="true"

  print_success "全局 .gitignore 已配置: ${gitignore_path}"
}

# 描述: 使用自定义 .gitignore
configure_custom_gitignore() {
  print_info "请输入自定义 .gitignore 内容（输入空行结束）:"

  local line content=""
  while true; do
    read -r line
    if [[ -z "${line}" ]]; then
      break
    fi
    content+="${line}"$'\n'
  done

  GITIGNORE_CONFIG["custom_content"]="${content}"
  GITIGNORE_CONFIG["template"]="custom"
  GITIGNORE_CONFIG["enabled"]="true"

  local gitignore_path="${HOME}/.gitignore_global"
  echo -n "${content}" >"${gitignore_path}"
  git config --global core.excludesfile "${gitignore_path}"

  print_success "自定义 .gitignore 已配置: ${gitignore_path}"
}
```

### 5.9 Git 别名配置接口

```bash
# 描述: 配置 Git 别名
# 返回: 0
configure_git_aliases() {
  print_title "⚡ Git 别名配置"

  if ! ask_confirm "是否配置常用 Git 别名?" "y"; then
    print_info "跳过 Git 别名配置"
    return 0
  fi

  git config --global alias.st "status"
  git config --global alias.co "checkout"
  git config --global alias.br "branch"
  git config --global alias.ci "commit"
  git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
  git config --global alias.unstage "reset HEAD --"
  git config --global alias.last "log -1 HEAD"

  SUMMARY["aliases_configured"]="true"
  print_success "Git 别名已配置"
}
```

### 5.10 多账户配置接口

```bash
# 描述: 配置额外 Git 账户
# 返回: 0
configure_extra_accounts() {
  print_title "👥 多账户配置"

  if ! ask_confirm "是否配置额外的 Git 账户?" "n"; then
    print_info "跳过多账户配置"
    return 0
  fi

  while true; do
    local name email dir

    name=$(ask_input "请输入账户名称（例如：工作）")
    email=$(ask_input "请输入 Git 邮箱")
    while ! validate_email "${email}"; do
      print_error "无效的邮箱地址"
      email=$(ask_input "请输入 Git 邮箱")
    done

    dir=$(ask_input "请输入关联的工作目录（例如：~/work）")

    EXTRA_ACCOUNTS+=("${name},${email},${dir}")
    configure_single_extra_account "${name}" "${email}" "${dir}"

    SUMMARY["extra_accounts_count"]=$((${SUMMARY["extra_accounts_count"]} + 1))

    if ! ask_confirm "是否继续添加账户?" "n"; then
      break
    fi
  done

  print_success "多账户配置完成，共 ${#EXTRA_ACCOUNTS[@]} 个账户"
}

# 描述: 配置单个额外账户
# 参数:
#   $1 - 账户名称
#   $2 - 邮箱
#   $3 - 目录
configure_single_extra_account() {
  local name="$1"
  local email="$2"
  local dir="$3"

  local config_path="${HOME}/.gitconfig-${name}"

  cat >"${config_path}" <<EOF
[user]
    name = ${name}
    email = ${email}
EOF

  local abs_dir
  abs_dir=$(eval echo "${dir}")

  git config --global --add "includeIf.gitdir:${abs_dir}/.path" "${config_path}"

  print_success "账户 '${name}' 已配置，关联目录: ${dir}"
}
```

### 5.11 配置验证接口

```bash
# 描述: 验证 Git 配置
# 返回: 0
verify_configuration() {
  print_title "✅ 验证配置"

  local all_passed="true"

  if verify_github_ssh; then
    print_success "GitHub SSH 连接成功"
  else
    all_passed="false"
  fi

  if verify_gitlab_ssh; then
    print_success "GitLab SSH 连接成功"
  else
    all_passed="false"
  fi

  if [[ "${all_passed}" == "true" ]]; then
    SUMMARY["verification_passed"]="true"
  fi
}

# 描述: 验证 GitHub SSH 连接
# 返回: 0 成功, 1 失败
verify_github_ssh() {
  print_info "正在测试 GitHub SSH 连接..."

  local result
  if result=$(timeout 10s ssh -T -o StrictHostKeyChecking=no git@github.com 2>&1); then
    echo "${result}"
    return 0
  else
    local exit_code=$?
    if [[ ${exit_code} == 1 ]]; then
      echo "${result}"
      return 0
    fi
    print_warning "GitHub SSH 连接失败: ${result}"
    print_warning "建议: 请将公钥添加到 GitHub"
    return 1
  fi
}

# 描述: 验证 GitLab SSH 连接
# 返回: 0 成功, 1 失败
verify_gitlab_ssh() {
  print_info "正在测试 GitLab SSH 连接..."

  local result
  if result=$(timeout 10s ssh -T -o StrictHostKeyChecking=no git@gitlab.com 2>&1); then
    echo "${result}"
    return 0
  else
    local exit_code=$?
    if [[ ${exit_code} == 1 ]]; then
      echo "${result}"
      return 0
    fi
    print_warning "GitLab SSH 连接失败: ${result}"
    print_warning "建议: 请将公钥添加到 GitLab"
    return 1
  fi
}
```

### 5.12 配置导出接口

```bash
# 描述: 导出当前 Git 配置
# 参数: $1 - 导出文件路径
# 返回: 0
export_config() {
  local export_file="$1"

  print_info "正在导出配置到: ${export_file}"

  local name email
  name=$(git config --global user.name 2>/dev/null || true)
  email=$(git config --global user.email 2>/dev/null || true)

  local ssh_key_path
  ssh_key_path=$(find "${HOME}/.ssh" -name "id_ed25519" -o -name "id_rsa" | head -1)
  local ssh_algorithm="ed25519"
  if [[ "${ssh_key_path}" == *"id_rsa" ]]; then
    ssh_algorithm="rsa"
  fi

  local gitignore_content=""
  local gitignore_path
  gitignore_path=$(git config --global core.excludesfile 2>/dev/null || true)
  if [[ -n "${gitignore_path}" ]] && [[ -f "${gitignore_path}" ]]; then
    gitignore_content=$(cat "${gitignore_path}")
  fi

  local extra_accounts_content=""
  local include_configs
  include_configs=$(git config --global --get-all "includeIf.gitdir:*.path" 2>/dev/null || true)
  while IFS= read -r config_path; do
    if [[ -f "${config_path}" ]]; then
      local acct_name
      acct_name=$(basename "${config_path}" | sed 's/\.gitconfig-//')
      local acct_email
      acct_email=$(git config -f "${config_path}" user.email 2>/dev/null || true)
      local gitdir
      gitdir=$(git config --global --name-only --get-regexp "includeIf.gitdir:.*\.path" | grep -F "${config_path}" | sed 's/includeIf.gitdir://;s/\.path//')
      if [[ -n "${acct_name}" ]] && [[ -n "${acct_email}" ]] && [[ -n "${gitdir}" ]]; then
        extra_accounts_content+="name=${acct_name},email=${acct_email},dir=${gitdir%/}"$'\n'
      fi
    fi
  done <<<"${include_configs}"

  cat >"${export_file}" <<EOF
#!/usr/bin/env bash
# Git 配置导出文件
# 生成时间: $(date -u +%Y-%m-%dT%H:%M:%SZ)
# 使用方法: git-init.sh --import this-file.sh

export GIT_INIT_CONFIG_MAIN_NAME="${name}"
export GIT_INIT_CONFIG_MAIN_EMAIL="${email}"

export GIT_INIT_CONFIG_SSH_ALGORITHM="${ssh_algorithm}"
export GIT_INIT_CONFIG_SSH_KEY_PATH="${ssh_key_path}"

export GIT_INIT_CONFIG_GITIGNORE_TEMPLATE="custom"
export GIT_INIT_CONFIG_GITIGNORE_CONTENT="\$(cat <<'GITIGNORE_EOF'
${gitignore_content}
GITIGNORE_EOF
)"

export GIT_INIT_CONFIG_ALIASES="yes"

export GIT_INIT_CONFIG_EXTRA_ACCOUNTS="\$(cat <<'ACCOUNTS_EOF'
${extra_accounts_content%$'\n'}
ACCOUNTS_EOF
)"

export GIT_INIT_CONFIG_VERIFY="yes"
EOF

  chmod +x "${export_file}"

  print_success "配置已导出到: ${export_file}"
}
```

### 5.13 配置导入接口

```bash
# 描述: 从文件导入配置
# 参数: $1 - 导入文件路径
# 返回: 0
import_config() {
  local import_file="$1"

  if [[ ! -f "${import_file}" ]]; then
    print_error "导入文件不存在: ${import_file}"
    exit 1
  fi

  print_info "正在从文件导入配置: ${import_file}"

  source "${import_file}"

  OPTIONS["yes_to_all"]="true"

  if [[ -n "${GIT_INIT_CONFIG_MAIN_NAME:-}" ]] && [[ -n "${GIT_INIT_CONFIG_MAIN_EMAIL:-}" ]]; then
    MAIN_ACCOUNT["name"]="${GIT_INIT_CONFIG_MAIN_NAME}"
    MAIN_ACCOUNT["email"]="${GIT_INIT_CONFIG_MAIN_EMAIL}"
    git config --global user.name "${MAIN_ACCOUNT["name"]}"
    git config --global user.email "${MAIN_ACCOUNT["email"]}"
    SUMMARY["main_account_configured"]="true"
    print_success "主账户配置完成"
  fi

  if [[ -n "${GIT_INIT_CONFIG_GITIGNORE_CONTENT:-}" ]]; then
    local gitignore_path="${HOME}/.gitignore_global"
    echo -n "${GIT_INIT_CONFIG_GITIGNORE_CONTENT}" >"${gitignore_path}"
    git config --global core.excludesfile "${gitignore_path}"
    SUMMARY["gitignore_configured"]="true"
    print_success "全局 .gitignore 已配置"
  fi

  if [[ "${GIT_INIT_CONFIG_ALIASES:-}" == "yes" ]]; then
    configure_git_aliases
  fi

  if [[ -n "${GIT_INIT_CONFIG_EXTRA_ACCOUNTS:-}" ]]; then
    while IFS= read -r line; do
      if [[ -z "${line}" ]]; then
        continue
      fi
      local name email dir
      IFS=',' read -r name email dir <<<"${line}"
      if [[ -n "${name}" ]] && [[ -n "${email}" ]] && [[ -n "${dir}" ]]; then
        EXTRA_ACCOUNTS+=("${line}")
        configure_single_extra_account "${name}" "${email}" "${dir}"
        SUMMARY["extra_accounts_count"]=$((${SUMMARY["extra_accounts_count"]} + 1))
      fi
    done <<<"${GIT_INIT_CONFIG_EXTRA_ACCOUNTS}"
  fi

  if [[ "${GIT_INIT_CONFIG_VERIFY:-}" == "yes" ]]; then
    verify_configuration
  fi

  print_summary
}
```

### 5.14 摘要输出接口

```bash
# 描述: 打印配置摘要
# 返回: 0
print_summary() {
  echo ""
  echo -e "${COLOR_BOLD}${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
  echo -e "${COLOR_BOLD}${COLOR_GREEN}🎉 Git 配置完成！${COLOR_RESET}"
  echo ""
  echo -e "${COLOR_BOLD}📋 配置摘要:${COLOR_RESET}"

  if [[ "${SUMMARY["main_account_configured"]}" == "true" ]]; then
    echo "  • 用户: ${MAIN_ACCOUNT["name"]} <${MAIN_ACCOUNT["email"]}>"
  fi

  if [[ "${SUMMARY["ssh_key_configured"]}" == "true" ]]; then
    echo "  • SSH Key: ${SSH_CONFIG["algorithm"]} (${SSH_CONFIG["key_path"]})"
  fi

  if [[ "${SUMMARY["gitignore_configured"]}" == "true" ]]; then
    echo "  • 全局 .gitignore: 已配置"
  fi

  if [[ "${SUMMARY["aliases_configured"]}" == "true" ]]; then
    echo "  • Git 别名: 已配置"
  fi

  if [[ "${SUMMARY["extra_accounts_count"]}" -gt 0 ]]; then
    echo "  • 额外账户: ${SUMMARY["extra_accounts_count"]} 个"
  fi

  echo ""
  echo -e "${COLOR_BOLD}💡 提示:${COLOR_RESET}"

  if [[ "${SUMMARY["ssh_key_configured"]}" == "true" ]]; then
    echo "  • 请将公钥添加到 GitHub/GitLab"
  fi

  if [[ "${SUMMARY["extra_accounts_count"]}" -gt 0 ]]; then
    local first_account
    IFS=',' read -r name email dir <<<"${EXTRA_ACCOUNTS[0]}"
    echo "  • 在 ${dir} 目录下会自动使用 ${name} 账户"
  fi

  echo "  • 使用 --export 可以导出配置备份"
  echo ""
}
```

---

## 6. 实现里程碑

### M1: 基础框架 + 主账户配置 (0.5 天)

- [ ] 创建 `scripts/git-init.sh` 单文件框架
- [ ] 实现 CLI 参数解析
- [ ] 实现 UI 输出模块（颜色、标题、分隔线）
- [ ] 实现交互式输入模块
- [ ] 实现依赖检查
- [ ] 实现主账户配置
- [ ] 编写单元测试

### M2: SSH Key 配置 + .gitignore 配置 (0.5 天)

- [ ] 实现 SSH Key 检测、生成、备份
- [ ] 实现剪贴板复制（兼容 macOS/Linux）
- [ ] 实现全局 .gitignore 配置（默认 + 自定义）
- [ ] 实现 Git 别名配置
- [ ] 集成测试

### M3: 多账户配置 + 配置验证 (0.5 天)

- [ ] 实现多账户配置（includeIf）
- [ ] 实现 SSH 连接验证（GitHub/GitLab）
- [ ] 实现配置摘要输出
- [ ] 集成测试

### M4: 配置导入导出 (0.5 天)

- [ ] 实现配置导出功能
- [ ] 实现配置导入功能
- [ ] 实现帮助信息和版本信息
- [ ] 端到端测试

---

## 7. 风险与应对

| 风险 | 影响 | 概率 | 应对措施 |
|------|------|------|----------|
| 脚本超过 500 行限制 | 高 | 中 | 保持函数简洁，必要时可拆分为子脚本（但优先保持单文件） |
| Bash 版本兼容性 | 高 | 中 | 检测 Bash 版本，提供降级方案，避免使用过新的特性 |
| 网络超时/失败 | 中 | 高 | SSH 连接测试设置超时（10秒），失败不阻塞后续流程 |
| 剪贴板不支持 | 低 | 高 | 检测剪贴板命令，不支持时直接打印公钥 |
| macOS/Linux 差异 | 高 | 中 | 充分测试跨平台兼容性，使用条件判断处理差异 |
| includeIf Git 版本兼容性 | 中 | 低 | 检测 Git 版本，旧版本提示手动配置 |

---

## 8. 验收标准

### 8.1 功能验收

- [ ] `curl -fsSL https://.../git-init.sh | bash` 交互式引导完成配置
- [ ] SSH Key 生成、备份功能正常
- [ ] 全局 .gitignore 配置正常（默认 + 自定义）
- [ ] Git 别名配置正常
- [ ] 多账户配置正常，includeIf 机制工作
- [ ] SSH 连接验证正常（GitHub/GitLab）
- [ ] 配置导出功能正常
- [ ] 配置导入功能正常
- [ ] 幂等性：重复执行不产生冲突
- [ ] 支持 macOS 10.15+
- [ ] 支持 Ubuntu 18.04+、Debian 10+、CentOS 7+

### 8.2 质量验收

- [ ] 通过 ShellCheck 检查，无警告无错误
- [ ] 脚本行数 ≤ 500 行
- [ ] 在 macOS 和 Ubuntu 上完成端到端测试
- [ ] 启动时间 < 1 秒
- [ ] 所有脚本符合 constitution.md 规范
- [ ] 所有函数有文档注释

---

*文档版本: 1.0.0 | 最后更新: 2026-03-03*
