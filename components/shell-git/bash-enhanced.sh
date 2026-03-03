#!/usr/bin/env bash
#
# 描述: Bash 增强组件
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

COMPONENT_ID="bash-enhanced"
COMPONENT_NAME="Bash 增强"
COMPONENT_DESC="增强 Bash 配置和别名"
COMPONENT_CATEGORY="shell-git"
COMPONENT_DEPS=""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/core/constants.sh"
source "${SCRIPT_DIR}/../../lib/core/utils.sh"
source "${SCRIPT_DIR}/../../lib/ui/output.sh"

component_bash_enhanced_detect() {
  local bashrc="${HOME}/.bashrc"
  if [[ -f "${bashrc}" ]] && grep -q "ops-toolkit bash 配置" "${bashrc}" 2>/dev/null; then
    return 0
  fi
  return 1
}

component_bash_enhanced_install() {
  print_title "配置 Bash 增强"
  
  local bashrc="${HOME}/.bashrc"
  local bashrc_append="${SCRIPT_DIR}/../../configs/bash/bashrc.append"
  
  if [[ -f "${bashrc_append}" ]]; then
    if ! grep -q "ops-toolkit bash 配置" "${bashrc}" 2>/dev/null; then
      cat "${bashrc_append}" >> "${bashrc}"
    fi
  fi
  
  print_success "Bash 增强配置完成"
  return 0
}
