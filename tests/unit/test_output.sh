#!/usr/bin/env bash
#
# 描述: output.sh 单元测试
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
  test_suite_start "output.sh 测试"

  # 测试 1: 检查 output.sh 文件存在
  assert_file_exists "${SCRIPT_DIR}/../../lib/ui/output.sh" "output.sh 文件应该存在"

  # 测试 2: 如果文件存在，尝试 source 它（红灯阶段预期会失败或部分功能不完整）
  if [[ -f "${SCRIPT_DIR}/../../lib/ui/output.sh" ]]; then
    assert_cmd_success "source ${SCRIPT_DIR}/../../lib/ui/output.sh" "应该能成功 source output.sh"
  else
    echo -e "${COLOR_YELLOW}⚠️  跳过 source 测试（文件尚未创建）${COLOR_RESET}"
  fi

  test_suite_end
}

# 运行测试
run_tests
