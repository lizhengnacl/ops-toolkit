#!/usr/bin/env bash
#
# 描述: 输出格式化
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# 颜色代码
# ============================================================================

COLOR_RESET="\033[0m"
COLOR_BLACK="\033[30m"
COLOR_RED="\033[31m"
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"
COLOR_MAGENTA="\033[35m"
COLOR_CYAN="\033[36m"
COLOR_WHITE="\033[37m"
COLOR_BOLD="\033[1m"

# ============================================================================
# 输出函数
# ============================================================================

# 描述: 打印标题
# 参数: $1 - 标题文本
print_title() {
  local title="$1"
  echo ""
  echo -e "${COLOR_BOLD}${COLOR_CYAN}${title}${COLOR_RESET}"
}

# 描述: 打印分隔线
# 参数:
#   $1 - 字符 (可选, 默认 ─)
#   $2 - 长度 (可选, 默认 40)
print_separator() {
  local char="${1:-─}"
  local length="${2:-40}"
  printf "%${length}s\n" | tr ' ' "${char}"
}

# 描述: 打印成功消息
# 参数: $1 - 消息
print_success() {
  local message="$1"
  echo -e "${COLOR_GREEN}✓ ${message}${COLOR_RESET}"
}

# 描述: 打印错误消息
# 参数: $1 - 消息
print_error() {
  local message="$1"
  echo -e "${COLOR_RED}✗ ${message}${COLOR_RESET}" >&2
}

# 描述: 打印警告消息
# 参数: $1 - 消息
print_warning() {
  local message="$1"
  echo -e "${COLOR_YELLOW}⚠ ${message}${COLOR_RESET}"
}

# 描述: 打印信息消息
# 参数: $1 - 消息
print_info() {
  local message="$1"
  echo -e "${COLOR_BLUE}ℹ ${message}${COLOR_RESET}"
}

# 描述: 打印组件状态行
# 参数:
#   $1 - 组件名称
#   $2 - 状态 (success|skipped|failed)
#   $3 - 消息
print_component_status() {
  local name="$1"
  local status="$2"
  local message="$3"

  case "${status}" in
    success)
      echo -e "  ${COLOR_GREEN}✓ ${name}${COLOR_RESET}    ${message}"
      ;;
    skipped)
      echo -e "  ${COLOR_CYAN}✓ ${name}${COLOR_RESET}    ${COLOR_CYAN}${message}${COLOR_RESET}"
      ;;
    failed)
      echo -e "  ${COLOR_RED}✗ ${name}${COLOR_RESET}    ${COLOR_RED}${message}${COLOR_RESET}"
      ;;
    *)
      echo -e "  ${name}    ${message}"
      ;;
  esac
}
