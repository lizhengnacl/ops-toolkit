#!/usr/bin/env bash
#
# 描述: 进度显示
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

# 描述: 显示进度条
# 参数:
#   $1 - 当前进度
#   $2 - 总进度
#   $3 - 描述 (可选)
show_progress() {
  local current="$1"
  local total="$2"
  local description="${3:-}"
  local percent=$((current * 100 / total))
  local bar_length=50
  local filled_length=$((percent * bar_length / 100))
  local bar=""

  for ((i = 0; i < filled_length; i++)); do
    bar="${bar}█"
  done
  for ((i = filled_length; i < bar_length; i++)); do
    bar="${bar}░"
  done

  printf "\r[%s] %d%% %s" "${bar}" "${percent}" "${description}"
}

# 描述: 完成进度条
finish_progress() {
  echo ""
}
