#!/usr/bin/env bash
#
# 描述: executor.sh 单元测试
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../helpers/test-utils.sh"

run_tests() {
  test_suite_start "executor.sh 测试"

  assert_file_exists "${SCRIPT_DIR}/../../lib/component/executor.sh" "executor.sh 文件应该存在"
  
  if [[ -f "${SCRIPT_DIR}/../../lib/component/executor.sh" ]]; then
    assert_cmd_success "source ${SCRIPT_DIR}/../../lib/component/executor.sh" "应该能成功 source executor.sh"
  else
    echo -e "${COLOR_YELLOW}⚠️  跳过 source 测试（文件尚未创建）${COLOR_RESET}"
  fi

  test_suite_end
}

run_tests
