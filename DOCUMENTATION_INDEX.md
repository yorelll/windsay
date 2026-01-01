# Hexo 博客 Cloudflare Pages 部署 - 文档索引

欢迎！本索引将帮助你快速找到所需的文档和资源。

## 🚀 快速开始

**如果你想立即开始，按照以下顺序阅读：**

1. 📋 [部署检查清单](DEPLOYMENT_CHECKLIST.md) - 确保你具备所有前置条件
2. 📖 [完整部署指南](DEPLOYMENT_GUIDE_CN.md) - 详细的步骤说明
3. 🚀 使用 [快速开始脚本](examples/quick-start.sh) - 自动化设置

**预计时间**：20-30 分钟完成首次部署

## 📚 文档列表

### 核心文档

| 文档 | 描述 | 适合人群 | 阅读时间 |
|------|------|----------|----------|
| [DEPLOYMENT_GUIDE_CN.md](DEPLOYMENT_GUIDE_CN.md) | 完整部署指南 | 所有用户 | 15 分钟 |
| [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) | 部署检查清单 | 所有用户 | 5 分钟 |
| [DEPLOYMENT_SUMMARY.md](DEPLOYMENT_SUMMARY.md) | 部署方案总结 | 想了解全局的用户 | 10 分钟 |
| [THEME_UPDATE_GUIDE.md](THEME_UPDATE_GUIDE.md) | 主题更新维护指南 | 主题开发者/高级用户 | 20 分钟 |
| [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md) | 架构图和流程图 | 技术用户 | 5 分钟 |

### 示例和工具

| 资源 | 描述 | 位置 |
|------|------|------|
| 博客配置示例 | Hexo 配置文件模板 | [examples/blog-config/](examples/blog-config/) |
| GitHub Actions 工作流 | 自动部署配置 | [examples/github-actions/](examples/github-actions/) |
| 快速开始脚本 | 自动化设置工具 | [examples/quick-start.sh](examples/quick-start.sh) |
| 清理脚本 | 清理依赖和临时文件 | [examples/cleanup.sh](examples/cleanup.sh) |
| 示例文件说明 | 各示例文件用途 | [examples/README.md](examples/README.md) |

## 🎯 按需求查找文档

### 我是第一次使用 Hexo

