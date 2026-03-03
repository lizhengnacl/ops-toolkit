#!/usr/bin/env bash
#
# 描述: ops-toolkit 卸载脚本
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

readonly VERSION="1.0.0"
readonly INSTALL_DIR="${HOME}/.local/lib/ops-toolkit"
readonly BIN_DIR="${HOME}/.local/bin"
readonly LOG_DIR="${HOME}/.cache/ops-toolkit/logs"
readonly CONFIG_DIR="${HOME}/.config/ops-toolkit"
readonly TEMP_DIR="${HOME}/.cache/ops-toolkit/tmp"

COLOR_RESET="\033[0m"
COLOR_BOLD="\033[1m"
COLOR_CYAN="\033[36m"
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_RED="\033[31m"

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
  echo -e "${COLOR_BOLD}${COLOR_CYAN}${message}${COLOR_RESET}"
}

print_error() {
  local message="$1"
  echo -e "${COLOR_RED}✗ ${message}${COLOR_RESET}"
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

main() {
  print_title "卸载 ops-toolkit v${VERSION}"
  
  print_warning "此操作将删除以下内容:"
  echo "  - ${INSTALL_DIR}"
  echo "  - ${BIN_DIR}/ops-toolkit"
  echo "  - ${LOG_DIR}"
  echo "  - ${CONFIG_DIR}"
  echo "  - ${TEMP_DIR}"
  
  if ! ask_yes_no "确认要卸载吗？" "n"; then
    print_info "已取消卸载"
    return 0
  fi
  
  local items=(
    "${INSTALL_DIR}"
    "${BIN_DIR}/ops-toolkit"
    "${LOG_DIR}"
    "${CONFIG_DIR}"
    "${TEMP_DIR}"
  )
  
  for item in "${items[@]}"; do
    if [[ -e "${item}" ]]; then
      print_info "删除 ${item}..."
      rm -rf "${item}"
      print_success "已删除 ${item}"
    else
      print_warning "${item} 不存在，跳过"
    fi
  done
  
  print_success "卸载完成！"
  
  return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
