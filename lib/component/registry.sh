#!/usr/bin/env bash
#
# 描述: 组件注册表
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

# 加载核心库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../core/constants.sh"

# ============================================================================
# 组件注册表
# ============================================================================

ALL_COMPONENTS=()
CATEGORY_COMPONENTS=()
COMPONENTS=()
ALL_CATEGORIES=()
CATEGORIES=()

# ============================================================================
# 注册表函数
# ============================================================================

# 描述: 初始化组件注册表
# 返回: 0
init_component_registry() {
  ALL_COMPONENTS=()
  CATEGORY_COMPONENTS=()
  COMPONENTS=()
  ALL_CATEGORIES=()
  CATEGORIES=()

  return 0
}

# 描述: 获取所有已注册组件
# 返回: 组件 ID 数组 (通过 stdout 输出)
get_all_components() {
  echo "${ALL_COMPONENTS[@]}"
}

# 描述: 获取指定类别的组件
# 参数: $1 - 类别名称
# 返回: 组件 ID 数组 (通过 stdout 输出)
get_components_by_category() {
  local category="$1"
  if [[ -n "${CATEGORY_COMPONENTS["${category}"]:-}" ]]; then
    echo "${CATEGORY_COMPONENTS["${category}"]}"
  fi
}

# 描述: 获取所有类别
# 返回: 类别名称数组 (通过 stdout 输出)
get_categories() {
  echo "${ALL_CATEGORIES[@]}"
}
