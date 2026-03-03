# ops-toolkit 开发任务列表

> 版本: 1.0.0
> 日期: 2026-03-03
> 状态: 待执行

---

## 任务执行规范

1. **TDD 原则**：所有功能模块必须先写测试，再写实现
2. **原子任务**：每个任务只涉及一个主要文件的创建或修改
3. **并行标记 [P]**：标记无依赖关系的任务，可并行执行
4. **依赖关系**：明确标注前置任务编号

---

## 阶段 M1: CLI 框架 + 系统检测

### M1.1 项目初始化

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M1.1.1 | 创建项目目录结构 | 全局 | [P] | - |
| M1.1.2 | 创建 .gitignore 文件 | .gitignore | [P] | - |
| M1.1.3 | 创建测试工具函数 | tests/helpers/test-utils.sh | [P] | - |

### M1.2 核心库 - 常量定义 (TDD)

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M1.2.1 | 编写 constants.sh 测试 | tests/unit/test_constants.sh | [P] | M1.1.3 |
| M1.2.2 | 实现 constants.sh | lib/core/constants.sh | - | M1.2.1 |

### M1.3 核心库 - 日志系统 (TDD)

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M1.3.1 | 编写 logging.sh 测试 | tests/unit/test_logging.sh | [P] | M1.1.3 |
| M1.3.2 | 实现 logging.sh | lib/core/logging.sh | - | M1.2.2, M1.3.1 |

### M1.4 核心库 - 工具函数 (TDD)

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M1.4.1 | 编写 utils.sh 测试 | tests/unit/test_utils.sh | [P] | M1.1.3 |
| M1.4.2 | 实现 utils.sh | lib/core/utils.sh | - | M1.2.2, M1.3.2, M1.4.1 |

### M1.5 核心库 - 参数校验 (TDD)

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M1.5.1 | 编写 validation.sh 测试 | tests/unit/test_validation.sh | [P] | M1.1.3 |
| M1.5.2 | 实现 validation.sh | lib/core/validation.sh | - | M1.2.2, M1.3.2, M1.5.1 |

### M1.6 系统检测模块 (TDD)

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M1.6.1 | 编写 detect.sh 测试 | tests/unit/test_detect.sh | [P] | M1.1.3 |
| M1.6.2 | 实现 detect.sh | lib/system/detect.sh | - | M1.2.2, M1.3.2, M1.4.2, M1.6.1 |
| M1.6.3 | 实现 prerequisites.sh | lib/system/prerequisites.sh | - | M1.6.2 |

### M1.7 CLI 入口与基础命令

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M1.7.1 | 实现 version.sh | lib/version.sh | [P] | M1.2.2, M1.3.2 |
| M1.7.2 | 实现 help.sh | lib/help.sh | [P] | M1.2.2, M1.3.2 |
| M1.7.3 | 实现 bin/ops-toolkit 主入口 | bin/ops-toolkit | - | M1.2.2, M1.3.2, M1.7.1, M1.7.2 |

### M1.8 开发脚本

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M1.8.1 | 创建 lint.sh | scripts/lint.sh | [P] | - |
| M1.8.2 | 创建 test.sh | scripts/test.sh | [P] | - |

---

## 阶段 M2: 组件系统框架

### M2.1 UI 模块 - 输出格式化 (TDD)

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M2.1.1 | 编写 output.sh 测试 | tests/unit/test_output.sh | [P] | M1.1.3 |
| M2.1.2 | 实现 output.sh | lib/ui/output.sh | - | M1.2.2, M1.3.2, M2.1.1 |
| M2.1.3 | 实现 progress.sh | lib/ui/progress.sh | - | M2.1.2 |

### M2.2 组件基类

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M2.2.1 | 创建组件基类 | components/_base.sh | [P] | M1.2.2, M1.3.2, M1.4.2 |

### M2.3 组件注册表 (TDD)

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M2.3.1 | 编写 registry.sh 测试 | tests/unit/test_registry.sh | [P] | M1.1.3 |
| M2.3.2 | 实现 registry.sh | lib/component/registry.sh | - | M1.2.2, M1.3.2, M1.4.2, M2.2.1, M2.3.1 |

