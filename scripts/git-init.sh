#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

VERSION="1.0.0"
SCRIPT_NAME="git-init.sh"

readonly COLOR_RESET="\033[0m"
readonly COLOR_RED="\033[31m"
readonly COLOR_GREEN="\033[32m"
readonly COLOR_YELLOW="\033[33m"
readonly COLOR_BLUE="\033[34m"
readonly COLOR_CYAN="\033[36m"
readonly COLOR_BOLD="\033[1m"

MAIN_ACCOUNT_NAME=""
MAIN_ACCOUNT_EMAIL=""

SSH_CONFIG_ALGORITHM="ed25519"
SSH_CONFIG_KEY_PATH=""
SSH_CONFIG_PUBLIC_KEY=""
SSH_CONFIG_EXISTS="false"

GITIGNORE_CONFIG_ENABLED="true"
GITIGNORE_CONFIG_TEMPLATE="default"
GITIGNORE_CONFIG_CUSTOM_CONTENT=""

EXTRA_ACCOUNTS=()

OPTION_EXPORT_FILE=""
OPTION_IMPORT_FILE=""
OPTION_YES_TO_ALL="false"
OPTION_SKIP_SSH="false"
OPTION_SKIP_GITIGNORE="false"
OPTION_SKIP_ALIASES="false"
OPTION_SKIP_VERIFY="false"

SUMMARY_MAIN_ACCOUNT_CONFIGURED="false"
SUMMARY_SSH_KEY_CONFIGURED="false"
SUMMARY_GITIGNORE_CONFIGURED="false"
SUMMARY_ALIASES_CONFIGURED="false"
SUMMARY_EXTRA_ACCOUNTS_COUNT="0"
SUMMARY_VERIFICATION_PASSED="false"

TEMP_FILE=""

print_title() {
  echo -e "\n${COLOR_BOLD}${COLOR_CYAN}$1${COLOR_RESET}"
  echo -e "${COLOR_CYAN}$(printf '─%.0s' {1..40})${COLOR_RESET}"
}

print_success() {
  echo -e "${COLOR_GREEN}✅ $1${COLOR_RESET}"
}

print_error() {
  echo -e "${COLOR_RED}❌ $1${COLOR_RESET}" >&2
}

print_warning() {
  echo -e "${COLOR_YELLOW}⚠️  $1${COLOR_RESET}"
}

print_info() {
  echo -e "${COLOR_BLUE}ℹ️  $1${COLOR_RESET}"
}

ask_input() {
  local prompt="$1"
  local default="${2:-}"
  local input

  # 直接输出到 stderr，确保不被捕获
  if [[ -n "${default}" ]]; then
    printf "%s [%s]: " "${prompt}" "${default}" >&2
  else
    printf "%s: " "${prompt}" >&2
  fi
  
  # 检测是否是交互式终端
  if [[ -t 0 ]]; then
    # 交互式终端：正常读取
    read -r input
    input="${input:-${default}}"
  else
    # 非交互式环境
    if [[ -n "${default}" ]]; then
      # 有默认值：直接使用
      input="${default}"
      echo >&2
      echo "ℹ️ 检测到非交互式环境，使用默认值: ${input}" >&2
    else
      # 没有默认值：提示用户需要在真实终端运行
      echo >&2
      echo >&2
      echo "⚠️ 检测到非交互式终端环境" >&2
      echo "ℹ️ 请在真实的终端中运行此脚本" >&2
      echo "ℹ️ 或者先手动配置 git 用户名和邮箱" >&2
      exit 1
    fi
  fi

  # 只把最终结果输出到 stdout
  echo "${input}"
}

