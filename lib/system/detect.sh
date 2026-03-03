#!/usr/bin/env bash
#
# 描述: 系统检测函数
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

# 加载核心库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../core/constants.sh"
source "${SCRIPT_DIR}/../core/logging.sh"

# ============================================================================
# 系统信息
# ============================================================================

SYSTEM_INFO_OS="unknown"
SYSTEM_INFO_OS_VERSION=""
SYSTEM_INFO_OS_NAME=""
SYSTEM_INFO_ARCH="unknown"
SYSTEM_INFO_PACKAGE_MANAGER="unknown"
SYSTEM_INFO_SUPPORTED="false"

# ============================================================================
# 系统检测函数
# ============================================================================

# 描述: 检测操作系统类型
# 返回: macos|ubuntu|debian|centos|unknown
detect_os() {
  local os="unknown"

  if [[ "$(uname -s)" == "Darwin" ]]; then
    os="macos"
  elif [[ -f "/etc/os-release" ]]; then
    local id
    id="$(grep -E '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')"
    case "${id}" in
      ubuntu)
        os="ubuntu"
        ;;
      debian)
        os="debian"
        ;;
      centos|rhel)
        os="centos"
        ;;
    esac
  fi

  echo "${os}"
}

# 描述: 检测 CPU 架构
# 返回: x86_64|arm64|unknown
detect_arch() {
  local arch="unknown"
  local machine
  machine="$(uname -m)"

  case "${machine}" in
    x86_64|amd64)
      arch="x86_64"
      ;;
    arm64|aarch64)
      arch="arm64"
      ;;
  esac

  echo "${arch}"
}

# 描述: 检测包管理器
# 返回: brew|apt|dnf|yum|unknown
detect_package_manager() {
  local pm="unknown"

  if command -v brew &>/dev/null; then
    pm="brew"
  elif command -v apt &>/dev/null; then
    pm="apt"
  elif command -v dnf &>/dev/null; then
    pm="dnf"
  elif command -v yum &>/dev/null; then
    pm="yum"
  fi

  echo "${pm}"
}

# 描述: 获取系统完整信息
# 返回: 填充系统信息变量
get_system_info() {
  SYSTEM_INFO_OS="$(detect_os)"
  SYSTEM_INFO_ARCH="$(detect_arch)"
  SYSTEM_INFO_PACKAGE_MANAGER="$(detect_package_manager)"

  if [[ "${SYSTEM_INFO_OS}" == "macos" ]]; then
    SYSTEM_INFO_OS_VERSION="$(sw_vers -productVersion 2>/dev/null || echo "")"
    SYSTEM_INFO_OS_NAME="$(sw_vers -productName 2>/dev/null || echo "macOS")"
  elif [[ -f "/etc/os-release" ]]; then
    SYSTEM_INFO_OS_VERSION="$(grep -E '^VERSION_ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"' 2>/dev/null || echo "")"
    SYSTEM_INFO_OS_NAME="$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d'=' -f2 | tr -d '"' 2>/dev/null || echo "Linux")"
  fi

  local os="${SYSTEM_INFO_OS}"
  for supported_os in "${SUPPORTED_OS[@]}"; do
    if [[ "${os}" == "${supported_os}" ]]; then
      SYSTEM_INFO_SUPPORTED="true"
      break
    fi
  done
}

# 描述: 检查系统是否支持
# 返回: 0 支持, 1 不支持
is_supported_os() {
  if [[ "${SYSTEM_INFO_SUPPORTED}" == "true" ]]; then
    return 0
  fi
  return 1
}