1. 先阅读 [Hexo 官方文档](https://hexo.io/zh-cn/docs/)
2. 然后查看 [部署检查清单](DEPLOYMENT_CHECKLIST.md)
3. 使用 [快速开始脚本](examples/quick-start.sh) 自动设置
4. 参考 [完整部署指南](DEPLOYMENT_GUIDE_CN.md) 了解细节

### 我已经有 Hexo 博客，想迁移到 Cloudflare

1. 阅读 [部署方案总结](DEPLOYMENT_SUMMARY.md) 了解架构
2. 参考 [示例配置文件](examples/blog-config/) 修改现有配置
3. 复制 [GitHub Actions 工作流](examples/github-actions/deploy.yml)
4. 按照 [部署指南](DEPLOYMENT_GUIDE_CN.md) 的第三、四步操作

### 我想修改或更新主题

1. 阅读 [主题更新维护指南](THEME_UPDATE_GUIDE.md)
2. 了解主题与博客仓库的分离架构
3. 学习如何更新主题、Fork 主题、或贡献代码
4. 掌握版本管理和主题开发最佳实践

### 我想了解技术架构

1. 查看 [架构图文档](ARCHITECTURE_DIAGRAM.md)
2. 阅读 [部署方案总结](DEPLOYMENT_SUMMARY.md)
3. 研究 [GitHub Actions 工作流](examples/github-actions/)

### 我遇到了问题

1. 检查 [部署检查清单](DEPLOYMENT_CHECKLIST.md) 的故障排除部分
2. 查看 [完整部署指南](DEPLOYMENT_GUIDE_CN.md) 的常见问题
3. 在 [GitHub Issues](https://github.com/yorelll/windsay/issues) 搜索或提问

## 📖 文档详细说明

### DEPLOYMENT_GUIDE_CN.md
**完整部署指南**

- **内容**：从零开始的完整步骤
- **包含**：
  - 创建博客仓库
  - 配置 Cloudflare
  - 设置 GitHub Actions
  - 配置自定义域名
  - 日常使用流程
  - 常见问题解答
- **特点**：代码示例丰富，步骤详细

### DEPLOYMENT_CHECKLIST.md
**部署检查清单**

- **内容**：可勾选的检查清单
- **包含**：
  - 前置准备检查
  - 12 个主要步骤
  - 每步的子任务
  - 故障排除清单
- **特点**：确保不遗漏任何步骤

### DEPLOYMENT_SUMMARY.md
**部署方案总结**

- **内容**：高层次的方案概览
- **包含**：
  - 架构设计
  - 工作流程
  - 文件清单
  - 快速开始
  - 配置要点
  - 优势分析
- **特点**：适合快速了解全局

### ARCHITECTURE_DIAGRAM.md
**架构图和流程图**

- **内容**：可视化的架构说明
- **包含**：
  - 整体架构图
  - 工作流详细步骤
  - 数据流向图
  - 主题管理关系
  - 域名解析流程
  - 缓存策略
  - 安全架构
  - 成本结构
  - 性能指标
- **特点**：图形化展示，易于理解

## 🛠️ 示例文件说明

### examples/blog-config/

包含博客根目录需要的配置文件：

- **_config.yml** - Hexo 主配置
  - 网站信息
  - URL 配置
  - 主题设置
  - 插件配置
- **package.json** - npm 依赖
  - 所有必需的包
  - 构建脚本
- **.gitignore** - Git 忽略规则
  - 排除 node_modules
  - 排除构建产物
- **.nvmrc** - Node.js 版本
  - 指定版本 18

### examples/github-actions/

包含 GitHub Actions 工作流配置：

- **deploy.yml** - 主部署工作流 ⭐ **推荐使用**
  - 监听 push 事件
  - 自动构建和部署
  - 使用 Cloudflare Pages Action
- **deploy-wrangler.yml** - 使用 Wrangler CLI 的替代方案
  - 提供更多自定义选项
  - 适合高级用户
- **preview.yml** - PR 预览部署
  - 为 Pull Request 创建预览
  - 自动评论 PR

### examples/quick-start.sh

自动化设置脚本：

- **功能**：
  - ✅ 检查环境依赖（git, node >= 16, npm）
  - ✅ 创建博客目录
  - ✅ 安装所有依赖
  - ✅ 正确配置 package.json（包含 hexo.version 字段）
  - ✅ 添加便捷的 npm scripts
  - ✅ 添加主题子模块
  - ✅ 复制配置文件
  - ✅ 创建必要页面
  - ✅ 初始化 Git
  - ✅ 支持非空远程仓库（强制推送选项）
  - ✅ GitHub Actions 权限配置提醒
  - ✅ 自定义域名自动配置支持
- **用法**：`bash quick-start.sh <博客目录名> <域名> [远程仓库URL]`
- **更新**：v2.0 版本，包含完整的依赖检查和错误处理

### examples/update.sh

博客内容和配置管理脚本：

- **功能**：
  - 📝 **内容管理**：创建、编辑、删除、搜索文章
  - ⚙️ **配置管理**：修改博客信息、域名（可同步到 Cloudflare）
  - 🎨 **主题管理**：更新主题（带 git stash 保护）、查看版本
  - 🚀 **部署**：本地预览、构建、提交推送
  - 🔧 **维护**：清理缓存、重装依赖、查看统计
- **用法**：在博客目录运行 `bash /path/to/update.sh`
- **更新**：重新组织菜单，新增编辑/删除/搜索文章功能，域名 Cloudflare 同步

### examples/cleanup.sh

清理脚本，用于释放磁盘空间：

- **功能**：
  - 删除 node_modules
  - 删除 yarn.lock 和 pnpm-lock.yaml
  - 删除生成的 public 目录
  - 删除 Hexo 缓存文件
  - ✅ **保留 package-lock.json**（确保依赖版本一致）
  - 保留文章、配置和主题
- **用法**：`bash cleanup.sh /path/to/blog`
- **特点**：安全的清理，保留重要文件，带 set -euo pipefail 错误处理

## 🔄 典型使用流程

### 首次部署流程

```
1. 阅读部署检查清单
   ↓
2. 使用快速开始脚本 / 手动设置
   ↓
3. 编辑配置文件
   ↓
4. 配置 GitHub 和 Cloudflare
   ↓
5. 推送代码
   ↓
6. 等待自动部署
   ↓
7. 访问你的网站 ✅
```

### 日常写作流程

```
1. hexo new post "文章标题" 或 npm run new "文章标题"
   ↓
2. 编辑 Markdown 文件
   ↓
3. hexo server 或 npm run server (本地预览)
   ↓
4. git add/commit/push
   ↓
5. 自动部署 ✅
```

### 主题更新流程

```
1. cd themes/windsay
   ↓
2. git pull origin main
   ↓
3. 测试本地预览
   ↓
4. git add/commit/push
   ↓
5. 自动部署 ✅
```

详细说明请查看 [主题更新维护指南](THEME_UPDATE_GUIDE.md)

### 清理博客资源流程

```
1. bash examples/cleanup.sh
   ↓
2. 确认删除
   ↓
3. node_modules 等依赖被删除
   ↓
4. 磁盘空间释放 ✅
   ↓
5. (可选) npm install 重新安装依赖
```

## 💡 推荐阅读顺序

### 快速上手（30 分钟）

1. [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) - 5 分钟
2. [examples/quick-start.sh](examples/quick-start.sh) - 运行脚本
3. [DEPLOYMENT_GUIDE_CN.md](DEPLOYMENT_GUIDE_CN.md) 第三到第十一步 - 20 分钟

### 深入了解（1 小时）

1. [DEPLOYMENT_SUMMARY.md](DEPLOYMENT_SUMMARY.md) - 15 分钟
2. [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md) - 10 分钟
3. [DEPLOYMENT_GUIDE_CN.md](DEPLOYMENT_GUIDE_CN.md) 完整阅读 - 30 分钟
4. [examples/README.md](examples/README.md) - 5 分钟

### 问题排查

1. [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) 故障排除部分
2. [DEPLOYMENT_GUIDE_CN.md](DEPLOYMENT_GUIDE_CN.md) 常见问题部分
3. GitHub Actions 构建日志
4. Cloudflare Pages 部署日志

## 🆘 获取帮助

遇到问题时的求助流程：

1. **查看文档**
   - 先查看相关文档的"常见问题"部分
   - 使用文档内的搜索功能

2. **检查日志**
   - GitHub Actions 运行日志
   - Cloudflare Pages 部署日志
   - 浏览器控制台错误

3. **搜索问题**
   - 在 [GitHub Issues](https://github.com/yorelll/windsay/issues) 搜索
   - 在 Hexo 社区搜索
   - 在 Cloudflare 社区搜索

4. **提问**
   - [提交 GitHub Issue](https://github.com/yorelll/windsay/issues/new)
   - 提供详细的错误信息
   - 包含配置文件（去除敏感信息）

## 📝 贡献

如果你发现文档有错误或可以改进的地方：

1. Fork 仓库
2. 修改文档
3. 提交 Pull Request

或者直接 [提交 Issue](https://github.com/yorelll/windsay/issues/new)

## 🔗 外部资源

- [Hexo 官方文档](https://hexo.io/zh-cn/docs/)
- [Cloudflare Pages 文档](https://developers.cloudflare.com/pages/)
- [GitHub Actions 文档](https://docs.github.com/cn/actions)
- [Markdown 语法参考](https://www.markdownguide.org/)

## ✨ 特别说明

本文档集提供了三种不同深度的使用方式：

1. **快速模式**：使用检查清单 + 快速脚本（20 分钟）
2. **标准模式**：阅读完整指南 + 手动配置（1 小时）
3. **深入模式**：研究架构 + 自定义配置（2+ 小时）

选择适合你的方式开始！

---

**最后更新**: 2024-12-30

**维护者**: [yorelll](https://github.com/yorelll)

**许可证**: MIT
