# ops-toolkit 技术实现方案

> 版本: 1.0.0
> 日期: 2026-03-03
> 状态: 待执行

---

## 1. 技术上下文总结

### 1.1 技术选型

本项目基于以下技术选型：

| 类别 | 选型 | 说明 |
|------|------|------|
| **编程语言** | Bash | 跨平台兼容性好，无需额外运行时 |
| **Shell 版本** | Bash 4.0+ | 支持高级特性，兼容 macOS/Linux |
| **依赖管理** | 无外部依赖 | 保持项目轻量，仅依赖系统内置工具 |
| **测试框架** | ShellUnit (自定义) | 轻量级测试框架 |
| **代码检查** | ShellCheck | 静态分析工具 |

### 1.2 核心约束

- 必须遵循 `constitution.md` 定义的脚本编写规范
- 必须支持 macOS 12.0+ 和 Linux (Ubuntu 20.04+, Debian 11+, CentOS 8+)
- 启动时间 < 500ms
- 单组件检测 < 100ms

---

## 2. "合宪性"审查

### 2.1 可读性原则检查

| 宪法条款 | 符合情况 | 说明 |
|----------|----------|------|
| 使用有意义的变量名 | ✅ | 所有变量遵循 snake_case，常量使用 UPPER_SNAKE_CASE |
| 布尔变量使用肯定形式 | ✅ | 如 `is_installed`、`has_permission` |
| 一致的缩进（2 空格） | ✅ | 项目统一使用 2 空格缩进 |
| 行长度 ≤ 100 字符 | ✅ | 超长行合理换行 |
| 函数必须有文档注释 | ✅ | 所有公共函数包含描述、参数、返回值、示例 |
| 注释解释"为什么"而非"是什么" | ✅ | 注释聚焦决策原因而非代码重复 |

### 2.2 可维护性原则检查

| 宪法条款 | 符合情况 | 说明 |
|----------|----------|------|
| 单一职责原则 | ✅ | 每个函数只做一件事，如 `detect_os()`、`log_info()` |
| 函数长度 ≤ 50 行 | ✅ | 超过时拆分为子函数 |
| 嵌套深度 ≤ 3 层 | ✅ | 使用提前返回避免深层嵌套 |
| 配置与代码分离 | ✅ | 配置模板存放于 `configs/` 目录 |
| 默认值处理 | ✅ | 使用 `${VAR:-default}` 提供合理默认值 |
| 版本控制友好 | ✅ | 小文件、有意义的提交信息 |

### 2.3 健壮性原则检查

| 宪法条款 | 符合情况 | 说明 |
|----------|----------|------|
| 启用严格模式 `set -euo pipefail` | ✅ | 所有脚本头部启用 |
| 验证所有外部输入 | ✅ | 路径检查、参数数量验证 |
| 检查命令执行结果 | ✅ | 使用 `command -v` 检查依赖 |
| 使用 trap 清理资源 | ✅ | `cleanup()` 函数 + `trap cleanup EXIT` |
| 分级日志（DEBUG/INFO/WARN/ERROR） | ✅ | 结构化日志含时间戳、级别、来源 |
| 设置超时 | ✅ | 网络操作使用 `--max-time` 和 `timeout` |
| 限制重试 | ✅ | 重试次数和间隔有上限 |

### 2.4 可移植性原则检查

| 宪法条款 | 符合情况 | 说明 |
|----------|----------|------|
| 使用 `#!/usr/bin/env bash` | ✅ | 所有脚本使用 env 调用解释器 |
| 不硬编码路径 | ✅ | 动态获取脚本目录 `${SCRIPT_DIR}` |
| 优先 POSIX 兼容语法 | ✅ | 必要时使用 Bash 特性但保持安全 |
| 检查命令存在性 | ✅ | 如 gsed vs sed 兼容性处理 |
| 不假设特定用户/主机名/时区 | ✅ | 使用 UTC 或明确指定时区 |
| 强制 `LC_ALL=C` | ✅ | 确保一致的行为 |

### 合宪性审查结论

