#!/usr/bin/env bash
#
# 描述: init 流程集成测试
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../helpers/test-utils.sh"

run_tests() {
  test_suite_start "init 流程集成测试"
  
  assert_file_exists "${SCRIPT_DIR}/../../lib/init.sh" "init.sh 文件应该存在"
  assert_file_exists "${SCRIPT_DIR}/../../lib/list.sh" "list.sh 文件应该存在"
  
  if [[ -f "${SCRIPT_DIR}/../../lib/init.sh" ]]; then
    assert_cmd_success "source ${SCRIPT_DIR}/../../lib/init.sh" "应该能成功 source init.sh"
  fi
  
  if [[ -f "${SCRIPT_DIR}/../../lib/list.sh" ]]; then
    assert_cmd_success "source ${SCRIPT_DIR}/../../lib/list.sh" "应该能成功 source list.sh"
  fi
  
  test_suite_end
}

run_tests
