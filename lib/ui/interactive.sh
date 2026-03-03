#!/usr/bin/env bash
#
# 描述: 交互式 UI
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../core/constants.sh"

# 描述: 询问 yes/no 问题
# 参数:
#   $1 - 问题文本
#   $2 - 默认值 (y/n, 可选)
# 返回: 0 表示 yes, 1 表示 no
ask_yes_no() {
  local question="$1"
  local default="${2:-}"
  local prompt
  
  if [[ "${default}" == "y" ]]; then
    prompt="[Y/n]"
  elif [[ "${default}" == "n" ]]; then
    prompt="[y/N]"
  else
    prompt="[y/n]"
  fi
  
  while true; do
    read -p "${question} ${prompt} " answer
    answer=$(echo "${answer}" | tr '[:upper:]' '[:lower:]')
    
    if [[ -z "${answer}" ]]; then
      answer="${default}"
    fi
    
    case "${answer}" in
      y|yes)
        return 0
        ;;
      n|no)
        return 1
        ;;
      *)
        echo "请输入 y 或 n"
        ;;
    esac
  done
}

# 描述: 询问文本输入
# 参数:
#   $1 - 问题文本
#   $2 - 默认值 (可选)
# 返回: 用户输入的文本 (通过 stdout 输出)
ask_input() {
  local question="$1"
  local default="${2:-}"
  local answer
  
  if [[ -n "${default}" ]]; then
    read -p "${question} [${default}]: " answer
    answer=${answer:-${default}}
  else
    read -p "${question}: " answer
  fi
  
  echo "${answer}"
}

# 描述: 显示选择菜单
# 参数:
#   $1 - 提示文本
#   $@ - 选项列表
# 返回: 选中的选项索引 (通过 stdout 输出)
show_menu() {
  local prompt="$1"
  shift
  local options=("$@")
  local num_options=${#options[@]}
  
  echo ""
  echo "${prompt}"
  for i in $(seq 0 $((num_options - 1))); do
    echo "  $((i + 1)). ${options[$i]}"
  done
  
  while true; do
    read -p "请选择 (1-${num_options}): " choice
    if [[ "${choice}" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= num_options )); then
      echo $((choice - 1))
      return 0
    fi
    echo "请输入 1 到 ${num_options} 之间的数字"
  done
}