✅ **本技术方案完全符合 constitution.md 的所有条款。**

---

## 3. 项目结构细化

### 3.1 完整目录树

```
ops-toolkit/
├── .gitignore
├── CLAUDE.md
├── constitution.md
├── README.md
│
├── install.sh                          # curl 安装入口
├── uninstall.sh                        # 卸载脚本
│
├── bin/
│   └── ops-toolkit                     # CLI 主入口 (可执行)
│
├── lib/                                # 核心库
│   ├── init.sh                         # init 子命令实现
│   ├── list.sh                         # list 子命令实现
│   ├── version.sh                      # version 子命令实现
│   ├── help.sh                         # help 子命令实现
│   │
│   ├── core/
│   │   ├── constants.sh                # 全局常量定义
│   │   ├── logging.sh                  # 日志系统
│   │   ├── utils.sh                    # 通用工具函数
│   │   └── validation.sh               # 参数校验函数
│   │
│   ├── system/
│   │   ├── detect.sh                   # 系统检测
│   │   └── prerequisites.sh            # 依赖检查
│   │
│   ├── ui/
│   │   ├── interactive.sh              # 交互式选择界面
│   │   ├── output.sh                   # 输出格式化
│   │   └── progress.sh                 # 进度显示
│   │
│   └── component/
│       ├── registry.sh                 # 组件注册表
│       ├── executor.sh                 # 组件执行器
│       └── detector.sh                 # 组件状态检测器
│
├── components/                         # 内置组件
│   ├── _base.sh                        # 组件基类
│   │
│   ├── shell-git/                      # Shell 与 Git 类别
│   │   ├── _category.sh
│   │   ├── git-config.sh
│   │   ├── ssh-key.sh
│   │   ├── zsh-ohmyzsh.sh
│   │   ├── zsh-plugins.sh
│   │   └── bash-enhanced.sh
│   │
│   └── editor/                         # 编辑器配置类别
│       ├── _category.sh
│       ├── vim-basic.sh
│       ├── neovim-config.sh
│       └── vscode-extensions.sh
│
├── configs/                            # 配置模板
│   ├── git/
│   │   └── gitconfig.template
│   ├── zsh/
│   │   └── zshrc.append
│   ├── bash/
│   │   └── bashrc.append
│   └── vim/
│       └── vimrc.template
│
├── tests/                              # 测试
│   ├── helpers/
│   │   └── test-utils.sh
│   ├── unit/
│   │   ├── test_logging.sh
│   │   ├── test_detect.sh
│   │   └── test_utils.sh
│   └── integration/
│       └── test_init_flow.sh
│
├── scripts/                            # 开发脚本
│   ├── lint.sh                         # ShellCheck 检查
│   └── test.sh                         # 运行测试
│
└── specs/                              # 规格文档
    └── 001-core-functionality/
        ├── spec.md
        ├── plan.md
        └── api-sketch.md
```

### 3.2 模块职责划分

| 模块 | 职责 | 关键文件 |
|------|------|----------|
| **CLI 入口** | 命令解析、路由分发 | `bin/ops-toolkit` |
| **核心库** | 常量、日志、工具函数 | `lib/core/*` |
| **系统检测** | OS、架构、包管理器检测 | `lib/system/detect.sh` |
| **UI 层** | 交互式选择、输出格式化 | `lib/ui/*` |
| **组件系统** | 注册、检测、执行组件 | `lib/component/*` |
| **组件实现** | 各组件具体逻辑 | `components/*` |
| **配置模板** | 配置文件模板 | `configs/*` |

---

## 4. 核心数据结构

### 4.1 系统信息 (SYSTEM_INFO)

```bash
# 关联数组存储系统信息
declare -gA SYSTEM_INFO=(
  ["os"]="macos"                    # macos|ubuntu|debian|centos|unknown
  ["os_version"]="14.3"             # 操作系统版本
  ["os_name"]="Sonoma"              # 操作系统名称
  ["arch"]="arm64"                  # x86_64|arm64|unknown
  ["package_manager"]="brew"        # brew|apt|dnf|yum|unknown
  ["supported"]="true"               # 是否支持
)
```

