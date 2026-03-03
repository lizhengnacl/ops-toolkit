#!/usr/bin/env bash
#
# 描述: ssh-key 组件集成测试
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../helpers/test-utils.sh"

run_tests() {
  test_suite_start "ssh-key 组件测试"
  assert_file_exists "${SCRIPT_DIR}/../../components/shell-git/ssh-key.sh" "ssh-key.sh 文件应该存在"
  if [[ -f "${SCRIPT_DIR}/../../components/shell-git/ssh-key.sh" ]]; then
    assert_cmd_success "source ${SCRIPT_DIR}/../../components/shell-git/ssh-key.sh" "应该能成功 source ssh-key.sh"
  else
    echo -e "${COLOR_YELLOW}⚠️  跳过 source 测试（文件尚未创建）${COLOR_RESET}"
  fi
  test_suite_end
}

run_tests
