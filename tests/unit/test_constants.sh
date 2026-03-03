#!/usr/bin/env bash
#
# 描述: constants.sh 单元测试
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

# 加载测试工具
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../helpers/test-utils.sh"

# 主测试函数
run_tests() {
  test_suite_start "constants.sh 测试"

  # 测试 1: 检查 constants.sh 文件存在
  assert_file_exists "${SCRIPT_DIR}/../../lib/core/constants.sh" "constants.sh 文件应该存在"

  # 测试 2: 成功 source constants.sh
  source "${SCRIPT_DIR}/../../lib/core/constants.sh"
  local source_exit_code=$?
  assert_eq "${source_exit_code}" "0" "source constants.sh 应该成功"

  # 测试 3: 验证版本信息常量
  assert_eq "${VERSION}" "1.0.0" "VERSION 应该是 1.0.0"
  assert_eq "${SCRIPT_NAME}" "ops-toolkit" "SCRIPT_NAME 应该是 ops-toolkit"

  # 测试 4: 验证日志级别常量
  assert_eq "${LOG_LEVEL_DEBUG}" "0" "LOG_LEVEL_DEBUG 应该是 0"
  assert_eq "${LOG_LEVEL_INFO}" "1" "LOG_LEVEL_INFO 应该是 1"
  assert_eq "${LOG_LEVEL_WARN}" "2" "LOG_LEVEL_WARN 应该是 2"
  assert_eq "${LOG_LEVEL_ERROR}" "3" "LOG_LEVEL_ERROR 应该是 3"

  # 测试 5: 验证错误码常量
  assert_eq "${ERR_SUCCESS}" "0" "ERR_SUCCESS 应该是 0"
  assert_eq "${ERR_GENERAL}" "1" "ERR_GENERAL 应该是 1"
  assert_eq "${ERR_INVALID_ARG}" "2" "ERR_INVALID_ARG 应该是 2"
  assert_eq "${ERR_UNSUPPORTED_OS}" "10" "ERR_UNSUPPORTED_OS 应该是 10"

  # 测试 6: 验证支持的操作系统
  local os_count="${#SUPPORTED_OS[@]}"
  assert_true "[[ ${os_count} -gt 0 ]]" "SUPPORTED_OS 应该至少有一个元素"
  assert_contains "${SUPPORTED_OS[*]}" "macos" "SUPPORTED_OS 应该包含 macos"
  assert_contains "${SUPPORTED_OS[*]}" "ubuntu" "SUPPORTED_OS 应该包含 ubuntu"

  test_suite_end
}

# 运行测试
run_tests