### 4.2 组件元数据 (COMPONENT_META)

```bash
# 单个组件元数据
declare -gA COMPONENT_META=(
  ["id"]="git-config"
  ["name"]="Git 配置"
  ["desc"]="配置 Git 用户信息和常用别名"
  ["category"]="shell-git"
  ["deps"]=""                        # 逗号分隔的依赖 ID
  ["path"]=""                        # 组件脚本路径
  ["status"]="unknown"               # unknown|installed|not_installed
  ["selected"]="false"               # 用户是否选中
)
```

### 4.3 组件注册表 (COMPONENT_REGISTRY)

```bash
# 所有组件 ID 列表
declare -ga ALL_COMPONENTS=()

# 类别 → 组件 ID 映射
declare -gA CATEGORY_COMPONENTS=()

# 组件 ID → 元数据映射 (JSON 字符串)
declare -gA COMPONENTS=()

# 所有类别
declare -ga ALL_CATEGORIES=()

# 类别元数据
declare -gA CATEGORIES=()
```

### 4.4 执行结果 (EXECUTION_SUMMARY)

```bash
# 执行摘要
declare -gA EXECUTION_SUMMARY=(
  ["total"]="0"
  ["success"]="0"
  ["skipped"]="0"
  ["failed"]="0"
)

# 单个组件执行结果
declare -gA EXEC_RESULT=(
  ["component_id"]="git-config"
  ["status"]="success"              # success|skipped|failed
  ["message"]="配置完成"
  ["duration"]="1.2"                # 秒
  ["error"]=""                       # 错误信息（如失败）
)

# 所有执行结果数组
declare -ga ALL_EXEC_RESULTS=()
```

### 4.5 日志上下文 (LOG_CONTEXT)

```bash
declare -gA LOG_CONTEXT=(
  ["level"]="INFO"                   # DEBUG|INFO|WARN|ERROR
  ["file"]=""                         # 日志文件路径
  ["enabled"]="true"                  # 是否启用文件日志
  ["color"]="true"                    # 是否启用颜色输出
)
```

---

## 5. 接口设计

### 5.1 CLI 入口接口

**文件**: `bin/ops-toolkit`

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# 描述: ops-toolkit 主入口
# 用法: ops-toolkit <command> [options]
# 命令: init|list|version|help|uninstall

main() {
  local command="${1:-help}"

  case "${command}" in
    init)
      source "${LIB_DIR}/init.sh"
      init_command "$@"
      ;;
    list)
      source "${LIB_DIR}/list.sh"
      list_command "$@"
      ;;
    version)
      source "${LIB_DIR}/version.sh"
      version_command
      ;;
    help)
      source "${LIB_DIR}/help.sh"
      help_command
      ;;
    uninstall)
      source "${LIB_DIR}/uninstall.sh"
      uninstall_command
      ;;
    *)
      log_error "Unknown command: ${command}"
      help_command
      exit 1
      ;;
  esac
}

main "$@"
```

### 5.2 核心库接口

#### 5.2.1 常量定义 (`lib/core/constants.sh`)

```bash
# 版本信息
readonly VERSION="1.0.0"
readonly SCRIPT_NAME="ops-toolkit"

# 目录路径
readonly INSTALL_DIR="${HOME}/.local/lib/ops-toolkit"
readonly BIN_DIR="${HOME}/.local/bin"
readonly LOG_DIR="${HOME}/.cache/ops-toolkit/logs"
readonly CONFIG_DIR="${HOME}/.config/ops-toolkit"
readonly TEMP_DIR="${HOME}/.cache/ops-toolkit/tmp"

# 日志级别
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3

# 支持的操作系统
readonly SUPPORTED_OS=("macos" "ubuntu" "debian" "centos")

