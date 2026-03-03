#!/usr/bin/env bash
#
# 描述: VSCode 扩展组件
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

COMPONENT_ID="vscode-extensions"
COMPONENT_NAME="VSCode 扩展"
COMPONENT_DESC="安装常用 VSCode 扩展"
COMPONENT_CATEGORY="editor"
COMPONENT_DEPS=""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

component_vscode_extensions_detect() {
  if command -v code &> /dev/null; then
    return 0
  fi
  return 1
}

component_vscode_extensions_install() {
  echo "VSCode 扩展安装"
  return 0
}
