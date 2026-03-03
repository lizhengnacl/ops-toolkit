#!/usr/bin/env bash
#
# 描述: 测试工具函数
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# 测试统计变量
# ============================================================================

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# ============================================================================
# 颜色输出
# ============================================================================

COLOR_RESET="\033[0m"
COLOR_GREEN="\033[32m"
COLOR_RED="\033[31m"
COLOR_YELLOW="\033[33m"
COLOR_CYAN="\033[36m"

# ============================================================================
# 测试断言函数
# ============================================================================

# 描述: 断言条件为真
# 参数:
#   $1 - 条件表达式
#   $2 - 测试描述 (可选)
assert_true() {
  local condition="$1"
  local description="${2:-}"
  ((TESTS_TOTAL++))

  if [[ "${condition}" == "0" ]] || [[ "${condition}" == "true" ]]; then
    ((TESTS_PASSED++))
    echo -e "${COLOR_GREEN}✓ PASS${COLOR_RESET}: ${description:-${condition}}"
  elif (eval "${condition}") 2>/dev/null; then
    ((TESTS_PASSED++))
    echo -e "${COLOR_GREEN}✓ PASS${COLOR_RESET}: ${description:-${condition}}"
  else
    ((TESTS_FAILED++))
    echo -e "${COLOR_RED}✗ FAIL${COLOR_RESET}: ${description:-${condition}}"
  fi
}

# 描述: 断言两个值相等
# 参数:
#   $1 - 实际值
#   $2 - 期望值
#   $3 - 测试描述 (可选)
assert_eq() {
  local actual="$1"
  local expected="$2"
  local description="${3:-}"
  ((TESTS_TOTAL++))

  if [[ "${actual}" == "${expected}" ]]; then
    ((TESTS_PASSED++))
    echo -e "${COLOR_GREEN}✓ PASS${COLOR_RESET}: ${description:-expected ${expected}}"
  else
    ((TESTS_FAILED++))
    echo -e "${COLOR_RED}✗ FAIL${COLOR_RESET}: ${description:-}"
    echo -e "  Expected: ${COLOR_CYAN}${expected}${COLOR_RESET}"
    echo -e "  Actual:   ${COLOR_YELLOW}${actual}${COLOR_RESET}"
  fi
}

# 描述: 断言命令成功执行 (退出码 0)
# 参数:
#   $1 - 命令
#   $2 - 测试描述 (可选)
assert_cmd_success() {
  local cmd="$1"
  local description="${2:-}"
  ((TESTS_TOTAL++))

  if eval "${cmd}" >/dev/null 2>&1; then
    ((TESTS_PASSED++))
    echo -e "${COLOR_GREEN}✓ PASS${COLOR_RESET}: ${description:-command succeeded}"
  else
    ((TESTS_FAILED++))
    echo -e "${COLOR_RED}✗ FAIL${COLOR_RESET}: ${description:-command failed}"
  fi
}

# 描述: 断言命令失败 (退出码非 0)
# 参数:
#   $1 - 命令
#   $2 - 测试描述 (可选)
assert_cmd_fail() {
  local cmd="$1"
  local description="${2:-}"
  ((TESTS_TOTAL++))

  if ! eval "${cmd}" >/dev/null 2>&1; then
    ((TESTS_PASSED++))
    echo -e "${COLOR_GREEN}✓ PASS${COLOR_RESET}: ${description:-command failed as expected}"
  else
    ((TESTS_FAILED++))
    echo -e "${COLOR_RED}✗ FAIL${COLOR_RESET}: ${description:-command succeeded unexpectedly}"
  fi
}

# 描述: 断言字符串包含子串
# 参数:
#   $1 - 实际字符串
#   $2 - 期望包含的子串
#   $3 - 测试描述 (可选)
assert_contains() {
  local actual="$1"
  local substring="$2"
  local description="${3:-}"
  ((TESTS_TOTAL++))

  if [[ "${actual}" == *"${substring}"* ]]; then
    ((TESTS_PASSED++))
    echo -e "${COLOR_GREEN}✓ PASS${COLOR_RESET}: ${description:-contains '${substring}'}"
  else
    ((TESTS_FAILED++))
    echo -e "${COLOR_RED}✗ FAIL${COLOR_RESET}: ${description:-}"
    echo -e "  Expected to contain: ${COLOR_CYAN}${substring}${COLOR_RESET}"
    echo -e "  Actual:             ${COLOR_YELLOW}${actual}${COLOR_RESET}"
  fi
}

# 描述: 断言文件存在
# 参数:
#   $1 - 文件路径
#   $2 - 测试描述 (可选)
assert_file_exists() {
  local file="$1"
  local description="${2:-}"
  ((TESTS_TOTAL++))

  if [[ -f "${file}" ]]; then
    ((TESTS_PASSED++))
    echo -e "${COLOR_GREEN}✓ PASS${COLOR_RESET}: ${description:-file exists: ${file}}"
  else
    ((TESTS_FAILED++))
    echo -e "${COLOR_RED}✗ FAIL${COLOR_RESET}: ${description:-file not found: ${file}}"
  fi
}

# 描述: 断言目录存在
# 参数:
#   $1 - 目录路径
#   $2 - 测试描述 (可选)
assert_dir_exists() {
  local dir="$1"
  local description="${2:-}"
  ((TESTS_TOTAL++))

  if [[ -d "${dir}" ]]; then
    ((TESTS_PASSED++))
    echo -e "${COLOR_GREEN}✓ PASS${COLOR_RESET}: ${description:-directory exists: ${dir}}"
  else
    ((TESTS_FAILED++))
    echo -e "${COLOR_RED}✗ FAIL${COLOR_RESET}: ${description:-directory not found: ${dir}}"
  fi
}

# ============================================================================
# 测试套件函数
# ============================================================================

# 描述: 开始测试套件
# 参数:
#   $1 - 测试套件名称
test_suite_start() {
  local suite_name="$1"
  echo ""
  echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
  echo -e "${COLOR_CYAN}测试套件: ${suite_name}${COLOR_RESET}"
  echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
  TESTS_PASSED=0
  TESTS_FAILED=0
  TESTS_TOTAL=0
}

# 描述: 结束测试套件并打印摘要
test_suite_end() {
  echo ""
  echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
  echo -e "测试结果:"
  echo -e "  ${COLOR_GREEN}通过: ${TESTS_PASSED}${COLOR_RESET}"
  echo -e "  ${COLOR_RED}失败: ${TESTS_FAILED}${COLOR_RESET}"
  echo -e "  总计: ${TESTS_TOTAL}"
  echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
  echo ""

  if [[ ${TESTS_FAILED} -gt 0 ]]; then
    return 1
  fi
  return 0
}

# 描述: 创建临时目录
# 返回: 临时目录路径
create_temp_dir() {
  local temp_dir
  temp_dir="$(mktemp -d -t ops-toolkit-test.XXXXXX)"
  echo "${temp_dir}"
}

# 描述: 清理临时目录
# 参数:
#   $1 - 临时目录路径
cleanup_temp_dir() {
  local temp_dir="$1"
  if [[ -d "${temp_dir}" ]]; then
    rm -rf "${temp_dir}"
  fi
}
