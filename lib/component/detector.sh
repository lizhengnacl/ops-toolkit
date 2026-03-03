#!/usr/bin/env bash
#
# 描述: 组件检测器
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../core/constants.sh"

# 描述: 扫描组件目录
# 参数: $1 - 组件根目录
# 返回: 组件文件路径数组 (通过 stdout 输出)
scan_components() {
  local root_dir="$1"
  local components=()
  
  if [[ -d "${root_dir}" ]]; then
    while IFS= read -r -d '' file; do
      if [[ "${file}" != *"_base.sh" ]] && [[ "${file}" != *"_category.sh" ]]; then
        components+=("${file}")
      fi
    done < <(find "${root_dir}" -name "*.sh" -type f -print0)
  fi
  
  echo "${components[@]}"
}

# 描述: 加载单个组件
# 参数: $1 - 组件文件路径
# 返回: 0 成功, 非 0 失败
load_component() {
  local component_file="$1"
  if [[ -f "${component_file}" ]]; then
    source "${component_file}"
    return 0
  fi
  return 1
}

# 描述: 检测所有组件
# 参数: $1 - 组件根目录
# 返回: 0
detect_all_components() {
  local root_dir="$1"
  local components
  components=($(scan_components "${root_dir}"))
  
  for component_file in "${components[@]}"; do
    load_component "${component_file}" || true
  done
  
  return 0
}
