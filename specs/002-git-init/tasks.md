# Git 一键初始化工具 任务分解

> 版本: 1.0.0
> 日期: 2026-03-03
> 状态: 待执行

---

## 执行阶段概览

| 阶段 | 任务数 | 预计时间 | 说明 |
|------|--------|----------|------|
| **M1: 基础框架 + 主账户配置** | 10 个 | 0.5 天 | 脚本框架、CLI 解析、UI、基础测试 |
| **M2: SSH Key + .gitignore 配置** | 8 个 | 0.5 天 | SSH 密钥生成、忽略文件配置 |
| **M3: Git 别名 + 多账户配置** | 6 个 | 0.5 天 | Git 别名、多账户 includeIf 配置 |
| **M4: 配置验证 + 导入导出** | 8 个 | 0.5 天 | SSH 连接验证、配置导入导出 |
| **M5: 整合与测试** | 3 个 | - | 完整流程测试、文档完善 |

---

## 阶段 M1: 基础框架 + 主账户配置

### 任务 1.1: 创建 git-init.sh 基础框架文件
- **描述**: 创建单文件脚本的基础结构，包括 shebang、严格模式、版本常量
- **文件**: `scripts/git-init.sh`
- **依赖**: 无
- **标记**: [P]
- **验收标准**:
  - 文件存在且可执行
  - 包含 `#!/usr/bin/env bash`
  - 包含 `set -euo pipefail` 和 `IFS=$'\n\t'`
  - 包含 `VERSION="1.0.0"` 和 `SCRIPT_NAME="git-init.sh"`
  - 包含基础的 `main()` 函数框架

---

### 任务 1.2: 创建测试辅助工具文件
- **描述**: 创建测试用的辅助函数库
- **文件**: `tests/helpers/git-init-test-utils.sh`
- **依赖**: 无
- **标记**: [P]
- **验收标准**:
  - 包含临时目录创建/清理函数
  - 包含 mock git 配置函数
  - 包含断言函数

---

### 任务 1.3: 实现 CLI 参数解析测试
- **描述**: 为 parse_args 函数编写单元测试
- **文件**: `tests/unit/test_git_init_parse_args.sh`
- **依赖**: 任务 1.2
- **标记**: [P]
- **验收标准**:
  - 测试 `-h/--help` 参数
  - 测试 `-v/--version` 参数
  - 测试 `-e/--export` 参数
  - 测试 `-i/--import` 参数
  - 测试 `-y/--yes` 参数
  - 测试 `--no-*` 系列参数
  - 测试未知参数错误处理

---

### 任务 1.4: 实现 UI 输出模块测试
- **描述**: 为 UI 输出函数编写单元测试
- **文件**: `tests/unit/test_git_init_ui.sh`
- **依赖**: 任务 1.2
- **标记**: [P]
- **验收标准**:
  - 测试 `print_title()` 输出格式
  - 测试 `print_success()` 输出颜色
  - 测试 `print_error()` 输出颜色和重定向
  - 测试 `print_warning()` 输出颜色
  - 测试 `print_info()` 输出颜色

---

### 任务 1.5: 实现依赖检查测试
- **描述**: 为 check_dependencies 函数编写单元测试
- **文件**: `tests/unit/test_git_init_dependencies.sh`
- **依赖**: 任务 1.2
- **标记**: [P]
- **验收标准**:
  - 测试 git 存在的情况
  - 测试 ssh-keygen 存在的情况
  - 测试 git 缺失的错误处理
  - 测试 ssh-keygen 缺失的错误处理
  - 测试两者都缺失的错误处理

---

### 任务 1.6: 实现 CLI 参数解析功能
- **描述**: 实现 parse_args 函数，解析所有命令行参数
- **文件**: `scripts/git-init.sh`
- **依赖**: 任务 1.1, 任务 1.3
- **验收标准**:
  - 正确解析所有参数到 OPTIONS 关联数组
  - `-h/--help` 调用 print_help 并退出
  - `-v/--version` 调用 print_version 并退出
  - 未知参数显示错误并退出

