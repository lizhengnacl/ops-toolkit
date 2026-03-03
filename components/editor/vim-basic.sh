#!/usr/bin/env bash
#
# 描述: Vim 基础配置组件
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

COMPONENT_ID="vim-basic"
COMPONENT_NAME="Vim 基础配置"
COMPONENT_DESC="配置 Vim 基础设置和插件"
COMPONENT_CATEGORY="editor"
COMPONENT_DEPS=""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

component_vim_basic_detect() {
  if [[ -f "${HOME}/.vimrc" ]] || [[ -f "${HOME}/.vim/vimrc" ]]; then
    return 0
  fi
  return 1
}

component_vim_basic_install() {
  if [[ ! -f "${HOME}/.vimrc" ]] && [[ -f "${SCRIPT_DIR}/../../configs/vim/vimrc.template" ]]; then
    cp "${SCRIPT_DIR}/../../configs/vim/vimrc.template" "${HOME}/.vimrc"
  fi
  
  return 0
}
