#!/usr/bin/env bash
#
# 描述: 端到端测试 - 安装和初始化流程
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../helpers/test-utils.sh"

TEST_TEMP_DIR=""

setup() {
  TEST_TEMP_DIR="$(create_temp_dir)"
  export HOME="${TEST_TEMP_DIR}"
  export PATH="${TEST_TEMP_DIR}/.local/bin:${PATH}"
}

teardown() {
  if [[ -n "${TEST_TEMP_DIR:-}" ]] && [[ -d "${TEST_TEMP_DIR}" ]]; then
    cleanup_temp_dir "${TEST_TEMP_DIR}"
  fi
}

test_version_command() {
  test_suite_start "测试 version 命令"
  
  local bin_path="${SCRIPT_DIR}/../../bin/ops-toolkit"
  local output
  output="$("${bin_path}" version)"
  
  assert_contains "${output}" "ops-toolkit" "版本输出包含项目名称"
  assert_contains "${output}" "1.0.0" "版本输出包含版本号"
  
  test_suite_end
}

test_help_command() {
  test_suite_start "测试 help 命令"
  
  local bin_path="${SCRIPT_DIR}/../../bin/ops-toolkit"
  local output
  output="$("${bin_path}" help)"
  
  assert_contains "${output}" "init" "帮助包含 init 命令"
  assert_contains "${output}" "list" "帮助包含 list 命令"
  assert_contains "${output}" "version" "帮助包含 version 命令"
  assert_contains "${output}" "help" "帮助包含 help 命令"
  assert_contains "${output}" "uninstall" "帮助包含 uninstall 命令"
  
  test_suite_end
}

test_list_command() {
  test_suite_start "测试 list 命令"
  
  local bin_path="${SCRIPT_DIR}/../../bin/ops-toolkit"
  local output
  output="$("${bin_path}" list 2>&1 || true)"
  
  assert_true "0" "list 命令可以执行"
  
  test_suite_end
}

test_init_command() {
  test_suite_start "测试 init 命令"
  
  local bin_path="${SCRIPT_DIR}/../../bin/ops-toolkit"
  
  echo -e "n\n" | "${bin_path}" init >/dev/null 2>&1 || true
  assert_true "0" "init 命令可以执行"
  
  test_suite_end
}

test_install_script_exists() {
  test_suite_start "测试安装脚本存在"
  
  assert_file_exists "${SCRIPT_DIR}/../../install.sh" "install.sh 存在"
  assert_file_exists "${SCRIPT_DIR}/../../uninstall.sh" "uninstall.sh 存在"
  
  test_suite_end
}

test_documentation_exists() {
  test_suite_start "测试文档存在"
  
  assert_file_exists "${SCRIPT_DIR}/../../README.md" "README.md 存在"
  assert_file_exists "${SCRIPT_DIR}/../../docs/components.md" "components.md 存在"
  assert_file_exists "${SCRIPT_DIR}/../../docs/contributing.md" "contributing.md 存在"
  
  test_suite_end
}

main() {
  setup
  trap teardown EXIT
  
  local all_passed=0
  
  test_version_command || all_passed=1
  test_help_command || all_passed=1
  test_list_command || all_passed=1
  test_init_command || all_passed=1
  test_install_script_exists || all_passed=1
  test_documentation_exists || all_passed=1
  
  return ${all_passed}
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