ask_confirm() {
  local prompt="$1"
  local default="${2:-y}"
  local input

  if [[ "${OPTION_YES_TO_ALL}" == "true" ]]; then
    return 0
  fi

  local display_default
  if [[ "${default}" == "y" ]]; then
    display_default="Y/n"
  else
    display_default="y/N"
  fi

  # 直接输出到 stderr
  printf "%s [%s]: " "${prompt}" "${display_default}" >&2
  
  if [[ -t 0 ]]; then
    # 交互式终端：正常读取
    read -r input
    input="${input:-${default}}"
  else
    # 非交互式环境：直接使用默认值
    input="${default}"
    echo >&2
    echo "ℹ️ 检测到非交互式环境，使用默认值: ${input}" >&2
  fi
  
  case "${input}" in
    [Yy]*)
      return 0
      ;;
    [Nn]*)
      return 1
      ;;
    *)
      echo "请输入 y 或 n" >&2
      ;;
  esac
}

ask_choice() {
  local prompt="$1"
  shift
  local all_args=("$@")
  local num_args=${#all_args[@]}
  local default="${all_args[$((num_args - 1))]}"
  local options=("${all_args[@]:0:$((num_args - 1))}")
  local input

  # 输出到 stderr
  echo "${prompt}" >&2
  for option in "${options[@]}"; do
    IFS='|' read -r num name desc <<<"${option}"
    if [[ -n "${desc}" ]]; then
      echo "  ${num}) ${name} - ${desc}" >&2
    else
      echo "  ${num}) ${name}" >&2
    fi
  done

  # 输出到 stderr
  printf "请输入选项 [%s]: " "${default}" >&2
  
  if [[ -t 0 ]]; then
    # 交互式终端：正常读取
    read -r input
    input="${input:-${default}}"
  else
    # 非交互式环境：直接使用默认值
    input="${default}"
    echo >&2
    echo "ℹ️ 检测到非交互式环境，使用默认值: ${input}" >&2
  fi
  
  for option in "${options[@]}"; do
    IFS='|' read -r num name desc <<<"${option}"
    if [[ "${input}" == "${num}" ]]; then
      echo "${num}"
      return 0
    fi
  done

  echo "无效选项，请重新输入" >&2
}

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

validate_git_username() {
  local username="$1"
  [[ -n "${username}" ]] && [[ "${#username}" -le 100 ]]
}

validate_email() {
  local email="$1"
  [[ "${email}" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}

configure_main_account() {
  print_title "📝 主账户配置"

  local current_name current_email

  current_name=$(git config --global user.name 2>/dev/null || true)
  MAIN_ACCOUNT_NAME=$(ask_input "请输入 Git 用户名" "${current_name}")

  while ! validate_git_username "${MAIN_ACCOUNT_NAME}"; do
    print_error "无效的 Git 用户名"
    MAIN_ACCOUNT_NAME=$(ask_input "请输入 Git 用户名" "${current_name}")
  done

  current_email=$(git config --global user.email 2>/dev/null || true)
  MAIN_ACCOUNT_EMAIL=$(ask_input "请输入 Git 邮箱" "${current_email}")

  while ! validate_email "${MAIN_ACCOUNT_EMAIL}"; do
    print_error "无效的邮箱地址"
    MAIN_ACCOUNT_EMAIL=$(ask_input "请输入 Git 邮箱" "${current_email}")
  done

  git config --global user.name "${MAIN_ACCOUNT_NAME}"
  git config --global user.email "${MAIN_ACCOUNT_EMAIL}"

  SUMMARY_MAIN_ACCOUNT_CONFIGURED="true"
  print_success "主账户配置完成: ${MAIN_ACCOUNT_NAME} <${MAIN_ACCOUNT_EMAIL}>"
}

ensure_dir() {
  local dir="$1"
  if [[ ! -d "${dir}" ]]; then
    mkdir -p "${dir}"
  fi
}

configure_ssh_key() {
  print_title "🔑 SSH Key 配置"

  local key_path="${HOME}/.ssh/id_ed25519"

  if [[ -f "${key_path}" ]]; then
    SSH_CONFIG_EXISTS="true"
    SSH_CONFIG_KEY_PATH="${key_path}"

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

  SUMMARY_SSH_KEY_CONFIGURED="true"
}

use_existing_ssh_key() {
  SSH_CONFIG_PUBLIC_KEY=$(cat "${SSH_CONFIG_KEY_PATH}.pub" 2>/dev/null || true)
  print_success "使用现有 SSH Key: ${SSH_CONFIG_KEY_PATH}"
  copy_public_key_to_clipboard
}

backup_and_generate_ssh_key() {
  local timestamp=$(date +%Y%m%d_%H%M%S)
  local backup_path="${SSH_CONFIG_KEY_PATH}.bak.${timestamp}"

  mv "${SSH_CONFIG_KEY_PATH}" "${backup_path}"
  mv "${SSH_CONFIG_KEY_PATH}.pub" "${backup_path}.pub" 2>/dev/null || true

  print_info "已备份旧 Key 到: ${backup_path}"

  generate_new_ssh_key
}

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

  SSH_CONFIG_ALGORITHM="${key_type}"
  SSH_CONFIG_KEY_PATH="${key_path}"

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

  SSH_CONFIG_PUBLIC_KEY=$(cat "${key_path}.pub")

  print_success "SSH Key 已生成: ${key_path}"
  copy_public_key_to_clipboard
}

copy_public_key_to_clipboard() {
  if [[ -z "${SSH_CONFIG_PUBLIC_KEY}" ]]; then
    return
  fi

  if command -v pbcopy &>/dev/null; then
    echo -n "${SSH_CONFIG_PUBLIC_KEY}" | pbcopy
    print_info "📋 公钥已复制到剪贴板"
  elif command -v xclip &>/dev/null; then
    echo -n "${SSH_CONFIG_PUBLIC_KEY}" | xclip -selection clipboard
    print_info "📋 公钥已复制到剪贴板"
  elif command -v xsel &>/dev/null; then
    echo -n "${SSH_CONFIG_PUBLIC_KEY}" | xsel --clipboard --input
    print_info "📋 公钥已复制到剪贴板"
  else
    print_info "公钥:"
    echo "${SSH_CONFIG_PUBLIC_KEY}"
  fi
}

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

  SUMMARY_GITIGNORE_CONFIGURED="true"
}

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

  GITIGNORE_CONFIG_TEMPLATE="default"
  GITIGNORE_CONFIG_ENABLED="true"

  print_success "全局 .gitignore 已配置: ${gitignore_path}"
}

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

  GITIGNORE_CONFIG_CUSTOM_CONTENT="${content}"
  GITIGNORE_CONFIG_TEMPLATE="custom"
  GITIGNORE_CONFIG_ENABLED="true"

  local gitignore_path="${HOME}/.gitignore_global"
  echo -n "${content}" >"${gitignore_path}"
  git config --global core.excludesfile "${gitignore_path}"

  print_success "自定义 .gitignore 已配置: ${gitignore_path}"
}

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

  SUMMARY_ALIASES_CONFIGURED="true"
  print_success "Git 别名已配置"
}

