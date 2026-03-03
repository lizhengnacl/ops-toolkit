#!/usr/bin/env bash
#
# 描述: 日志系统
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

# 加载常量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/constants.sh"

# ============================================================================
# 日志上下文
# ============================================================================

LOG_CONTEXT_LEVEL="INFO"
LOG_CONTEXT_FILE=""
LOG_CONTEXT_ENABLED="true"
LOG_CONTEXT_COLOR="true"

# ============================================================================
# 颜色代码
# ============================================================================

COLOR_RESET="\033[0m"
COLOR_RED="\033[31m"
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"
COLOR_CYAN="\033[36m"

# ============================================================================
# 日志初始化函数
# ============================================================================

# 描述: 初始化日志系统
# 参数:
#   $1 - 日志级别 (DEBUG|INFO|WARN|ERROR)
#   $2 - 日志文件路径 (可选)
# 返回: 0
log_init() {
  local log_level="${1:-INFO}"
  local log_file="${2:-}"

  LOG_CONTEXT_LEVEL="${log_level}"
  LOG_CONTEXT_FILE="${log_file}"

  if [[ -n "${log_file}" ]]; then
    LOG_CONTEXT_ENABLED="true"
    local log_dir
    log_dir="$(dirname "${log_file}")"
    mkdir -p "${log_dir}"
  fi

  return 0
}

# ============================================================================
# 日志输出函数
# ============================================================================

# 描述: 输出 DEBUG 级别日志
# 参数: $* - 日志内容
log_debug() {
  if [[ "${LOG_CONTEXT_LEVEL}" == "DEBUG" ]]; then
    _log_output "DEBUG" "${COLOR_CYAN}" "$*"
  fi
}

# 描述: 输出 INFO 级别日志
# 参数: $* - 日志内容
log_info() {
  _log_output "INFO" "${COLOR_GREEN}" "$*"
}

# 描述: 输出 WARN 级别日志
# 参数: $* - 日志内容
log_warn() {
  _log_output "WARN" "${COLOR_YELLOW}" "$*"
}

# 描述: 输出 ERROR 级别日志
# 参数: $* - 日志内容
log_error() {
  _log_output "ERROR" "${COLOR_RED}" "$*" >&2
}

# ============================================================================
# 内部辅助函数
# ============================================================================

# 描述: 内部日志输出
# 参数:
#   $1 - 级别名称
#   $2 - 颜色代码
#   $3 - 日志内容
_log_output() {
  local level="$1"
  local color="$2"
  local message="$3"
  local timestamp
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

  local output="[${timestamp}] [${level}] ${message}"

  if [[ "${LOG_CONTEXT_COLOR}" == "true" ]]; then
    echo -e "${color}${output}${COLOR_RESET}"
  else
    echo "${output}"
  fi

  if [[ "${LOG_CONTEXT_ENABLED}" == "true" ]] && [[ -n "${LOG_CONTEXT_FILE}" ]]; then
    echo "${output}" >> "${LOG_CONTEXT_FILE}"
  fi
}
