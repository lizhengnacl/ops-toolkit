#!/usr/bin/env bash
#
# 描述: SSH Key 组件
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

COMPONENT_ID="ssh-key"
COMPONENT_NAME="SSH Key"
COMPONENT_DESC="生成和配置 SSH Key"
COMPONENT_CATEGORY="shell-git"
COMPONENT_DEPS=""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/core/constants.sh"
source "${SCRIPT_DIR}/../../lib/core/utils.sh"
source "${SCRIPT_DIR}/../../lib/ui/output.sh"
source "${SCRIPT_DIR}/../../lib/ui/interactive.sh"

component_ssh_key_detect() {
  if [[ -f "${HOME}/.ssh/id_rsa" ]] || [[ -f "${HOME}/.ssh/id_ed25519" ]]; then
    return 0
  fi
  return 1
}

component_ssh_key_install() {
  print_title "配置 SSH Key"
  
  local key_type="ed25519"
  local key_file="${HOME}/.ssh/id_${key_type}"
  
  if [[ -f "${key_file}" ]]; then
    print_success "SSH Key 已存在"
    return 0
  fi
  
  if ask_yes_no "是否要生成新的 SSH Key？" "y"; then
    local email
    email=$(ask_input "请输入用于 SSH Key 的邮箱" "$(git config --global user.email 2>/dev/null || true)")
    
    ensure_dir "${HOME}/.ssh"
    
    ssh-keygen -t "${key_type}" -C "${email}" -f "${key_file}" -N ""
    
    print_success "SSH Key 已生成"
    print_info "公钥内容："
    cat "${key_file}.pub"
  fi
  
  return 0
}