configure_extra_accounts() {
  print_title "👥 多账户配置"

  if ! ask_confirm "是否配置额外的 Git 账户?" "n"; then
    print_info "跳过多账户配置"
    return 0
  fi

  while true; do
    local name email mode dir remote_pattern

    name=$(ask_input "请输入账户名称（例如：工作）")
    email=$(ask_input "请输入 Git 邮箱")
    while ! validate_email "${email}"; do
      print_error "无效的邮箱地址"
      email=$(ask_input "请输入 Git 邮箱")
    done

    echo "请选择账户切换方式:"
    echo "  1) 基于目录 - 在指定目录下自动使用此账户"
    echo "  2) 基于 Remote - 根据 Git remote 地址自动使用此账户"
    mode=$(ask_choice "请选择切换方式" "1|基于目录" "2|基于 Remote" "1")

    if [[ "${mode}" == "1" ]]; then
      dir=$(ask_input "请输入关联的工作目录（例如：~/work）")
      EXTRA_ACCOUNTS+=("${name},${email},dir,${dir}")
      configure_single_extra_account "${name}" "${email}" "dir" "${dir}"
    else
      remote_pattern=$(ask_input "请输入 Git remote 匹配模式（例如：github.com/company 或 git@gitlab.com:team）")
      EXTRA_ACCOUNTS+=("${name},${email},remote,${remote_pattern}")
      configure_single_extra_account "${name}" "${email}" "remote" "${remote_pattern}"
    fi

    SUMMARY_EXTRA_ACCOUNTS_COUNT=$((${SUMMARY_EXTRA_ACCOUNTS_COUNT} + 1))

    if ! ask_confirm "是否继续添加账户?" "n"; then
      break
    fi
  done

  print_success "多账户配置完成，共 ${#EXTRA_ACCOUNTS[@]} 个账户"
}

