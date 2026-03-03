#!/usr/bin/env bash
#
# 描述: Zsh 插件组件
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

COMPONENT_ID="zsh-plugins"
COMPONENT_NAME="Zsh 插件"
COMPONENT_DESC="配置 Zsh 常用插件"
COMPONENT_CATEGORY="shell-git"
COMPONENT_DEPS="zsh-ohmyzsh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/core/constants.sh"
source "${SCRIPT_DIR}/../../lib/core/utils.sh"
source "${SCRIPT_DIR}/../../lib/ui/output.sh"

component_zsh_plugins_detect() {
  local zshrc="${HOME}/.zshrc"
  if [[ -f "${zshrc}" ]] && grep -q "plugins=" "${zshrc}"; then
    return 0
  fi
  return 1
}

component_zsh_plugins_install() {
  print_title "配置 Zsh 插件"
  
  local zshrc="${HOME}/.zshrc"
  local zshrc_append="${SCRIPT_DIR}/../../configs/zsh/zshrc.append"
  
  if [[ -f "${zshrc_append}" ]]; then
    if ! grep -q "ops-toolkit zsh 配置" "${zshrc}" 2>/dev/null; then
      cat "${zshrc_append}" >> "${zshrc}"
    fi
  fi
  
  if [[ -f "${zshrc}" ]]; then
    sed -i.bak 's/^plugins=(git)/plugins=(git gitfast docker kubectl)/' "${zshrc}" 2>/dev/null || true
    rm -f "${zshrc}.bak"
  fi
  
  print_success "Zsh 插件配置完成"
  return 0
}