# 错误码
readonly ERR_SUCCESS=0
readonly ERR_GENERAL=1
readonly ERR_INVALID_ARG=2
readonly ERR_UNSUPPORTED_OS=10
readonly ERR_MISSING_DEP=11
readonly ERR_COMPONENT_DETECT=20
readonly ERR_COMPONENT_INSTALL=21
readonly ERR_DEPENDENCY=22
readonly ERR_NETWORK=30
readonly ERR_PERMISSION=31
```

#### 5.2.2 日志系统 (`lib/core/logging.sh`)

```bash
# 描述: 初始化日志系统
# 参数:
#   $1 - 日志级别 (DEBUG|INFO|WARN|ERROR)
#   $2 - 日志文件路径 (可选)
# 返回: 0
log_init() { ... }

# 描述: 输出 DEBUG 级别日志
# 参数: $* - 日志内容
log_debug() { ... }

# 描述: 输出 INFO 级别日志
# 参数: $* - 日志内容
log_info() { ... }

# 描述: 输出 WARN 级别日志
# 参数: $* - 日志内容
log_warn() { ... }

# 描述: 输出 ERROR 级别日志
# 参数: $* - 日志内容
log_error() { ... }

# 描述: 写入日志文件
# 参数: $* - 日志内容
log_to_file() { ... }
```

#### 5.2.3 工具函数 (`lib/core/utils.sh`)

```bash
# 描述: 检查命令是否存在
# 参数: $1 - 命令名称
# 返回: 0 存在, 1 不存在
command_exists() { ... }

# 描述: 安全创建目录
# 参数: $1 - 目录路径
# 返回: 0 成功, 1 失败
ensure_dir() { ... }

# 描述: 备份文件
# 参数:
#   $1 - 源文件路径
#   $2 - 备份目录 (可选)
# 返回: 备份文件路径
backup_file() { ... }

# 描述: 带超时执行命令
# 参数:
#   $1 - 超时秒数
#   $2 - 命令
# 返回: 命令退出码
run_with_timeout() { ... }

# 描述: 获取当前时间戳
# 返回: ISO 8601 格式时间戳
timestamp() { ... }

# 描述: 模板渲染
# 参数:
#   $1 - 模板文件路径
#   $2 - 变量文件路径或关联数组名
# 返回: 渲染后的内容
render_template() { ... }
```

#### 5.2.4 参数校验 (`lib/core/validation.sh`)

```bash
# 描述: 验证路径安全性
# 参数: $1 - 路径
# 返回: 0 安全, 1 不安全
validate_path() { ... }

# 描述: 验证邮箱格式
# 参数: $1 - 邮箱地址
# 返回: 0 有效, 1 无效
validate_email() { ... }

# 描述: 验证 Git 用户名
# 参数: $1 - 用户名
# 返回: 0 有效, 1 无效
validate_git_username() { ... }
```

### 5.3 系统检测接口 (`lib/system/detect.sh`)

```bash
# 描述: 检测操作系统类型
# 返回: macos|ubuntu|debian|centos|unknown
detect_os() { ... }

# 描述: 检测操作系统版本
# 返回: 版本号字符串
detect_os_version() { ... }

# 描述: 检测操作系统名称
# 返回: 名称字符串 (如 Sonoma)
detect_os_name() { ... }

# 描述: 检测 CPU 架构
# 返回: x86_64|arm64|unknown
detect_arch() { ... }

# 描述: 检测包管理器
# 返回: brew|apt|dnf|yum|unknown
detect_package_manager() { ... }

# 描述: 获取系统完整信息
# 返回: 填充 SYSTEM_INFO 关联数组
get_system_info() { ... }

# 描述: 检查系统是否支持
# 返回: 0 支持, 1 不支持
is_supported_os() { ... }
```

### 5.4 UI 接口

#### 5.4.1 输出格式化 (`lib/ui/output.sh`)

```bash
# 描述: 打印标题
# 参数: $1 - 标题文本
print_title() { ... }

# 描述: 打印分隔线
# 参数:
#   $1 - 字符 (可选, 默认 ─)
#   $2 - 长度 (可选, 默认 40)
print_separator() { ... }