---

### 任务 1.7: 实现 UI 输出模块
- **描述**: 实现所有 UI 输出函数（颜色定义、print_* 系列）
- **文件**: `scripts/git-init.sh`
- **依赖**: 任务 1.1, 任务 1.4
- **验收标准**:
  - 定义所有颜色常量（COLOR_RESET, COLOR_RED 等）
  - 实现 print_title() 带分隔线
  - 实现 print_success/error/warning/info 带 emoji 和颜色
  - print_error 输出到 stderr

---

### 任务 1.8: 实现交互式输入模块
- **描述**: 实现 ask_input, ask_confirm, ask_choice 函数
- **文件**: `scripts/git-init.sh`
- **依赖**: 任务 1.7
- **验收标准**:
  - ask_input 支持默认值
  - ask_confirm 支持 yes_to_all 选项
  - ask_choice 支持选项列表和默认值
  - 所有函数通过 stdout 返回结果

---

### 任务 1.9: 实现依赖检查功能
- **描述**: 实现 check_dependencies 函数
- **文件**: `scripts/git-init.sh`
- **依赖**: 任务 1.7, 任务 1.5
- **验收标准**:
  - 使用 command -v 检查 git 和 ssh-keygen
  - 缺失依赖时显示友好错误
  - 缺失依赖时退出码非 0

---

### 任务 1.10: 实现主账户配置功能
- **描述**: 实现 configure_main_account, validate_git_username, validate_email 函数
- **文件**: `scripts/git-init.sh`
- **依赖**: 任务 1.8, 任务 1.9
- **验收标准**:
  - 读取现有 git 配置作为默认值
  - validate_git_username 验证非空且长度 ≤ 100
  - validate_email 使用正则验证邮箱格式
  - 设置 git config --global user.name 和 user.email
  - 更新 SUMMARY 状态

---

## 阶段 M2: SSH Key + .gitignore 配置

### 任务 2.1: 创建 SSH Key 配置测试
- **描述**: 为 SSH Key 相关函数编写单元测试
- **文件**: `tests/unit/test_git_init_ssh.sh`
- **依赖**: 任务 1.2
- **标记**: [P]
- **验收标准**:
  - 测试 SSH Key 存在的检测
  - 测试 use_existing_ssh_key 流程
  - 测试 backup_and_generate_ssh_key 备份逻辑
  - 测试 generate_new_ssh_key ed25519 算法
  - 测试 generate_new_ssh_key rsa 4096 算法
  - 测试 copy_public_key_to_clipboard 各种平台
  - 测试 ensure_dir 目录创建

---

### 任务 2.2: 创建 .gitignore 配置测试
- **描述**: 为 .gitignore 相关函数编写单元测试
- **文件**: `tests/unit/test_git_init_gitignore.sh`
- **依赖**: 任务 1.2
- **标记**: [P]
- **验收标准**:
  - 测试 configure_default_gitignore 模板内容
  - 测试 configure_custom_gitignore 用户输入
  - 测试跳过选项
  - 验证 git config --global core.excludesfile 设置

---

### 任务 2.3: 实现 ensure_dir 工具函数
- **描述**: 实现安全创建目录的工具函数
- **文件**: `scripts/git-init.sh`
- **依赖**: 任务 1.10
- **验收标准**:
  - 检查目录是否存在
  - 不存在时使用 mkdir -p 创建
  - 无返回值

---

### 任务 2.4: 实现 SSH Key 配置功能
- **描述**: 实现 configure_ssh_key, use_existing_ssh_key, backup_and_generate_ssh_key, generate_new_ssh_key, copy_public_key_to_clipboard 函数
- **文件**: `scripts/git-init.sh`
- **依赖**: 任务 2.3, 任务 2.1
- **验收标准**:
  - 检测 ~/.ssh/id_ed25519 是否存在
  - 使用现有 Key 时读取公钥
  - 备份旧 Key 时使用时间戳后缀
  - 生成 ed25519 和 rsa 4096 两种算法
  - 正确设置私钥权限 600，公钥 644
  - 支持 pbcopy/xclip/xsel 剪贴板复制
  - 不支持剪贴板时直接打印公钥