configure_single_extra_account() {
  local name="$1"
  local email="$2"
  local mode="$3"
  local value="$4"

  local config_path="${HOME}/.gitconfig-${name}"

  cat >"${config_path}" <<EOF
[user]
    name = ${name}
    email = ${email}
EOF

  if [[ "${mode}" == "dir" ]]; then
    local abs_dir
    abs_dir=$(eval echo "${value}")
    git config --global --add "includeIf.gitdir:${abs_dir}/.path" "${config_path}"
    print_success "账户 '${name}' 已配置，关联目录: ${value}"
  else
    git config --global --add "includeIf.hasconfig:remote.*.url:${value}.path" "${config_path}"
    print_success "账户 '${name}' 已配置，匹配 Remote: ${value}"
  fi
}

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
    SUMMARY_VERIFICATION_PASSED="true"
  fi
}

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
    print_warning "GitHub SSH 连接失败"
    print_warning "建议: 请将公钥添加到 GitHub"
    return 1
  fi
}

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
    print_warning "GitLab SSH 连接失败"
    print_warning "建议: 请将公钥添加到 GitLab"
    return 1
  fi
}

print_summary() {
  echo ""
  echo -e "${COLOR_BOLD}${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
  echo -e "${COLOR_BOLD}${COLOR_GREEN}🎉 Git 配置完成！${COLOR_RESET}"
  echo ""
  echo -e "${COLOR_BOLD}📋 配置摘要:${COLOR_RESET}"

  if [[ "${SUMMARY_MAIN_ACCOUNT_CONFIGURED}" == "true" ]]; then
    echo "  • 用户: ${MAIN_ACCOUNT_NAME} <${MAIN_ACCOUNT_EMAIL}>"
  fi

  if [[ "${SUMMARY_SSH_KEY_CONFIGURED}" == "true" ]]; then
    echo "  • SSH Key: ${SSH_CONFIG_ALGORITHM} (${SSH_CONFIG_KEY_PATH})"
  fi

  if [[ "${SUMMARY_GITIGNORE_CONFIGURED}" == "true" ]]; then
    echo "  • 全局 .gitignore: 已配置"
  fi

  if [[ "${SUMMARY_ALIASES_CONFIGURED}" == "true" ]]; then
    echo "  • Git 别名: 已配置"
  fi

  if [[ "${SUMMARY_EXTRA_ACCOUNTS_COUNT}" -gt 0 ]]; then
    echo "  • 额外账户: ${SUMMARY_EXTRA_ACCOUNTS_COUNT} 个"
    for account in "${EXTRA_ACCOUNTS[@]}"; do
      IFS=',' read -r name email mode value <<<"${account}"
      if [[ "${mode}" == "dir" ]]; then
        echo "    - ${name} (目录: ${value})"
      else
        echo "    - ${name} (Remote: ${value})"
      fi
    done
  fi

  echo ""
  echo -e "${COLOR_BOLD}💡 提示:${COLOR_RESET}"

  if [[ "${SUMMARY_SSH_KEY_CONFIGURED}" == "true" ]]; then
    echo "  • 请将公钥添加到 GitHub/GitLab"
  fi

  if [[ "${SUMMARY_EXTRA_ACCOUNTS_COUNT}" -gt 0 ]]; then
    local first_account
    IFS=',' read -r name email mode value <<<"${EXTRA_ACCOUNTS[0]}"
    if [[ "${mode}" == "dir" ]]; then
      echo "  • 在 ${value} 目录下会自动使用 ${name} 账户"
    else
      echo "  • Remote 匹配 ${value} 时会自动使用 ${name} 账户"
    fi
  fi

  echo "  • 使用 --export 可以导出配置备份"
  echo ""
}