# 描述: 打印成功消息
# 参数: $1 - 消息
print_success() { ... }

# 描述: 打印错误消息
# 参数: $1 - 消息
print_error() { ... }

# 描述: 打印警告消息
# 参数: $1 - 消息
print_warning() { ... }

# 描述: 打印信息消息
# 参数: $1 - 消息
print_info() { ... }

# 描述: 打印组件状态行
# 参数:
#   $1 - 组件名称
#   $2 - 状态 (success|skipped|failed)
#   $3 - 消息
print_component_status() { ... }
```

#### 5.4.2 交互式界面 (`lib/ui/interactive.sh`)

```bash
# 描述: 显示多选菜单
# 参数:
#   $1 - 标题
#   $2 - 选项数组 (格式: "id|name|status")
#   $3 - 默认选中项 (可选, 逗号分隔)
# 返回: 选中的 ID 数组 (通过 stdout 输出)
select_multiple() { ... }

# 描述: 显示确认提示
# 参数:
#   $1 - 提示信息
#   $2 - 默认值 (y/n, 可选, 默认 y)
# 返回: 0 确认, 1 取消
confirm() { ... }

# 描述: 显示输入提示
# 参数:
#   $1 - 提示信息
#   $2 - 默认值 (可选)
#   $3 - 验证函数 (可选)
# 返回: 用户输入 (通过 stdout 输出)
prompt_input() { ... }

# 描述: 显示密码输入提示
# 参数:
#   $1 - 提示信息
# 返回: 用户输入 (通过 stdout 输出)
prompt_password() { ... }
```

### 5.5 组件系统接口

#### 5.5.1 组件注册表 (`lib/component/registry.sh`)

```bash
# 描述: 初始化组件注册表
# 返回: 0
init_component_registry() { ... }

# 描述: 获取所有已注册组件
# 返回: 组件 ID 数组 (通过 stdout 输出)
get_all_components() { ... }

# 描述: 获取指定类别的组件
# 参数: $1 - 类别名称
# 返回: 组件 ID 数组 (通过 stdout 输出)
get_components_by_category() { ... }

# 描述: 获取组件元数据
# 参数: $1 - 组件 ID
# 返回: 组件信息 (JSON 格式, 通过 stdout 输出)
get_component_meta() { ... }

# 描述: 获取所有类别
# 返回: 类别名称数组 (通过 stdout 输出)
get_categories() { ... }

# 描述: 获取类别元数据
# 参数: $1 - 类别 ID
# 返回: 类别信息 (JSON 格式, 通过 stdout 输出)
get_category_meta() { ... }

# 描述: 加载组件脚本
# 参数: $1 - 组件 ID
# 返回: 0 成功, 1 失败
load_component() { ... }
```

#### 5.5.2 组件检测器 (`lib/component/detector.sh`)

```bash
# 描述: 检测组件是否已安装
# 参数: $1 - 组件 ID
# 返回: 0 已安装, 1 未安装
is_component_installed() { ... }

# 描述: 批量检测组件状态
# 参数: $@ - 组件 ID 列表
# 返回: 填充 COMPONENTS 关联数组
detect_components_status() { ... }

# 描述: 获取组件状态详情
# 参数: $1 - 组件 ID
# 返回: 状态描述文本 (通过 stdout 输出)
get_component_status_detail() { ... }
```

#### 5.5.3 组件执行器 (`lib/component/executor.sh`)

```bash
# 描述: 执行单个组件
# 参数:
#   $1 - 组件 ID
#   $2 - 选项 (--force 强制重新安装)
# 返回: 0 成功, 1 失败, 2 跳过
execute_component() { ... }

# 描述: 批量执行组件
# 参数:
#   $1 - 组件 ID 数组
#   $2 - 选项
# 返回: 填充 EXECUTION_SUMMARY 和 ALL_EXEC_RESULTS
execute_components() { ... }

