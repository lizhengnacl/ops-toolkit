#!/usr/bin/env bash
#
# 描述: help 子命令实现
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

# 描述: 显示帮助信息
help_command() {
  cat << EOF
ops-toolkit - 快速初始化开发环境的命令行工具

用法:
  ops-toolkit <command> [options]

命令:
  init        交互式环境初始化
  list        列出所有可用组件
  version     显示版本信息
  help        显示此帮助信息
  uninstall   卸载工具

全局选项:
  -h, --help     显示帮助信息
  -v, --version  显示版本信息

示例:
  ops-toolkit init
  ops-toolkit list
  ops-toolkit version

EOF
}
