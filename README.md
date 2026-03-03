# ops-toolkit

快速初始化开发环境的命令行工具。

## 功能特性

- 一键初始化 Shell 和 Git 环境
- 配置常用编辑器（Vim, Neovim, VSCode）
- 交互式安装，按需选择组件
- 幂等执行，安全可靠
- 支持 MacOS 和 Linux 系统

## 安装

### 快速安装

```bash
git clone https://github.com/lizhengnacl/ops-toolkit.git
cd ops-toolkit
./install.sh
```

### 手动安装

1. 克隆仓库
2. 将项目复制到 `~/.local/lib/ops-toolkit`
3. 将 `bin/ops-toolkit` 链接到 `~/.local/bin/`

确保 `~/.local/bin` 在你的 `PATH` 环境变量中。

### Git 一键初始化（快速方式）

如果只需要快速配置 Git 环境，可以直接下载并执行 git-init.sh：

```bash
# 方式 1：直接下载并执行（推荐在真实终端中运行）
bash -c "$(curl -fsSL https://raw.githubusercontent.com/lizhengnacl/ops-toolkit/main/scripts/git-init.sh)"

# 方式 2：先下载再执行（更安全）
curl -fsSL https://raw.githubusercontent.com/lizhengnacl/ops-toolkit/main/scripts/git-init.sh -o /tmp/git-init.sh
chmod +x /tmp/git-init.sh
/tmp/git-init.sh

# 方式 3：克隆完整仓库
git clone https://github.com/lizhengnacl/ops-toolkit.git
cd ops-toolkit
./scripts/git-init.sh
```

git-init.sh 功能特性：
- 配置 Git 主账户
- 生成和管理 SSH Key
- 配置全局 .gitignore
- 设置 Git 别名
- 支持多账户配置（基于目录或 Remote）
- SSH 连接验证
- 配置导入/导出

## 使用

### 初始化开发环境

```bash
ops-toolkit init
```

### 列出可用组件

```bash
ops-toolkit list
```

### 显示版本

```bash
ops-toolkit version
```

### 显示帮助

```bash
ops-toolkit help
```

### 卸载

```bash
ops-toolkit uninstall
```

或者使用根目录的卸载脚本：

```bash
./uninstall.sh
```

## 组件列表

### Shell & Git

- git-config: 配置 Git 用户名和邮箱
- ssh-key: 生成 SSH 密钥对
- zsh-ohmyzsh: 安装 Zsh 和 Oh My Zsh
- zsh-plugins: 配置 Zsh 插件和主题
- bash-enhanced: 增强 Bash 配置

### 编辑器

- vim-basic: 基础 Vim 配置
- neovim-config: Neovim 配置
- vscode-extensions: 常用 VSCode 扩展

## 项目结构

```
ops-toolkit/
├── bin/                # 可执行文件
├── components/         # 组件实现
│   ├── shell-git/      # Shell & Git 组件
│   └── editor/         # 编辑器组件
├── configs/            # 配置模板
├── lib/                # 核心库
├── tests/              # 测试文件
├── install.sh          # 安装脚本
└── uninstall.sh        # 卸载脚本
```

## 开发

详细的开发指南请参考：
- [组件开发指南](docs/components.md)
- [贡献指南](docs/contributing.md)

### 运行测试

```bash
./scripts/test.sh
```

### 代码检查

```bash
./scripts/lint.sh
```

## 系统要求

- Bash 4.0+
- Git
- 支持的操作系统：MacOS, Ubuntu, Debian, CentOS

## 许可证

MIT License
