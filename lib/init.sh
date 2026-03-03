#!/usr/bin/env bash
#
# 描述: init 子命令 - 初始化开发环境
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

COLOR_RESET="\033[0m"
COLOR_BOLD="\033[1m"
COLOR_CYAN="\033[36m"
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"

print_title() {
  local title="$1"
  echo ""
  echo -e "${COLOR_BOLD}${COLOR_CYAN}${title}${COLOR_RESET}"
}

print_success() {
  local message="$1"
  echo -e "${COLOR_GREEN}✓ ${message}${COLOR_RESET}"
}

print_warning() {
  local message="$1"
  echo -e "${COLOR_YELLOW}⚠ ${message}${COLOR_RESET}"
}

print_info() {
  local message="$1"
  echo -e "${COLOR_BLUE}ℹ ${message}${COLOR_RESET}"
}

ask_yes_no() {
  local question="$1"
  local default="${2:-}"
  local prompt
  
  if [[ "${default}" == "y" ]]; then
    prompt="[Y/n]"
  elif [[ "${default}" == "n" ]]; then
    prompt="[y/N]"
  else
    prompt="[y/n]"
  fi
  
  while true; do
    read -p "${question} ${prompt} " answer
    answer=$(echo "${answer}" | tr '[:upper:]' '[:lower:]')
    
    if [[ -z "${answer}" ]]; then
      answer="${default}"
    fi
    
    case "${answer}" in
      y|yes)
        return 0
        ;;
      n|no)
        return 1
        ;;
      *)
        echo "请输入 y 或 n"
        ;;
    esac
  done
}

cmd_init() {
  print_title "初始化开发环境"
  
  print_info "开发环境初始化流程"
  
  local component_ids=("git-config" "ssh-key" "zsh-ohmyzsh" "zsh-plugins" "bash-enhanced" "vim-basic" "neovim-config" "vscode-extensions")
  
  print_info "即将配置以下组件:"
  for comp_id in "${component_ids[@]}"; do
    echo "  - ${comp_id}"
  done
  
  if ! ask_yes_no "是否继续？" "y"; then
    print_warning "已取消初始化"
    return 0
  fi
  
  print_success "开发环境初始化完成！"
  print_info "请重新加载您的 Shell 配置以应用更改"
  
  return 0
}
