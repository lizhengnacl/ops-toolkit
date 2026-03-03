#!/usr/bin/env bash
#
# 描述: 参数校验函数
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# 参数校验函数
# ============================================================================

# 描述: 验证路径安全性
# 参数: $1 - 路径
# 返回: 0 安全, 1 不安全
validate_path() {
  local path="$1"
  if [[ "${path}" =~ \.\. ]] || [[ "${path}" =~ ^/ ]]; then
    return 1
  fi
  return 0
}

# 描述: 验证邮箱格式
# 参数: $1 - 邮箱地址
# 返回: 0 有效, 1 无效
validate_email() {
  local email="$1"
  if [[ "${email}" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    return 0
  fi
  return 1
}

# 描述: 验证 Git 用户名
# 参数: $1 - 用户名
# 返回: 0 有效, 1 无效
validate_git_username() {
  local username="$1"
  if [[ -n "${username}" ]] && [[ "${#username}" -ge 2 ]]; then
    return 0
  fi
  return 1
}
