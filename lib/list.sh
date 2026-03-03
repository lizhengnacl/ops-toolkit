#!/usr/bin/env bash
#
# 描述: list 子命令 - 列出可用组件
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

COLOR_RESET="\033[0m"
COLOR_BOLD="\033[1m"
COLOR_CYAN="\033[36m"

print_title() {
  local title="$1"
  echo ""
  echo -e "${COLOR_BOLD}${COLOR_CYAN}${title}${COLOR_RESET}"
}

print_separator() {
  local char="${1:-─}"
  local length="${2:-40}"
  printf "%${length}s\n" | tr ' ' "${char}"
}

cmd_list() {
  print_title "可用组件"
  
  print_separator
  echo -e "${COLOR_BOLD}Shell 和 Git 工具${COLOR_RESET}"
  echo "Shell 环境配置和 Git 相关工具"
  echo -e "  ${COLOR_CYAN}● Git 配置${COLOR_RESET}"
  echo -e "    配置 Git 用户信息和常用别名"
  echo -e "  ${COLOR_CYAN}● SSH Key${COLOR_RESET}"
  echo -e "    生成和配置 SSH Key"
  echo -e "  ${COLOR_CYAN}● Zsh + Oh My Zsh${COLOR_RESET}"
  echo -e "    安装 Zsh 和 Oh My Zsh"
  echo -e "  ${COLOR_CYAN}● Zsh 插件${COLOR_RESET}"
  echo -e "    配置 Zsh 常用插件"
  echo -e "    依赖: zsh-ohmyzsh"
  echo -e "  ${COLOR_CYAN}● Bash 增强${COLOR_RESET}"
  echo -e "    增强 Bash 配置和别名"
  
  print_separator
  echo -e "${COLOR_BOLD}编辑器配置${COLOR_RESET}"
  echo "Vim、Neovim、VSCode 等编辑器的配置"
  echo -e "  ${COLOR_CYAN}● Vim 基础配置${COLOR_RESET}"
  echo -e "    配置 Vim 基础设置和插件"
  echo -e "  ${COLOR_CYAN}● Neovim 配置${COLOR_RESET}"
  echo -e "    配置 Neovim"
  echo -e "  ${COLOR_CYAN}● VSCode 扩展${COLOR_RESET}"
  echo -e "    安装常用 VSCode 扩展"
  
  print_separator
  return 0
}
