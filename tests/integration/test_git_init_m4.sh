#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# 加载测试工具
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test-utils.sh"

test_suite_start "M4 导入导出集成测试"

# 创建测试环境
TEST_DIR=$(create_temp_dir)
EXPORT_FILE="${TEST_DIR}/git-config-export.sh"
TEST_HOME="${TEST_DIR}/home"
mkdir -p "${TEST_HOME}"

echo "测试目录: ${TEST_DIR}"

# ============================================================================
# 测试 1: 基本导出功能测试
# ============================================================================
echo -e "\n--- 测试 1: 基本导出功能 ---"
# 在测试 home 下运行导出
HOME="${TEST_HOME}" /Users/bytedance/code/ops-toolkit/scripts/git-init.sh --export "${EXPORT_FILE}" 2>&1

assert_file_exists "${EXPORT_FILE}" "导出文件应该存在"

if [[ -x "${EXPORT_FILE}" ]]; then
  assert_true "true" "导出文件应该是可执行的"
else
  assert_true "false" "导出文件应该是可执行的"
fi

EXPORT_CONTENT=$(cat "${EXPORT_FILE}")
assert_contains "${EXPORT_CONTENT}" "GIT_INIT_CONFIG_MAIN_NAME" "导出文件应该包含主账户名称配置"
assert_contains "${EXPORT_CONTENT}" "GIT_INIT_CONFIG_MAIN_EMAIL" "导出文件应该包含主账户邮箱配置"

# ============================================================================
# 测试 2: 验证导出文件包含必要的变量
# ============================================================================
echo -e "\n--- 测试 2: 验证导出文件内容 ---"
assert_contains "${EXPORT_CONTENT}" "GIT_INIT_CONFIG_SSH_ALGORITHM" "应该包含 SSH 算法"
assert_contains "${EXPORT_CONTENT}" "GIT_INIT_CONFIG_GITIGNORE_ENABLED" "应该包含 .gitignore 启用状态"
assert_contains "${EXPORT_CONTENT}" "GIT_INIT_CONFIG_ALIASES_CONFIGURED" "应该包含别名配置状态"

# ============================================================================
# 测试 3: 验证导出文件不包含敏感信息
# ============================================================================
echo -e "\n--- 测试 3: 验证无敏感信息 ---"
if [[ "${EXPORT_CONTENT}" == *"PRIVATE KEY"* ]]; then
  assert_true "false" "导出文件不应该包含私钥"
else
  assert_true "true" "导出文件不包含私钥"
fi

# ============================================================================
# 清理
# ============================================================================
cleanup_temp_dir "${TEST_DIR}"

test_suite_end
