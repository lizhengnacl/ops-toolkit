#!/usr/bin/env bash
#
# 描述: Zsh 和 Oh My Zsh 组件
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

COMPONENT_ID="zsh-ohmyzsh"
COMPONENT_NAME="Zsh + Oh My Zsh"
COMPONENT_DESC="安装 Zsh 和 Oh My Zsh"
COMPONENT_CATEGORY="shell-git"
COMPONENT_DEPS=""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/core/constants.sh"
source "${SCRIPT_DIR}/../../lib/core/utils.sh"
source "${SCRIPT_DIR}/../../lib/system/detect.sh"
source "${SCRIPT_DIR}/../../lib/ui/output.sh"

component_zsh_ohmyzsh_detect() {
  if command -v zsh &> /dev/null && [[ -d "${HOME}/.oh-my-zsh" ]]; then
    return 0
  fi
  return 1
}

component_zsh_ohmyzsh_install() {
  print_title "安装 Zsh 和 Oh My Zsh"
  
  local os
  os=$(detect_os)
  
  if ! command -v zsh &> /dev/null; then
    print_info "正在安装 Zsh..."
    case "${os}" in
      macos)
        if command -v brew &> /dev/null; then
          brew install zsh
        fi
        ;;
      ubuntu|debian)
        sudo apt-get update && sudo apt-get install -y zsh
        ;;
      centos)
        sudo yum install -y zsh
        ;;
    esac
  fi
  
  if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
    print_info "正在安装 Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
  
  print_success "Zsh 和 Oh My Zsh 安装完成"
  return 0
}
