# Quick Start v2.0 功能说明

## 概述

Quick Start v2.0 是对原有快速开始脚本的重大增强，旨在提供更加流畅和用户友好的博客创建体验。

## 主要改进

### 1. 域名参数必填

**之前**: 用户需要手动编辑 `_config.yml` 来配置域名
**现在**: 域名作为必填参数，脚本自动配置

```bash
# v1.0 (旧版)
bash examples/quick-start.sh my-blog
# 然后手动编辑 _config.yml 修改域名

# v2.0 (新版)
bash examples/quick-start.sh my-blog blog.example.com
# 域名自动配置完成
```

### 2. Hero 区域自动初始化

**新增功能**: 自动创建 `source/_data/theme_config.yml`，用户可以轻松自定义：
- Hero 轮播图
- 音乐播放器
- 梦想语句
- 主题颜色
- 等等

### 3. 自动创建第一篇文章

**新增功能**: 自动创建欢迎文章，包含：
- 博客使用说明
- 常用命令
- 下一步建议
- 资源链接

**模板文件**: `examples/blog-config/welcome-post.md`  
**生成位置**: `source/_posts/welcome-to-my-blog.md`

**优点**:
- 可以自定义模板内容
- 使用标准的 Hexo 写作流程
- 方便版本控制和维护

### 4. Git 自动化和自动推送

**新增功能**: 脚本自动完成：
- `git init` - 初始化仓库
- `git add .` - 添加所有文件
- `git commit` - 创建描述性提交
- `git branch -M main` - 设置主分支
- `git remote add origin` - 添加远程仓库（可选）
- `git push -u origin main` - 推送代码（可选）

**支持两种工作流**:

1. **自动推送模式**（推荐）：
```bash
# 提供远程仓库 URL，脚本自动推送
bash examples/quick-start.sh my-blog blog.example.com https://github.com/用户名/my-blog.git
```

2. **手动推送模式**：
```bash
# 不提供仓库 URL，稍后手动推送
bash examples/quick-start.sh my-blog blog.example.com
# 稍后手动执行
git remote add origin https://github.com/用户名/my-blog.git
git push -u origin main
```

**支持 HTTPS 和 SSH**:
- HTTPS: `https://github.com/用户名/仓库名.git` (默认，可能需要输入凭据)
- SSH: `git@github.com:用户名/仓库名.git` (需要预先配置 SSH 密钥)

### 5. 智能验证和提醒

**新增功能**:
- 域名格式验证
- 参数完整性检查
- 配置信息确认提示
- 仓库名称一致性强调
- 详细的下一步指导

### 6. update.sh 管理工具

**新增脚本**: 提供交互式菜单管理博客：

**内容管理**:
- 创建新文章
- 创建草稿
- 发布草稿
- 列出所有文章

**配置更新**:
- 修改博客信息
- 修改域名
- 自定义主题
- 更新友情链接

**主题管理**:
- 更新主题
- 查看版本

**部署工具**:
- 本地预览
- 构建静态文件
- 提交并推送

**维护工具**:
- 清理缓存
- 重新安装依赖
- 查看统计信息

## 使用流程对比

### v1.0 工作流程（旧版）

```
1. bash examples/quick-start.sh my-blog
2. cd my-blog
3. 手动编辑 _config.yml 修改域名
4. 手动编辑 _config.yml 修改站点信息
5. 手动创建第一篇文章
6. 手动初始化 Git
7. 手动 git add, commit
8. 在 GitHub 创建仓库
9. git remote add origin ...
10. git push
11. 手动配置 Cloudflare Secrets
12. 等待部署
```

### v2.0 工作流程（新版）

**方式一：自动推送（推荐）**
```
1. 在 GitHub 创建名为 windsay-blog 的仓库（Public，不要初始化）
2. 添加 Cloudflare Secrets 到 GitHub
   - CLOUDFLARE_API_TOKEN
   - CLOUDFLARE_ACCOUNT_ID
3. bash examples/quick-start.sh windsay-blog blog.example.com https://github.com/用户名/windsay-blog.git
   (脚本会提醒你完成配置，然后自动推送)
4. 博客自动部署完成！

后续更新:
5. bash ../windsay/examples/update.sh
   (使用交互式菜单管理博客)
```

**方式二：手动推送**
```
1. bash examples/quick-start.sh windsay-blog blog.example.com
   (自动完成: 域名配置、Hero 初始化、创建文章、Git 提交)
2. 在 GitHub 创建名为 windsay-blog 的仓库
3. 添加 Cloudflare Secrets
4. cd windsay-blog
5. git remote add origin https://github.com/用户名/windsay-blog.git
6. git push -u origin main
7. 博客自动部署！

后续更新:
8. bash ../windsay/examples/update.sh
   (使用交互式菜单管理博客)
```

