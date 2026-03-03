#!/usr/bin/env bash
#
# 描述: ShellCheck 检查
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Running ShellCheck..."
echo "===================="

# 检查所有 Shell 脚本
shellcheck \
  --shell=bash \
  --severity=warning \
  "${PROJECT_ROOT}/bin/"* \
  "${PROJECT_ROOT}/lib/"**/*.sh \
  "${PROJECT_ROOT}/tests/"**/*.sh \
  "${PROJECT_ROOT}/scripts/"*.sh 2>/dev/null || true

echo ""
echo "ShellCheck complete!"