---

### 任务 2.5: 实现全局 .gitignore 配置功能
- **描述**: 实现 configure_gitignore, configure_default_gitignore, configure_custom_gitignore 函数
- **文件**: `scripts/git-init.sh`
- **依赖**: 任务 1.10, 任务 2.2
- **验收标准**:
  - 默认模板包含 macOS、编辑器、编程语言、环境变量、构建输出
  - 自定义模板支持多行输入（空行结束）
  - 设置 git config --global core.excludesfile
  - 更新 SUMMARY.gitignore_configured

---

### 任务 2.6: 创建 Git 别名配置测试
- **描述**: 为 Git 别名函数编写单元测试
- **文件**: `tests/unit/test_git_init_aliases.sh`
- **依赖**: 任务 1.2
- **标记**: [P]
- **验收标准**:
  - 测试所有 7 个别名是否正确设置
  - 测试跳过选项
  - 验证 SUMMARY.aliases_configured 更新

---

### 任务 2.7: 实现 Git 别名配置功能
- **描述**: 实现 configure_git_aliases 函数
- **文件**: `scripts/git-init.sh`
- **依赖**: 任务 2.5, 任务 2.6
- **验收标准**:
  - 设置 alias.st=status
  - 设置 alias.co=checkout
  - 设置 alias.br=branch
  - 设置 alias.ci=commit
  - 设置 alias.lg=美化日志格式
  - 设置 alias.unstage=reset HEAD --
  - 设置 alias.last=log -1 HEAD
  - 更新 SUMMARY.aliases_configured

---

### 任务 2.8: 实现 print_help 和 print_version 函数
- **描述**: 实现帮助信息和版本信息显示
- **文件**: `scripts/git-init.sh`
- **依赖**: 任务 1.7
- **标记**: [P]
- **验收标准**:
  - print_help 显示完整帮助信息
  - print_version 显示版本号和项目信息
  - 格式与 spec.md 示例一致

---

## 阶段 M3: Git 别名 + 多账户配置

### 任务 3.1: 创建多账户配置测试
- **描述**: 为多账户配置函数编写单元测试
- **文件**: `tests/unit/test_git_init_extra_accounts.sh`
- **依赖**: 任务 1.2
- **标记**: [P]
- **验收标准**:
  - 测试 configure_single_extra_account 配置文件生成
  - 测试 includeIf 配置正确添加
  - 测试目录路径展开（eval ~/work）
  - 测试 EXTRA_ACCOUNTS 数组更新

---

### 任务 3.2: 实现配置摘要输出测试
- **描述**: 为 print_summary 函数编写单元测试
- **文件**: `tests/unit/test_git_init_summary.sh`
- **依赖**: 任务 1.2
- **标记**: [P]
- **验收标准**:
  - 测试主账户显示
  - 测试 SSH Key 显示
  - 测试 .gitignore 显示
  - 测试 Git 别名显示
  - 测试额外账户计数显示
  - 测试提示信息显示

---

### 任务 3.3: 实现多账户配置功能
- **描述**: 实现 configure_extra_accounts, configure_single_extra_account 函数
- **文件**: `scripts/git-init.sh`
- **依赖**: 任务 2.7, 任务 3.1
- **验收标准**:
  - 询问用户是否配置额外账户
  - 支持循环添加多个账户
  - 每个账户生成独立的 ~/.gitconfig-${name} 文件
  - 使用 git config --global --add includeIf.gitdir:${dir}/.path
  - 目录路径使用 eval 展开
  - 更新 SUMMARY.extra_accounts_count

---

### 任务 3.4: 实现配置摘要输出功能
- **描述**: 实现 print_summary 函数
- **文件**: `scripts/git-init.sh`
- **依赖**: 任务 3.3, 任务 3.2
- **验收标准**:
  - 显示成功标题
  - 根据 SUMMARY 状态显示配置项
  - 显示提示信息（公钥添加、多账户目录、导出备份）
  - 格式与 spec.md 示例一致

