#!/usr/bin/env bash
#
# 描述: 运行测试
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEST_DIR="${PROJECT_ROOT}/tests"

echo "Running tests..."
echo "=============="

TESTS_PASSED=0
TESTS_FAILED=0

# 运行所有单元测试
for test_file in "${TEST_DIR}/unit/"test_*.sh; do
  if [[ -f "${test_file}" ]]; then
    echo ""
    echo "Running: $(basename "${test_file}")"
    echo "----------------------------------------"
    if bash "${test_file}"; then
      ((TESTS_PASSED++))
    else
      ((TESTS_FAILED++))
    fi
  fi
done

# 运行所有集成测试
for test_file in "${TEST_DIR}/integration/"test_*.sh; do
  if [[ -f "${test_file}" ]]; then
    echo ""
    echo "Running: $(basename "${test_file}")"
    echo "----------------------------------------"
    if bash "${test_file}"; then
      ((TESTS_PASSED++))
    else
      ((TESTS_FAILED++))
    fi
  fi
done

# 运行所有端到端测试
for test_file in "${TEST_DIR}/e2e/"test_*.sh; do
  if [[ -f "${test_file}" ]]; then
    echo ""
    echo "Running: $(basename "${test_file}")"
    echo "----------------------------------------"
    if bash "${test_file}"; then
      ((TESTS_PASSED++))
    else
      ((TESTS_FAILED++))
    fi
  fi
done

echo ""
echo "=============="
echo "Test Summary:"
echo "  Passed: ${TESTS_PASSED}"
echo "  Failed: ${TESTS_FAILED}"
echo "=============="

if [[ ${TESTS_FAILED} -gt 0 ]]; then
  exit 1
fi
exit 0