## 关键改进点

### 时间节省
- **v1.0**: ~30-45 分钟
- **v2.0 (手动推送)**: ~10-15 分钟
- **v2.0 (自动推送)**: ~5-8 分钟

### 手动步骤
- **v1.0**: 12 个手动步骤
- **v2.0 (手动推送)**: 4 个手动步骤
- **v2.0 (自动推送)**: 2 个手动步骤 (创建仓库 + 配置 Secrets)

### 错误风险
- **v1.0**: 高（多个手动配置步骤）
- **v2.0**: 低（自动化配置，验证检查）

### 用户体验
- **v1.0**: 需要技术背景，容易出错
- **v2.0**: 友好，有清晰指导，难以出错

## 必要提醒

### 仓库名称必须一致

这是 v2.0 最重要的概念：

```
本地目录名 = GitHub 仓库名 = Cloudflare 项目名
```

例如：
- 本地目录：`windsay-blog`
- GitHub 仓库：`windsay-blog`
- Cloudflare 项目：`windsay-blog`

**为什么重要？**
- GitHub Actions 自动部署依赖于项目名匹配
- Cloudflare Pages 需要正确的项目名
- 保持一致性避免混淆

### 域名配置

脚本会自动配置以下位置的域名：
1. `_config.yml` 中的 `url` 字段
2. 第一篇文章中的示例链接
3. 部署工作流的环境变量

确保在 Cloudflare Pages 中也配置相同的自定义域名。

## 兼容性

### 操作系统
- ✅ Linux (已测试)
- ✅ macOS (已适配 sed 语法)
- ⚠️ Windows (推荐使用 WSL 或 Git Bash)

### Node.js 版本
- 推荐: Node.js 18+
- 最低: Node.js 14+

### Git 版本
- 最低: Git 2.0+

## 故障排除

### 问题: "无效的域名格式"

**解决方案**: 确保域名格式正确
```bash
# ✅ 正确
bash examples/quick-start.sh my-blog blog.example.com
bash examples/quick-start.sh my-blog example.com

# ❌ 错误
bash examples/quick-start.sh my-blog https://blog.example.com
bash examples/quick-start.sh my-blog blog.example.com/
```

### 问题: 推送失败 "rejected"

这是用户在问题描述中遇到的问题。现在脚本提供了解决方案：

**场景 1: 远程仓库已有内容**
```bash
# 脚本会提示，但如果手动操作
cd windsay-blog
git pull origin main --allow-unrelated-histories
git push -u origin main
```

**场景 2: HTTPS 需要身份验证**
- 使用 Personal Access Token 代替密码
- 创建: https://github.com/settings/tokens
- 或使用 SSH 方式: `git@github.com:用户名/仓库名.git`

**场景 3: SSH 密钥未配置**
```bash
# 生成 SSH 密钥
ssh-keygen -t ed25519 -C "your_email@example.com"

# 添加到 GitHub
# 访问 https://github.com/settings/keys
```

### 问题: Git 子模块克隆失败

**解决方案**: 
1. 检查网络连接
2. 使用脚本提供的镜像站选项
3. 配置 Git 代理
4. 使用 SSH 方式

详见 [examples/README.md](README.md#网络和克隆问题)

### 问题: sed 命令在 macOS 上失败

**解决方案**: v2.0 已自动检测操作系统并使用正确的 sed 语法。如果仍有问题：
```bash
# 手动安装 GNU sed (可选)
brew install gnu-sed
```

## 未来改进计划

- [ ] 添加更多主题配置选项到初始化流程
- [ ] 支持自定义第一篇文章模板
- [ ] 添加可选的 analytics 配置
- [ ] 提供更多部署平台选项 (Vercel, Netlify)
- [ ] 添加自动化测试
- [ ] 支持从现有博客迁移

## 反馈和贡献

如果你有任何问题或建议，欢迎：
- 提交 Issue: https://github.com/yorelll/windsay/issues
- 提交 Pull Request
- 在讨论区分享你的经验

## 版本历史

### v2.0.0 (2025-12-31)
- ✨ 新增域名必填参数
- ✨ 新增 Hero 区域自动初始化
- ✨ 新增第一篇文章自动创建（模板化）
- ✨ 新增 Git 自动提交
- ✨ 新增可选的远程仓库 URL 参数
- ✨ 新增自动推送到 GitHub 功能
- ✨ 支持 HTTPS 和 SSH 两种推送方式
- ✨ 新增推送前配置提醒（Cloudflare + GitHub Actions）
- ✨ 新增推送失败错误处理和指导
- ✨ 新增 update.sh 管理工具
- 🐛 修复 macOS sed 兼容性问题
- 📝 更新所有文档

### v1.0.0
- 基础的博客创建功能
- 主题子模块集成
- 基本配置文件复制
