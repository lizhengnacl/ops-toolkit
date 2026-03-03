#!/usr/bin/env bash
#
# 描述: 通用工具函数
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

# 加载常量和日志
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/constants.sh"
source "${SCRIPT_DIR}/logging.sh"

# ============================================================================
# 工具函数
# ============================================================================

# 描述: 检查命令是否存在
# 参数: $1 - 命令名称
# 返回: 0 存在, 1 不存在
command_exists() {
  local cmd="$1"
  if command -v "${cmd}" &>/dev/null; then
    return 0
  fi
  return 1
}

# 描述: 安全创建目录
# 参数: $1 - 目录路径
# 返回: 0 成功, 1 失败
ensure_dir() {
  local dir="$1"
  if ! mkdir -p "${dir}"; then
    log_error "Failed to create directory: ${dir}"
    return 1
  fi
  return 0
}

# 描述: 备份文件
# 参数:
#   $1 - 源文件路径
#   $2 - 备份目录 (可选)
# 返回: 备份文件路径
backup_file() {
  local source_file="$1"
  local backup_dir="${2:-$(dirname "${source_file}")}"
  local timestamp
  timestamp="$(date '+%Y%m%d-%H%M%S')"
  local backup_file="${backup_dir}/$(basename "${source_file}").${timestamp}.bak"

  if [[ -f "${source_file}" ]]; then
    ensure_dir "${backup_dir}"
    cp "${source_file}" "${backup_file}"
    log_debug "Backed up ${source_file} to ${backup_file}"
  fi

  echo "${backup_file}"
}

# 描述: 获取当前时间戳
# 返回: ISO 8601 格式时间戳
timestamp() {
  date '+%Y-%m-%dT%H:%M:%S%z'
}