print_help() {
  cat <<EOF
Git 一键初始化工具 v${VERSION}

在新机器环境下一键初始化完整的 Git 开发环境。

用法:
  ${SCRIPT_NAME} [选项]

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
  ${SCRIPT_NAME}

  # 导出配置
  ${SCRIPT_NAME} --export ~/git-config.sh

  # 导入配置
  ${SCRIPT_NAME} --import ~/git-config.sh

  # 跳过 SSH Key 配置
  ${SCRIPT_NAME} --no-ssh

远程下载执行:
  # 直接下载并执行（推荐在真实终端中运行）
  bash -c "\$(curl -fsSL https://raw.githubusercontent.com/lizhengnacl/ops-toolkit/main/scripts/git-init.sh)"

  # 先下载再执行（更安全）
  curl -fsSL https://raw.githubusercontent.com/lizhengnacl/ops-toolkit/main/scripts/git-init.sh -o /tmp/git-init.sh
  chmod +x /tmp/git-init.sh
  /tmp/git-init.sh

  # 克隆完整仓库
  git clone https://github.com/lizhengnacl/ops-toolkit.git
  cd ops-toolkit
  ./scripts/git-init.sh

项目地址: https://github.com/lizhengnacl/ops-toolkit
EOF
}

print_version() {
  echo "Git 一键初始化工具 v${VERSION}"
}

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
        OPTION_EXPORT_FILE="$2"
        shift 2
        ;;
      -i|--import)
        OPTION_IMPORT_FILE="$2"
        shift 2
        ;;
      -y|--yes)
        OPTION_YES_TO_ALL="true"
        shift
        ;;
      --no-ssh)
        OPTION_SKIP_SSH="true"
        shift
        ;;
      --no-gitignore)
        OPTION_SKIP_GITIGNORE="true"
        shift
        ;;
      --no-aliases)
        OPTION_SKIP_ALIASES="true"
        shift
        ;;
      --no-verify)
        OPTION_SKIP_VERIFY="true"
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