### M2.4 组件检测器 (TDD)

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M2.4.1 | 编写 detector.sh 测试 | tests/unit/test_detector.sh | [P] | M1.1.3 |
| M2.4.2 | 实现 detector.sh | lib/component/detector.sh | - | M1.2.2, M1.3.2, M1.4.2, M2.3.2, M2.4.1 |

### M2.5 组件执行器 (TDD)

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M2.5.1 | 编写 executor.sh 测试 | tests/unit/test_executor.sh | [P] | M1.1.3 |
| M2.5.2 | 实现 executor.sh | lib/component/executor.sh | - | M1.2.2, M1.3.2, M1.4.2, M2.1.2, M2.4.2, M2.5.1 |

### M2.6 UI 模块 - 交互式界面 (TDD)

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M2.6.1 | 编写 interactive.sh 测试 | tests/unit/test_interactive.sh | [P] | M1.1.3 |
| M2.6.2 | 实现 interactive.sh | lib/ui/interactive.sh | - | M1.2.2, M1.3.2, M2.1.2, M2.6.1 |

### M2.7 配置模板

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M2.7.1 | 创建 gitconfig 模板 | configs/git/gitconfig.template | [P] | - |
| M2.7.2 | 创建 zshrc 追加模板 | configs/zsh/zshrc.append | [P] | - |
| M2.7.3 | 创建 bashrc 追加模板 | configs/bash/bashrc.append | [P] | - |
| M2.7.4 | 创建 vimrc 模板 | configs/vim/vimrc.template | [P] | - |

### M2.8 类别元数据

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M2.8.1 | 创建 shell-git 类别元数据 | components/shell-git/_category.sh | [P] | M2.2.1 |
| M2.8.2 | 创建 editor 类别元数据 | components/editor/_category.sh | [P] | M2.2.1 |

---

## 阶段 M3: Shell 与 Git 组件

### M3.1 git-config 组件 (TDD)

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M3.1.1 | 编写 git-config 测试 | tests/integration/test_git_config.sh | [P] | M1.1.3 |
| M3.1.2 | 实现 git-config 组件 | components/shell-git/git-config.sh | - | M2.2.1, M2.7.1, M3.1.1 |

### M3.2 ssh-key 组件 (TDD)

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M3.2.1 | 编写 ssh-key 测试 | tests/integration/test_ssh_key.sh | [P] | M1.1.3 |
| M3.2.2 | 实现 ssh-key 组件 | components/shell-git/ssh-key.sh | - | M2.2.1, M3.2.1 |

### M3.3 zsh-ohmyzsh 组件 (TDD)

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M3.3.1 | 编写 zsh-ohmyzsh 测试 | tests/integration/test_zsh_ohmyzsh.sh | [P] | M1.1.3 |
| M3.3.2 | 实现 zsh-ohmyzsh 组件 | components/shell-git/zsh-ohmyzsh.sh | - | M2.2.1, M3.3.1 |

### M3.4 zsh-plugins 组件 (TDD)

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M3.4.1 | 编写 zsh-plugins 测试 | tests/integration/test_zsh_plugins.sh | [P] | M1.1.3 |
| M3.4.2 | 实现 zsh-plugins 组件 | components/shell-git/zsh-plugins.sh | - | M2.2.1, M2.7.2, M3.3.2, M3.4.1 |

### M3.5 bash-enhanced 组件 (TDD)

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M3.5.1 | 编写 bash-enhanced 测试 | tests/integration/test_bash_enhanced.sh | [P] | M1.1.3 |
| M3.5.2 | 实现 bash-enhanced 组件 | components/shell-git/bash-enhanced.sh | - | M2.2.1, M2.7.3, M3.5.1 |

### M3.6 list 子命令

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M3.6.1 | 实现 list.sh | lib/list.sh | - | M2.1.2, M2.3.2, M2.4.2, M2.8.1, M2.8.2, M3.1.2-M3.5.2 |

### M3.7 init 子命令

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M3.7.1 | 实现 init.sh | lib/init.sh | - | M1.6.2, M2.1.2, M2.5.2, M2.6.2, M3.6.1 |

### M3.8 集成测试

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M3.8.1 | 编写 init 流程集成测试 | tests/integration/test_init_flow.sh | - | M3.7.1 |

