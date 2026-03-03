#!/usr/bin/env bash
#
# 描述: 组件执行器
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../core/constants.sh"

# 描述: 执行单个组件
# 参数: $1 - 组件 ID
# 返回: 0 成功, 非 0 失败
execute_component() {
  local component_id="$1"
  
  if command -v "component_${component_id}_install" &> /dev/null; then
    "component_${component_id}_install"
    return $?
  fi
  
  return 1
}

# 描述: 检测单个组件
# 参数: $1 - 组件 ID
# 返回: 0 已安装, 1 未安装
detect_component() {
  local component_id="$1"
  
  if command -v "component_${component_id}_detect" &> /dev/null; then
    "component_${component_id}_detect"
    return $?
  fi
  
  return 1
}

# 描述: 执行组件列表
# 参数: $@ - 组件 ID 列表
# 返回: 0
execute_components() {
  local component_ids=("$@")
  
  for component_id in "${component_ids[@]}"; do
    if ! detect_component "${component_id}"; then
      execute_component "${component_id}" || true
    fi
  done
  
  return 0
}
