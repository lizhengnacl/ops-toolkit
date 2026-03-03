#!/usr/bin/env bash
#
# 描述: Git 配置组件
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

COMPONENT_ID="git-config"
COMPONENT_NAME="Git 配置"
COMPONENT_DESC="配置 Git 用户信息和常用别名"
COMPONENT_CATEGORY="shell-git"
COMPONENT_DEPS=""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/core/constants.sh"
source "${SCRIPT_DIR}/../../lib/core/utils.sh"
source "${SCRIPT_DIR}/../../lib/core/validation.sh"
source "${SCRIPT_DIR}/../../lib/ui/output.sh"
source "${SCRIPT_DIR}/../../lib/ui/interactive.sh"

component_git_config_detect() {
  local user_name
  user_name=$(git config --global user.name 2>/dev/null || true)
  local user_email
  user_email=$(git config --global user.email 2>/dev/null || true)
  
  if [[ -n "${user_name}" ]] && [[ -n "${user_email}" ]]; then
    return 0
  fi
  
  return 1
}

component_git_config_install() {
  local user_name
  local user_email
  
  print_title "配置 Git"
  
  user_name=$(git config --global user.name 2>/dev/null || true)
  user_name=$(ask_input "请输入 Git 用户名" "${user_name:-}")
  
  if ! validate_git_username "${user_name}"; then
    print_error "无效的 Git 用户名"
    return 1
  fi
  
  user_email=$(git config --global user.email 2>/dev/null || true)
  user_email=$(ask_input "请输入 Git 邮箱" "${user_email:-}")
  
  if ! validate_email "${user_email}"; then
    print_error "无效的邮箱地址"
    return 1
  fi
  
  git config --global user.name "${user_name}"
  git config --global user.email "${user_email}"
  
  if [[ -f "${SCRIPT_DIR}/../../configs/git/gitconfig.template" ]]; then
    local gitconfig_template
    gitconfig_template=$(cat "${SCRIPT_DIR}/../../configs/git/gitconfig.template")
    gitconfig_template=${gitconfig_template//\{\{GIT_USER_NAME\}\}/${user_name}}
    gitconfig_template=${gitconfig_template//\{\{GIT_USER_EMAIL\}\}/${user_email}}
    
    local temp_file
    temp_file=$(mktemp)
    echo "${gitconfig_template}" > "${temp_file}"
    git config --global --replace-all include.path "${temp_file}" 2>/dev/null || true
    rm -f "${temp_file}"
  fi
  
  print_success "Git 配置完成"
  return 0
}