---

## 阶段 M4: 编辑器配置组件

### M4.1 vim-basic 组件 (TDD)

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M4.1.1 | 编写 vim-basic 测试 | tests/integration/test_vim_basic.sh | [P] | M1.1.3 |
| M4.1.2 | 实现 vim-basic 组件 | components/editor/vim-basic.sh | - | M2.2.1, M2.7.4, M4.1.1 |

### M4.2 neovim-config 组件 (TDD)

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M4.2.1 | 编写 neovim-config 测试 | tests/integration/test_neovim_config.sh | [P] | M1.1.3 |
| M4.2.2 | 实现 neovim-config 组件 | components/editor/neovim-config.sh | - | M2.2.1, M4.2.1 |

### M4.3 vscode-extensions 组件 (TDD)

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M4.3.1 | 编写 vscode-extensions 测试 | tests/integration/test_vscode_extensions.sh | [P] | M1.1.3 |
| M4.3.2 | 实现 vscode-extensions 组件 | components/editor/vscode-extensions.sh | - | M2.2.1, M4.3.1 |

### M4.4 集成测试更新

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M4.4.1 | 更新 init 流程集成测试 | tests/integration/test_init_flow.sh | - | M4.1.2, M4.2.2, M4.3.2, M3.8.1 |

---

## 阶段 M5: 安装脚本 + 文档

### M5.1 卸载脚本

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M5.1.1 | 实现 uninstall.sh | lib/uninstall.sh | [P] | M1.2.2, M1.3.2 |
| M5.1.2 | 更新 bin/ops-toolkit 支持 uninstall | bin/ops-toolkit | - | M5.1.1 |

### M5.2 安装脚本

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M5.2.1 | 实现 install.sh | install.sh | - | M1.6.2, M5.1.2 |
| M5.2.2 | 实现 uninstall.sh (根目录) | uninstall.sh | - | M5.1.1, M5.2.1 |

### M5.3 文档

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M5.3.1 | 编写 README.md | README.md | [P] | - |
| M5.3.2 | 编写组件开发指南 | docs/components.md | [P] | - |
| M5.3.3 | 编写贡献指南 | docs/contributing.md | [P] | - |

### M5.4 端到端测试

| 编号 | 任务描述 | 文件路径 | 标记 | 依赖 |
|------|----------|----------|------|------|
| M5.4.1 | 编写端到端测试 | tests/e2e/test_install_and_init.sh | - | M5.2.1, M5.2.2, M3.7.1 |

---

## 任务依赖图

```
M1 (基础框架)
├── M1.1 (项目初始化)
├── M1.2 (constants)
├── M1.3 (logging) ──┐
├── M1.4 (utils)     ├──> M1.6 (detect)
├── M1.5 (validation)
├── M1.7 (CLI 入口)
└── M1.8 (开发脚本)

M2 (组件系统)
├── M2.1 (UI output)
├── M2.2 (组件基类)
├── M2.3 (registry) ──┐
├── M2.4 (detector)   ├──> M2.5 (executor)
├── M2.6 (UI interactive)
├── M2.7 (配置模板)
└── M2.8 (类别元数据)

M3 (Shell/Git 组件)
├── M3.1-M3.5 (各组件) ──┐
├── M3.6 (list 命令)        ├──> M3.7 (init 命令)
└── M3.8 (集成测试)

M4 (编辑器组件)
├── M4.1-M4.3 (各组件)
└── M4.4 (集成测试更新)

M5 (安装/文档)
├── M5.1 (uninstall)
├── M5.2 (install)
├── M5.3 (文档)
└── M5.4 (E2E 测试)
```

---

## 执行建议

1. **按阶段顺序执行**：M1 → M2 → M3 → M4 → M5
2. **阶段内并行**：标记 [P] 的任务可并行执行
3. **TDD 严格执行**：每个模块必须先完成测试，再实现功能
4. **持续验证**：每完成一个子阶段，运行 `scripts/test.sh` 确保测试通过
5. **代码质量**：每完成一个子阶段，运行 `scripts/lint.sh` 确保无 ShellCheck 警告

---

*文档版本: 1.0.0 | 最后更新: 2026-03-03*