export_config() {
  local export_file="$1"
  
  print_title "📤 导出 Git 配置"
  
  # 读取主账户信息
  local main_name main_email
  main_name=$(git config --global user.name 2>/dev/null || echo "")
  main_email=$(git config --global user.email 2>/dev/null || echo "")
  
  # 查找 SSH Key
  local ssh_algorithm ssh_key_path
  if [[ -f "${HOME}/.ssh/id_ed25519" ]]; then
    ssh_algorithm="ed25519"
    ssh_key_path="${HOME}/.ssh/id_ed25519"
  elif [[ -f "${HOME}/.ssh/id_rsa" ]]; then
    ssh_algorithm="rsa"
    ssh_key_path="${HOME}/.ssh/id_rsa"
  else
    ssh_algorithm=""
    ssh_key_path=""
  fi
  
  # 读取 .gitignore 内容
  local gitignore_enabled gitignore_content gitignore_path
  gitignore_path=$(git config --global core.excludesfile 2>/dev/null || echo "")
  if [[ -n "${gitignore_path}" ]] && [[ -f "${gitignore_path}" ]]; then
    gitignore_enabled="true"
    gitignore_content=$(cat "${gitignore_path}")
  else
    gitignore_enabled="false"
    gitignore_content=""
  fi
  
  # 检查 Git 别名是否配置
  local aliases_configured
  if git config --global alias.st &>/dev/null; then
    aliases_configured="true"
  else
    aliases_configured="false"
  fi
  
  # 解析多账户配置
  local extra_accounts=()
  local includeif_lines
  includeif_lines=$(git config --global --get-regexp "includeIf\." 2>/dev/null || true)
  
  while IFS= read -r line; do
    if [[ -n "${line}" ]]; then
      local key value
      key=$(echo "${line}" | awk '{print $1}')
      value=$(echo "${line}" | cut -d' ' -f2-)
      
      if [[ "${key}" == *".path" ]]; then
        local config_file="${value}"
        local account_name
        account_name=$(basename "${config_file}" | sed 's/\.gitconfig-//')
        
        local account_email
        if [[ -f "${config_file}" ]]; then
          account_email=$(git config --file "${config_file}" user.email 2>/dev/null || echo "")
        fi
        
        local mode=""
        local pattern=""
        if [[ "${key}" == includeIf.gitdir:* ]]; then
          mode="dir"
          pattern=$(echo "${key}" | sed -E 's/includeIf\.gitdir:(.*)\.path/\1/')
          pattern=${pattern%/}
        elif [[ "${key}" == includeIf.hasconfig:remote.*.url:* ]]; then
          mode="remote"
          pattern=$(echo "${key}" | sed -E 's/includeIf\.hasconfig:remote\.\*\.url:(.*)\.path/\1/')
        fi
        
        if [[ -n "${account_name}" ]] && [[ -n "${mode}" ]] && [[ -n "${pattern}" ]]; then
          extra_accounts+=("${account_name},${account_email:-},${mode},${pattern}")
        fi
      fi
    fi
  done <<<"${includeif_lines}"
  
  # 生成导出脚本
  cat >"${export_file}" <<EOF
#!/usr/bin/env bash
# Git 配置导出文件 - 由 git-init.sh 生成
# 生成时间: $(date)

export GIT_INIT_CONFIG_MAIN_NAME="${main_name}"
export GIT_INIT_CONFIG_MAIN_EMAIL="${main_email}"
export GIT_INIT_CONFIG_SSH_ALGORITHM="${ssh_algorithm}"
export GIT_INIT_CONFIG_SSH_KEY_PATH="${ssh_key_path}"
export GIT_INIT_CONFIG_GITIGNORE_ENABLED="${gitignore_enabled}"
export GIT_INIT_CONFIG_GITIGNORE_CONTENT='${gitignore_content//'/'\\''}'
export GIT_INIT_CONFIG_ALIASES_CONFIGURED="${aliases_configured}"
EOF
  
  # 添加多账户配置
  if [[ ${#extra_accounts[@]} -gt 0 ]]; then
    echo "" >>"${export_file}"
    echo "# 多账户配置" >>"${export_file}"
    local idx=0
    for account in "${extra_accounts[@]}"; do
      IFS=',' read -r name email mode pattern <<<"${account}"
      echo "export GIT_INIT_CONFIG_EXTRA_ACCOUNT_${idx}_NAME=\"${name}\"" >>"${export_file}"
      echo "export GIT_INIT_CONFIG_EXTRA_ACCOUNT_${idx}_EMAIL=\"${email}\"" >>"${export_file}"
      echo "export GIT_INIT_CONFIG_EXTRA_ACCOUNT_${idx}_MODE=\"${mode}\"" >>"${export_file}"
      echo "export GIT_INIT_CONFIG_EXTRA_ACCOUNT_${idx}_PATTERN=\"${pattern}\"" >>"${export_file}"
      idx=$((idx + 1))
    done
    echo "export GIT_INIT_CONFIG_EXTRA_ACCOUNTS_COUNT=\"${idx}\"" >>"${export_file}"
  fi
  
  # 设置可执行权限
  chmod +x "${export_file}"
  
  print_success "配置已导出到: ${export_file}"
}

import_config() {
  local import_file="$1"
  
  print_title "📥 导入 Git 配置"
  
  if [[ ! -f "${import_file}" ]]; then
    print_error "导入文件不存在: ${import_file}"
    exit 1
  fi
  
  # 导入配置
  source "${import_file}"
  
  # 设置自动确认所有提示
  OPTION_YES_TO_ALL="true"
  
  print_success "配置已从 ${import_file} 导入"
  
  # 调用主流程应用配置
  check_dependencies
  
  if [[ -n "${GIT_INIT_CONFIG_MAIN_NAME:-}" ]] && [[ -n "${GIT_INIT_CONFIG_MAIN_EMAIL:-}" ]]; then
    git config --global user.name "${GIT_INIT_CONFIG_MAIN_NAME}"
    git config --global user.email "${GIT_INIT_CONFIG_MAIN_EMAIL}"
    MAIN_ACCOUNT_NAME="${GIT_INIT_CONFIG_MAIN_NAME}"
    MAIN_ACCOUNT_EMAIL="${GIT_INIT_CONFIG_MAIN_EMAIL}"
    SUMMARY_MAIN_ACCOUNT_CONFIGURED="true"
    print_success "主账户已配置: ${MAIN_ACCOUNT_NAME} <${MAIN_ACCOUNT_EMAIL}>"
  fi
  
  if [[ "${GIT_INIT_CONFIG_GITIGNORE_ENABLED:-}" == "true" ]] && [[ -n "${GIT_INIT_CONFIG_GITIGNORE_CONTENT:-}" ]]; then
    local gitignore_path="${HOME}/.gitignore_global"
    echo -n "${GIT_INIT_CONFIG_GITIGNORE_CONTENT}" >"${gitignore_path}"
    git config --global core.excludesfile "${gitignore_path}"
    SUMMARY_GITIGNORE_CONFIGURED="true"
    print_success "全局 .gitignore 已配置"
  fi
  
  if [[ "${GIT_INIT_CONFIG_ALIASES_CONFIGURED:-}" == "true" ]]; then
    git config --global alias.st "status"
    git config --global alias.co "checkout"
    git config --global alias.br "branch"
    git config --global alias.ci "commit"
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.last "log -1 HEAD"
    SUMMARY_ALIASES_CONFIGURED="true"
    print_success "Git 别名已配置"
  fi
  
  # 导入多账户配置
  local extra_accounts_count=${GIT_INIT_CONFIG_EXTRA_ACCOUNTS_COUNT:-0}
  if [[ "${extra_accounts_count}" -gt 0 ]]; then
    local idx=0
    while [[ "${idx}" -lt "${extra_accounts_count}" ]]; do
      local name_var="GIT_INIT_CONFIG_EXTRA_ACCOUNT_${idx}_NAME"
      local email_var="GIT_INIT_CONFIG_EXTRA_ACCOUNT_${idx}_EMAIL"
      local mode_var="GIT_INIT_CONFIG_EXTRA_ACCOUNT_${idx}_MODE"
      local pattern_var="GIT_INIT_CONFIG_EXTRA_ACCOUNT_${idx}_PATTERN"
      
      local name="${!name_var:-}"
      local email="${!email_var:-}"
      local mode="${!mode_var:-}"
      local pattern="${!pattern_var:-}"
      
      if [[ -n "${name}" ]] && [[ -n "${mode}" ]] && [[ -n "${pattern}" ]]; then
        EXTRA_ACCOUNTS+=("${name},${email},${mode},${pattern}")
        configure_single_extra_account "${name}" "${email}" "${mode}" "${pattern}"
        SUMMARY_EXTRA_ACCOUNTS_COUNT=$((SUMMARY_EXTRA_ACCOUNTS_COUNT + 1))
      fi
      
      idx=$((idx + 1))
    done
  fi
  
  print_summary
}

cleanup() {
  if [[ -n "${TEMP_FILE:-}" ]] && [[ -f "${TEMP_FILE}" ]]; then
    rm -f "${TEMP_FILE}"
  fi
}
trap cleanup EXIT

main() {
  parse_args "$@"

  echo "🚀 Git 一键初始化工具 v${VERSION}"

  if [[ -n "${OPTION_EXPORT_FILE}" ]]; then
    export_config "${OPTION_EXPORT_FILE}"
    exit 0
  fi

  if [[ -n "${OPTION_IMPORT_FILE}" ]]; then
    import_config "${OPTION_IMPORT_FILE}"
    exit 0
  fi

  check_dependencies
  configure_main_account

  if [[ "${OPTION_SKIP_SSH}" != "true" ]]; then
    configure_ssh_key
  fi

  if [[ "${OPTION_SKIP_GITIGNORE}" != "true" ]]; then
    configure_gitignore
  fi

  if [[ "${OPTION_SKIP_ALIASES}" != "true" ]]; then
    configure_git_aliases
  fi

  configure_extra_accounts

  if [[ "${OPTION_SKIP_VERIFY}" != "true" ]]; then
    verify_configuration
  fi

  print_summary
}

main "$@"