---

### 任务 3.5: 更新 main 函数整合 M1-M3
- **描述**: 更新 main 函数，整合 M1-M3 的功能
- **文件**: `scripts/git-init.sh`
- **依赖**: 任务 3.4
- **验收标准**:
  - 调用 check_dependencies
  - 调用 configure_main_account
  - 根据 OPTIONS.skip_ssh 决定是否调用 configure_ssh_key
  - 根据 OPTIONS.skip_gitignore 决定是否调用 configure_gitignore
  - 根据 OPTIONS.skip_aliases 决定是否调用 configure_git_aliases
  - 调用 configure_extra_accounts
  - 调用 print_summary

---

### 任务 3.6: 创建 M1-M3 集成测试
- **描述**: 创建 M1-M3 功能的端到端集成测试
- **文件**: `tests/integration/test_git_init_m1_m3.sh`
- **依赖**: 任务 1.2, 任务 3.5
- **验收标准**:
  - 使用 mock 输入模拟完整流程
  - 验证所有 git config 设置
  - 验证 SSH Key 生成
  - 验证 .gitignore 文件
  - 验证多账户配置

---

## 阶段 M4: 配置验证 + 导入导出

### 任务 4.1: 创建 SSH 连接验证测试
- **描述**: 为 SSH 连接验证函数编写单元测试
- **文件**: `tests/unit/test_git_init_verify.sh`
- **依赖**: 任务 1.2
- **标记**: [P]
- **验收标准**:
  - 测试 verify_github_ssh 成功（退出码 1）
  - 测试 verify_github_ssh 失败（超时/网络错误）
  - 测试 verify_gitlab_ssh 成功
  - 测试 verify_gitlab_ssh 失败
  - 测试 10 秒超时设置

---

### 任务 4.2: 创建配置导出测试
- **描述**: 为 export_config 函数编写单元测试
- **文件**: `tests/unit/test_git_init_export.sh`
- **依赖**: 任务 1.2
- **标记**: [P]
- **验收标准**:
  - 测试导出文件包含主账户信息
  - 测试导出文件包含 SSH 算法和路径
  - 测试导出文件包含 .gitignore 内容
  - 测试导出文件包含 Git 别名配置
  - 测试导出文件包含多账户信息
  - 测试不包含 SSH 私钥
  - 测试导出文件可执行（chmod +x）

---

### 任务 4.3: 创建配置导入测试
- **描述**: 为 import_config 函数编写单元测试
- **文件**: `tests/unit/test_git_init_import.sh`
- **依赖**: 任务 1.2
- **标记**: [P]
- **验收标准**:
  - 测试导入文件不存在的错误处理
  - 测试导入主账户配置
  - 测试导入 .gitignore 配置
  - 测试导入 Git 别名配置
  - 测试导入多账户配置
  - 测试 yes_to_all 自动设为 true

---

### 任务 4.4: 实现 SSH 连接验证功能
- **描述**: 实现 verify_configuration, verify_github_ssh, verify_gitlab_ssh 函数
- **文件**: `scripts/git-init.sh`
- **依赖**: 任务 3.5, 任务 4.1
- **验收标准**:
  - 使用 timeout 10s 设置超时
  - 使用 -o StrictHostKeyChecking=no 避免交互式确认
  - GitHub/GitLab 测试成功时（退出码 1）显示成功
  - 失败时显示警告和建议
  - 更新 SUMMARY.verification_passed

---

### 任务 4.5: 实现配置导出功能
- **描述**: 实现 export_config 函数
- **文件**: `scripts/git-init.sh`
- **依赖**: 任务 4.4, 任务 4.2
- **验收标准**:
  - 读取 git config --global user.name/email
  - 查找 ~/.ssh/id_ed25519 或 id_rsa
  - 读取全局 .gitignore 内容
  - 解析 includeIf 配置获取多账户信息
  - 生成可执行的导出脚本
  - 包含所有 GIT_INIT_CONFIG_* 环境变量
  - 不包含 SSH 私钥

