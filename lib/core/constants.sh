#!/usr/bin/env bash
#
# 描述: 全局常量定义
# 作者: ops-toolkit
# 日期: 2026-03-03
#

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# 版本信息
# ============================================================================

if [[ -z "${VERSION:-}" ]]; then
  readonly VERSION="1.0.0"
fi
if [[ -z "${SCRIPT_NAME:-}" ]]; then
  readonly SCRIPT_NAME="ops-toolkit"
fi

# ============================================================================
# 目录路径
# ============================================================================

if [[ -z "${INSTALL_DIR:-}" ]]; then
  readonly INSTALL_DIR="${HOME}/.local/lib/ops-toolkit"
fi
if [[ -z "${BIN_DIR:-}" ]]; then
  readonly BIN_DIR="${HOME}/.local/bin"
fi
if [[ -z "${LOG_DIR:-}" ]]; then
  readonly LOG_DIR="${HOME}/.cache/ops-toolkit/logs"
fi
if [[ -z "${CONFIG_DIR:-}" ]]; then
  readonly CONFIG_DIR="${HOME}/.config/ops-toolkit"
fi
if [[ -z "${TEMP_DIR:-}" ]]; then
  readonly TEMP_DIR="${HOME}/.cache/ops-toolkit/tmp"
fi

# ============================================================================
# 日志级别
# ============================================================================

if [[ -z "${LOG_LEVEL_DEBUG:-}" ]]; then
  readonly LOG_LEVEL_DEBUG=0
fi
if [[ -z "${LOG_LEVEL_INFO:-}" ]]; then
  readonly LOG_LEVEL_INFO=1
fi
if [[ -z "${LOG_LEVEL_WARN:-}" ]]; then
  readonly LOG_LEVEL_WARN=2
fi
if [[ -z "${LOG_LEVEL_ERROR:-}" ]]; then
  readonly LOG_LEVEL_ERROR=3
fi

# ============================================================================
# 支持的操作系统
# ============================================================================

if [[ -z "${SUPPORTED_OS:-}" ]]; then
  readonly SUPPORTED_OS=("macos" "ubuntu" "debian" "centos")
fi

# ============================================================================
# 错误码
# ============================================================================

if [[ -z "${ERR_SUCCESS:-}" ]]; then
  readonly ERR_SUCCESS=0
fi
if [[ -z "${ERR_GENERAL:-}" ]]; then
  readonly ERR_GENERAL=1
fi
if [[ -z "${ERR_INVALID_ARG:-}" ]]; then
  readonly ERR_INVALID_ARG=2
fi
if [[ -z "${ERR_UNSUPPORTED_OS:-}" ]]; then
  readonly ERR_UNSUPPORTED_OS=10
fi
if [[ -z "${ERR_MISSING_DEP:-}" ]]; then
  readonly ERR_MISSING_DEP=11
fi
if [[ -z "${ERR_COMPONENT_DETECT:-}" ]]; then
  readonly ERR_COMPONENT_DETECT=20
fi
if [[ -z "${ERR_COMPONENT_INSTALL:-}" ]]; then
  readonly ERR_COMPONENT_INSTALL=21
fi
if [[ -z "${ERR_DEPENDENCY:-}" ]]; then
  readonly ERR_DEPENDENCY=22
fi
if [[ -z "${ERR_NETWORK:-}" ]]; then
  readonly ERR_NETWORK=30
fi
if [[ -z "${ERR_PERMISSION:-}" ]]; then
  readonly ERR_PERMISSION=31
fi
