# 组件开发指南

本文档介绍如何为 ops-toolkit 开发新的组件。

## 组件概述

组件是 ops-toolkit 的核心功能模块，每个组件负责一个特定的功能或配置。

## 组件结构

每个组件应该包含以下内容：

### 必需变量

```bash
COMPONENT_ID="my-component"          # 组件唯一标识符
COMPONENT_NAME="我的组件"             # 组件显示名称
COMPONENT_DESC="组件的简短描述"       # 组件描述
COMPONENT_CATEGORY="category-name"    # 组件类别
COMPONENT_DEPS=""                     # 依赖的其他组件（空格分隔）
```

### 必需函数

#### component_detect()

检测组件是否已安装/配置。

```bash
component_my_component_detect() {
  # 检测逻辑
  # 返回 0 表示已安装，返回 1 表示未安装
  return 0
}
```

#### component_install()

安装/配置组件。

```bash
component_my_component_install() {
  # 安装逻辑
  # 返回 0 表示成功，返回非 0 表示失败
  return 0
}
```

### 可选函数

#### component_uninstall()

卸载组件。

```bash
component_my_component_uninstall() {
  # 卸载逻辑
  return 0
}
```

#### component_status()

获取组件状态详情。

```bash
component_my_component_status() {
  # 输出状态详情
  echo "状态信息"
}
```

#### component_post_install_message()

安装后显示提示信息。

```bash
component_my_component_post_install_message() {
  echo "请重启您的终端以应用更改"
}
```

## 创建新组件步骤

### 1. 选择组件类别

首先确定组件属于哪个类别，或创建新的类别：

现有类别：
- `shell-git`: Shell 和 Git 相关组件
- `editor`: 编辑器配置组件

### 2. 创建组件文件

在对应类别目录下创建组件文件，文件名格式为 `<component-id>.sh`：

```bash
components/<category>/<component-id>.sh
```

### 3. 实现组件

按照上述模板实现组件的必需变量和函数。

### 4. 添加测试

为新组件创建集成测试：

```bash
tests/integration/test_<component-id>.sh
```

### 5. 更新列表命令

确保 `lib/list.sh` 和 `lib/init.sh` 包含新组件。

## 组件命名规范

- 组件 ID 使用小写字母和连字符，如 `git-config`
- 组件文件使用组件 ID 命名，如 `git-config.sh`
- 函数名使用 `component_<component-id>_<function-name>` 格式，将连字符替换为下划线

## 最佳实践

1. **幂等执行**：组件可以安全地多次执行
2. **用户友好**：提供清晰的提示和确认
3. **错误处理**：正确处理错误并提供有意义的错误信息
4. **备份配置**：修改用户配置前先备份
5. **检测现有配置**：在安装前检测是否已配置

## 示例组件

参考现有组件实现：

- `components/shell-git/git-config.sh`
- `components/editor/vim-basic.sh`