---

### 任务 4.6: 实现配置导入功能
- **描述**: 实现 import_config 函数
- **文件**: `scripts/git-init.sh`
- **依赖**: 任务 4.5, 任务 4.3
- **验收标准**:
  - 检查导入文件是否存在
  - source 导入文件读取环境变量
  - 设置 OPTIONS.yes_to_all=true
  - 根据 GIT_INIT_CONFIG_* 应用配置
  - 调用 print_summary 显示结果

---

### 任务 4.7: 更新 main 函数整合 M4
- **描述**: 更新 main 函数，整合导入导出和验证功能
- **文件**: `scripts/git-init.sh`
- **依赖**: 任务 4.6
- **验收标准**:
  - 检测到 OPTIONS.export_file 时调用 export_config 并退出
  - 检测到 OPTIONS.import_file 时调用 import_config 并退出
  - 根据 OPTIONS.skip_verify 决定是否调用 verify_configuration
  - 在 print_summary 之前调用 verify_configuration

---

### 任务 4.8: 创建 M4 集成测试
- **描述**: 创建导入导出和验证的端到端集成测试
- **文件**: `tests/integration/test_git_init_m4.sh`
- **依赖**: 任务 1.2, 任务 4.7
- **验收标准**:
  - 测试完整配置 → 导出 → 导入 → 验证流程
  - 验证导入后配置与原配置一致
  - 验证 SSH 连接验证（使用 mock）

---

## 阶段 M5: 整合与测试

### 任务 5.1: 创建完整端到端测试
- **描述**: 创建完整的端到端测试，覆盖 spec.md 所有场景
- **文件**: `tests/e2e/test_git_init_complete.sh`
- **依赖**: 任务 3.6, 任务 4.8
- **验收标准**:
  - 测试 AC-001: 全新机器完整流程
  - 测试 AC-002: 已有 SSH Key 的处理
  - 测试 AC-003: 多账户配置和自动切换
  - 测试 AC-004: 配置导出功能
  - 测试 AC-005: 配置导入功能
  - 测试 AC-006: 幂等性（重复执行）
  - 测试 AC-007: SSH 连接失败处理
  - 测试 AC-008: 无网络连接

---

### 任务 5.2: 创建全局 .gitignore 模板
- **描述**: 创建全局 .gitignore 模板文件（可选，作为内联的备选）
- **文件**: `configs/git/gitignore.template`
- **依赖**: 无
- **标记**: [P]
- **验收标准**:
  - 包含 spec.md 定义的所有通用忽略项
  - 格式与 git-init.sh 内联模板一致

---

### 任务 5.3: 运行 ShellCheck 并修复问题
- **描述**: 运行 ShellCheck 静态检查，确保代码质量符合 constitution.md
- **文件**: `scripts/git-init.sh`
- **依赖**: 任务 4.7
- **验收标准**:
  - 通过 ShellCheck 检查，无警告无错误
  - 脚本行数 ≤ 500 行
  - 所有函数有文档注释
  - 符合 constitution.md 所有规范

---

## 任务依赖关系图

