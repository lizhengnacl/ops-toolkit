#!/usr/bin/env bash
#
# 描述: ops-toolkit 安装脚本
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VERSION="1.0.0"
readonly INSTALL_DIR="${HOME}/.local/lib/ops-toolkit"
readonly BIN_DIR="${HOME}/.local/bin"

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

check_dependencies() {
  local deps=("bash" "git")
  for dep in "${deps[@]}"; do
    if ! command -v "${dep}" >/dev/null 2>&1; then
      print_error "缺少依赖: ${dep}"
      return 1
    fi
  done
  return 0
}

main() {
  print_title "安装 ops-toolkit v${VERSION}"
  
  if ! check_dependencies; then
    exit 1
  fi
  
  print_info "创建安装目录..."
  mkdir -p "${INSTALL_DIR}"
  mkdir -p "${BIN_DIR}"
  print_success "目录创建完成"
  
  print_info "复制文件..."
  cp -r "${SCRIPT_DIR}/lib/"* "${INSTALL_DIR}/"
  cp -r "${SCRIPT_DIR}/components" "${INSTALL_DIR}/"
  cp -r "${SCRIPT_DIR}/configs" "${INSTALL_DIR}/"
  cp "${SCRIPT_DIR}/bin/ops-toolkit" "${BIN_DIR}/"
  chmod +x "${BIN_DIR}/ops-toolkit"
  print_success "文件复制完成"
  
  if [[ ":${PATH}:" != *":${BIN_DIR}:"* ]]; then
    print_warning "注意: ${BIN_DIR} 不在 PATH 环境变量中"
    print_info "请将以下内容添加到您的 Shell 配置文件中:"
    echo "  export PATH=\"\${PATH}:${BIN_DIR}\""
  fi
  
  print_success "安装完成！"
  print_info "运行 'ops-toolkit help' 查看使用说明"
  
  return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
