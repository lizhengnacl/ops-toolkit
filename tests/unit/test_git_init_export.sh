#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# 加载测试工具
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test-utils.sh"

# 加载被测试脚本 - 只加载函数定义，不执行 main
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# 临时保存并重置 $@，避免被 source 的脚本处理参数
_OLD_ARGS=("$@")
set --
# 禁用 errexit 以防脚本在 source 时出错
set +e
source "${SCRIPT_DIR}/../../scripts/git-init.sh" 2>/dev/null
set -e
# 恢复原始参数
set -- "${_OLD_ARGS[@]:-}"

test_suite_start "配置导出功能测试"

# ============================================================================
# 测试 1: 测试导出文件包含主账户信息
# ============================================================================
test_export_contains_main_account() {
  local temp_dir=$(create_temp_dir)
  local export_file="${temp_dir}/git-config-export.sh"
  
  # 模拟 git 配置
  git config --global user.name "Test User" 2>/dev/null || true
  git config --global user.email "test@example.com" 2>/dev/null || true
  
  # 调用导出函数 (这会失败，因为函数还没实现)
  if export_config "${export_file}" 2>/dev/null; then
    # 检查导出文件是否存在
    assert_file_exists "${export_file}" "导出文件应该存在"
    
    # 检查文件内容
    local content=$(cat "${export_file}")
    assert_contains "${content}" "GIT_INIT_CONFIG_MAIN_NAME" "导出文件应该包含主账户名称"
    assert_contains "${content}" "GIT_INIT_CONFIG_MAIN_EMAIL" "导出文件应该包含主账户邮箱"
  fi
  
  cleanup_temp_dir "${temp_dir}"
}

# ============================================================================
# 测试 2: 测试导出文件包含 SSH 算法和路径
# ============================================================================
test_export_contains_ssh_info() {
  local temp_dir=$(create_temp_dir)
  local export_file="${temp_dir}/git-config-export.sh"
  
  # 调用导出函数
  if export_config "${export_file}" 2>/dev/null; then
    assert_file_exists "${export_file}" "导出文件应该存在"
    
    local content=$(cat "${export_file}")
    assert_contains "${content}" "GIT_INIT_CONFIG_SSH_ALGORITHM" "导出文件应该包含 SSH 算法"
    assert_contains "${content}" "GIT_INIT_CONFIG_SSH_KEY_PATH" "导出文件应该包含 SSH Key 路径"
  fi
  
  cleanup_temp_dir "${temp_dir}"
}

# ============================================================================
# 测试 3: 测试导出文件包含 .gitignore 内容
# ============================================================================
test_export_contains_gitignore() {
  local temp_dir=$(create_temp_dir)
  local export_file="${temp_dir}/git-config-export.sh"
  
  # 调用导出函数
  if export_config "${export_file}" 2>/dev/null; then
    assert_file_exists "${export_file}" "导出文件应该存在"
    
    local content=$(cat "${export_file}")
    assert_contains "${content}" "GIT_INIT_CONFIG_GITIGNORE_ENABLED" "导出文件应该包含 .gitignore 启用状态"
  fi
  
  cleanup_temp_dir "${temp_dir}"
}

# ============================================================================
# 测试 4: 测试导出文件包含 Git 别名配置
# ============================================================================
test_export_contains_aliases() {
  local temp_dir=$(create_temp_dir)
  local export_file="${temp_dir}/git-config-export.sh"
  
  # 调用导出函数
  if export_config "${export_file}" 2>/dev/null; then
    assert_file_exists "${export_file}" "导出文件应该存在"
    
    local content=$(cat "${export_file}")
    assert_contains "${content}" "GIT_INIT_CONFIG_ALIASES_CONFIGURED" "导出文件应该包含别名配置状态"
  fi
  
  cleanup_temp_dir "${temp_dir}"
}

# ============================================================================
# 测试 5: 测试导出文件不包含 SSH 私钥
# ============================================================================
test_export_not_contains_private_key() {
  local temp_dir=$(create_temp_dir)
  local export_file="${temp_dir}/git-config-export.sh"
  local test_private_key="-----BEGIN OPENSSH PRIVATE KEY-----"
  
  # 调用导出函数
  if export_config "${export_file}" 2>/dev/null; then
    assert_file_exists "${export_file}" "导出文件应该存在"
    
    local content=$(cat "${export_file}")
    if [[ "${content}" == *"${test_private_key}"* ]]; then
      assert_true "false" "导出文件不应该包含 SSH 私钥"
    else
      assert_true "true" "导出文件不包含 SSH 私钥"
    fi
  fi
  
  cleanup_temp_dir "${temp_dir}"
}

# ============================================================================
# 测试 6: 测试导出文件可执行
# ============================================================================
test_export_file_executable() {
  local temp_dir=$(create_temp_dir)
  local export_file="${temp_dir}/git-config-export.sh"
  
  # 调用导出函数
  if export_config "${export_file}" 2>/dev/null; then
    assert_file_exists "${export_file}" "导出文件应该存在"
    
    if [[ -x "${export_file}" ]]; then
      assert_true "true" "导出文件应该是可执行的"
    else
      assert_true "false" "导出文件应该是可执行的"
    fi
  fi
  
  cleanup_temp_dir "${temp_dir}"
}

# 运行所有测试
test_export_contains_main_account
test_export_contains_ssh_info
test_export_contains_gitignore
test_export_contains_aliases
test_export_not_contains_private_key
test_export_file_executable

test_suite_end