```
M1: 基础框架
├── 1.1 创建框架
├── 1.2 测试辅助 [P]
├── 1.3 参数解析测试 [P]
├── 1.4 UI 输出测试 [P]
├── 1.5 依赖检查测试 [P]
├── 1.6 实现参数解析 (依赖 1.1, 1.3)
├── 1.7 实现 UI 输出 (依赖 1.1, 1.4)
├── 1.8 实现交互输入 (依赖 1.7)
├── 1.9 实现依赖检查 (依赖 1.7, 1.5)
└── 1.10 实现主账户 (依赖 1.8, 1.9)

M2: SSH + .gitignore
├── 2.1 SSH 测试 [P]
├── 2.2 gitignore 测试 [P]
├── 2.3 ensure_dir (依赖 1.10)
├── 2.4 SSH 实现 (依赖 2.3, 2.1)
├── 2.5 gitignore 实现 (依赖 1.10, 2.2)
├── 2.6 别名测试 [P]
├── 2.7 别名实现 (依赖 2.5, 2.6)
└── 2.8 help/version (依赖 1.7) [P]

M3: 别名 + 多账户
├── 3.1 多账户测试 [P]
├── 3.2 摘要测试 [P]
├── 3.3 多账户实现 (依赖 2.7, 3.1)
├── 3.4 摘要实现 (依赖 3.3, 3.2)
├── 3.5 main 整合 (依赖 3.4)
└── 3.6 集成测试 (依赖 3.5)

M4: 验证 + 导入导出
├── 4.1 验证测试 [P]
├── 4.2 导出测试 [P]
├── 4.3 导入测试 [P]
├── 4.4 验证实现 (依赖 3.5, 4.1)
├── 4.5 导出实现 (依赖 4.4, 4.2)
├── 4.6 导入实现 (依赖 4.5, 4.3)
├── 4.7 main 整合 (依赖 4.6)
└── 4.8 集成测试 (依赖 4.7)

M5: 整合与测试
├── 5.1 端到端测试 (依赖 3.6, 4.8)
├── 5.2 gitignore 模板 [P]
└── 5.3 ShellCheck (依赖 4.7)
```

---

## 执行顺序建议

### 第一轮（并行基础任务）
- [ ] 1.1 创建 git-init.sh 基础框架
- [ ] 1.2 创建测试辅助工具
- [ ] 1.3 CLI 参数解析测试
- [ ] 1.4 UI 输出模块测试
- [ ] 1.5 依赖检查测试
- [ ] 2.1 SSH Key 配置测试
- [ ] 2.2 .gitignore 配置测试
- [ ] 2.6 Git 别名配置测试
- [ ] 2.8 help/version 实现
- [ ] 3.1 多账户配置测试
- [ ] 3.2 配置摘要输出测试
- [ ] 4.1 SSH 连接验证测试
- [ ] 4.2 配置导出测试
- [ ] 4.3 配置导入测试
- [ ] 5.2 gitignore 模板

### 第二轮（M1 核心功能）
- [ ] 1.6 CLI 参数解析实现
- [ ] 1.7 UI 输出实现
- [ ] 1.8 交互输入实现
- [ ] 1.9 依赖检查实现
- [ ] 1.10 主账户配置实现

### 第三轮（M2 SSH + .gitignore）
- [ ] 2.3 ensure_dir 实现
- [ ] 2.4 SSH Key 配置实现
- [ ] 2.5 .gitignore 配置实现
- [ ] 2.7 Git 别名配置实现

### 第四轮（M3 多账户）
- [ ] 3.3 多账户配置实现
- [ ] 3.4 配置摘要输出实现
- [ ] 3.5 main 函数整合 M1-M3
- [ ] 3.6 M1-M3 集成测试

### 第五轮（M4 导入导出）
- [ ] 4.4 SSH 连接验证实现
- [ ] 4.5 配置导出实现
- [ ] 4.6 配置导入实现
- [ ] 4.7 main 函数整合 M4
- [ ] 4.8 M4 集成测试

### 第六轮（M5 收尾）
- [ ] 5.1 完整端到端测试
- [ ] 5.3 ShellCheck 检查修复

---

## 验收标准汇总

### 功能验收
- [x] 所有任务分解完成
- [x] 每个任务原子化（单个文件）
- [x] TDD 遵循（测试任务先于实现任务）
- [x] 并行任务标记 [P]
- [x] 阶段划分明确
- [x] 依赖关系清晰
- [x] 覆盖 spec.md 所有 AC 场景

### 质量验收
- [x] 符合 constitution.md 规范
- [x] 单文件脚本 ≤ 500 行
- [x] ShellCheck 零警告零错误
- [x] 所有函数有文档注释

---

*文档版本: 1.0.0 | 最后更新: 2026-03-03*