# 描述: 检查组件依赖
# 参数: $1 - 组件 ID
# 返回: 0 依赖满足, 1 依赖缺失
check_component_dependencies() { ... }
```

### 5.6 组件接口规范

每个组件脚本必须实现以下接口：

```bash
# 组件元数据 (必需)
readonly COMPONENT_ID="git-config"
readonly COMPONENT_NAME="Git 配置"
readonly COMPONENT_DESC="配置 Git 用户信息和常用别名"
readonly COMPONENT_CATEGORY="shell-git"
readonly COMPONENT_DEPS=()

# 描述: 检测组件是否已安装
# 返回: 0 已安装, 1 未安装
component_detect() { ... }

# 描述: 安装/配置组件
# 参数: $1 - 选项 (--force 强制重新安装)
# 返回: 0 成功, 1 失败
component_install() { ... }

# 描述: 卸载组件 (可选)
# 返回: 0 成功, 1 失败
component_uninstall() { ... }

# 描述: 获取组件状态详情 (可选)
# 返回: 状态描述文本
component_status() { ... }

# 描述: 安装后提示 (可选)
# 返回: 提示文本数组
component_post_install_message() { ... }
```

---

## 6. 实现里程碑

### M1: CLI 框架 + 系统检测 (1-2 天)

- [ ] 创建项目目录结构
- [ ] 实现核心库 (constants, logging, utils)
- [ ] 实现系统检测模块
- [ ] 实现 CLI 入口和基础命令 (version, help)
- [ ] 编写单元测试

### M2: 组件系统框架 (1-2 天)

- [ ] 实现组件注册表
- [ ] 实现组件检测器
- [ ] 实现组件执行器
- [ ] 实现 UI 模块 (输出格式化)
- [ ] 编写组件基类和模板
- [ ] 编写单元测试

### M3: Shell 与 Git 组件 (2-3 天)

- [ ] 实现 git-config 组件
- [ ] 实现 ssh-key 组件
- [ ] 实现 zsh-ohmyzsh 组件
- [ ] 实现 zsh-plugins 组件
- [ ] 实现 bash-enhanced 组件
- [ ] 实现交互式选择界面
- [ ] 集成测试

### M4: 编辑器配置组件 (1-2 天)

- [ ] 实现 vim-basic 组件
- [ ] 实现 neovim-config 组件
- [ ] 实现 vscode-extensions 组件
- [ ] 集成测试

### M5: 安装脚本 + 文档 (1 天)

- [ ] 实现 install.sh
- [ ] 实现 uninstall.sh
- [ ] 编写 README
- [ ] 编写组件开发指南
- [ ] 端到端测试

---

## 7. 风险与应对

| 风险 | 影响 | 概率 | 应对措施 |
|------|------|------|----------|
| Bash 版本兼容性 | 高 | 中 | 检测 Bash 版本，提供降级方案 |
| 网络超时/失败 | 中 | 高 | 设置超时、重试机制、本地缓存 |
| 权限问题 | 中 | 中 | 明确提示、提供 sudo 选项 |
| 组件依赖冲突 | 中 | 低 | 依赖检查、清晰的错误信息 |
| macOS/Linux 差异 | 高 | 中 | 抽象系统层、充分测试 |

---

## 8. 验收标准

### 8.1 功能验收

- [ ] `ops-toolkit init` 交互式选择并配置组件
- [ ] `ops-toolkit list` 列出所有可用组件
- [ ] `ops-toolkit version` 显示版本信息
- [ ] 幂等性：重复执行不产生冲突
- [ ] 错误处理：单个组件失败不影响其他组件
- [ ] 支持 macOS 12.0+
- [ ] 支持 Ubuntu 20.04+、Debian 11+、CentOS 8+

### 8.2 质量验收

- [ ] 通过 ShellCheck 检查，无警告无错误
- [ ] 单元测试覆盖率 ≥ 80%
- [ ] 在 macOS 和 Ubuntu 上完成端到端测试
- [ ] 启动时间 < 500ms
- [ ] 日志文件格式规范，便于问题排查
- [ ] 所有脚本符合 constitution.md 规范

---

*文档版本: 1.0.0 | 最后更新: 2026-03-03*
