# 贡献指南

感谢您对 ops-toolkit 项目的关注！我们欢迎所有形式的贡献。

## 行为准则

请尊重其他贡献者，保持友善和专业。

## 如何贡献

### 报告问题

如果您发现了 bug 或有功能建议，请：

1. 先搜索现有的 Issues，看是否已经有类似的问题
2. 如果没有，创建一个新的 Issue
3. 清楚地描述问题，包括：
   - 问题的详细描述
   - 复现步骤
   - 预期行为
   - 实际行为
   - 您的环境信息（操作系统、Shell 版本等）

### 提交代码

1. Fork 项目仓库
2. 创建您的特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交您的更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建一个 Pull Request

## 开发环境设置

1. 克隆仓库
   ```bash
   git clone https://github.com/your-username/ops-toolkit.git
   cd ops-toolkit
   ```

2. 安装依赖（如果有）
   ```bash
   # 项目使用纯 Bash 编写，无需额外依赖
   ```

## 代码规范

### Shell 脚本规范

项目遵循以下 Shell 脚本规范：

1. **文件头**：每个脚本文件应该包含文件头注释，包括描述、作者、日期等
2. **安全设置**：每个脚本开头应该包含：
   ```bash
   set -euo pipefail
   IFS=$'\n\t'
   ```
3. **函数注释**：每个公共函数应该有文档注释
4. **命名规范**：
   - 变量名使用小写和下划线
   - 函数名使用小写和下划线
   - 常量使用大写和下划线
5. **缩进**：使用 2 个空格缩进
6. **引号**：总是引用变量，除非有充分理由不引用

### 代码检查

提交前请运行代码检查：

```bash
./scripts/lint.sh
```

项目使用 ShellCheck 进行代码检查。

## 测试

### 运行测试

```bash
./scripts/test.sh
```

### 编写测试

- 所有新功能应该有对应的测试
- 单元测试放在 `tests/unit/` 目录
- 集成测试放在 `tests/integration/` 目录
- 端到端测试放在 `tests/e2e/` 目录

## 提交信息规范

提交信息应该清晰、简洁，遵循以下格式：

```
<type>: <subject>

<body>

<footer>
```

类型（type）可以是：
- `feat`: 新功能
- `fix`: 修复 bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 构建/工具相关

## Pull Request 流程

1. 确保您的代码通过所有测试
2. 确保代码检查没有警告
3. 更新相关文档（如果需要）
4. 创建 Pull Request
5. 描述您的更改
6. 等待代码审查
7. 根据审查意见进行修改（如果需要）
8. 合并！

## 许可证

通过贡献代码，您同意您的贡献将根据项目的 MIT 许可证进行许可。

## 联系我们

如有任何问题，请通过 Issues 联系我们。

再次感谢您的贡献！
