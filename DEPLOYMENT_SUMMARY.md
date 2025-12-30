# Hexo + Windsay 主题 Cloudflare Pages 部署方案总结

## 概述

本方案提供了将 Hexo 博客（使用 windsay 主题）部署到 Cloudflare Pages 的完整解决方案，实现本地 `git push` 一键发布。

## 架构设计

```
┌─────────────────────────────────────────────────────────────┐
│                      整体架构                                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  主题仓库 (yorelll/windsay)                                   │
│  └── 作为 Git 子模块被博客仓库引用                              │
│                                                              │
│  博客仓库 (your-username/my-hexo-blog)                        │
│  ├── 博客内容和配置                                            │
│  ├── themes/windsay (子模块)                                  │
│  └── .github/workflows/deploy.yml                           │
│                                                              │
│  GitHub Actions                                             │
│  └── 监听 push 事件 → 构建 → 部署到 Cloudflare Pages           │
│                                                              │
│  Cloudflare Pages                                           │
│  ├── 托管静态网站                                              │
│  ├── 全球 CDN 分发                                            │
│  ├── 自动 SSL 证书                                            │
│  └── 自定义域名: blog.windsay.qzz.io                          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 工作流程

```
本地写作 → git add/commit → git push → GitHub → GitHub Actions
                                           ↓
                                    自动构建 Hexo
                                           ↓
                                  部署到 Cloudflare Pages
                                           ↓
                              https://blog.windsay.qzz.io
```

## 已提供的文件和工具

### 1. 文档

| 文件名 | 描述 | 用途 |
|--------|------|------|
| **DEPLOYMENT_GUIDE_CN.md** | 完整部署指南 | 详细的步骤说明，包括所有配置细节 |
| **DEPLOYMENT_CHECKLIST.md** | 部署检查清单 | 确保不遗漏任何步骤 |
| **examples/README.md** | 示例文件说明 | 解释各个示例文件的用途 |

### 2. 配置文件示例

目录：`examples/blog-config/`

| 文件名 | 描述 |
|--------|------|
| **_config.yml** | Hexo 主配置文件 |
| **package.json** | npm 依赖和脚本配置 |
| **.gitignore** | Git 忽略文件配置 |
| **.nvmrc** | Node.js 版本配置 |

### 3. GitHub Actions 工作流

目录：`examples/github-actions/`

| 文件名 | 描述 |
|--------|------|
| **deploy.yml** | 主部署工作流（推荐） |
| **deploy-wrangler.yml** | 使用 Wrangler CLI 的替代方案 |
| **preview.yml** | Pull Request 预览部署 |

### 4. 自动化工具

| 文件名 | 描述 |
|--------|------|
| **examples/quick-start.sh** | 快速开始脚本，自动化设置整个博客项目 |

## 快速开始（3 分钟）

### 方式一：使用自动化脚本（最简单）

```bash
# 1. 克隆主题仓库（或下载脚本）
git clone https://github.com/yorelll/windsay.git

# 2. 运行快速开始脚本
cd windsay
bash examples/quick-start.sh my-hexo-blog

# 3. 进入博客目录
cd my-hexo-blog

# 4. 编辑配置文件
# - 修改 _config.yml 中的网站信息
# - 修改 .github/workflows/deploy.yml 中的项目名

# 5. 创建 GitHub 仓库并推送
git remote add origin https://github.com/你的用户名/my-hexo-blog.git
git push -u origin main
```

### 方式二：手动设置

详见 [DEPLOYMENT_GUIDE_CN.md](DEPLOYMENT_GUIDE_CN.md)

## 配置要点

### 1. Cloudflare 配置

需要设置的内容：

- **API Token**: 在 Cloudflare 创建，权限为 "Account - Cloudflare Pages - Edit"
- **Account ID**: 在 Cloudflare Dashboard 中获取
- **自定义域名**: blog.windsay.qzz.io

### 2. GitHub Secrets

需要添加到博客仓库的 Secrets：

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`

### 3. 博客配置 (_config.yml)

关键配置项：

```yaml
# 必须修改
url: https://blog.windsay.qzz.io
theme: windsay
language: zh-CN

# 推荐配置
per_page: 12  # 6 的倍数，主题显示更美观

# 代码高亮
prismjs:
  enable: true
```

### 4. GitHub Actions 配置

关键配置项：

```yaml
# deploy.yml
projectName: windsay-blog  # 改为你的项目名
branch: main               # 改为你的默认分支
```

## 部署流程

### 第一次部署

1. **本地设置**（10 分钟）
   - 创建博客项目
   - 安装依赖
   - 添加主题子模块
   - 配置文件

2. **GitHub 配置**（5 分钟）
   - 创建仓库
   - 设置 Secrets
   - 推送代码

3. **Cloudflare 配置**（5 分钟）
   - 自动创建项目（通过 GitHub Actions）
   - 配置自定义域名
   - 等待 SSL 证书

**总时间**：约 20-30 分钟

### 日常发布

```bash
# 1. 写文章
hexo new post "我的新文章"

# 2. 本地预览（可选）
npm run server

# 3. 提交并推送
git add .
git commit -m "新文章：我的新文章"
git push

# 4. 等待自动部署（3-5 分钟）
# 访问 https://blog.windsay.qzz.io
```

## 优势

### ✅ 开发体验

- **本地预览**：即时查看效果
- **版本控制**：完整的 Git 历史
- **主题管理**：子模块方式，易于更新
- **一键发布**：`git push` 即可

### ✅ 性能

- **全球 CDN**：Cloudflare 自带 CDN
- **自动优化**：自动压缩和缓存
- **快速部署**：通常 3-5 分钟
- **免费额度**：每月无限次构建和流量

### ✅ 安全性

- **HTTPS**：自动 SSL 证书
- **DDoS 防护**：Cloudflare 自带
- **环境隔离**：构建和生产环境分离
- **密钥管理**：GitHub Secrets 安全存储

### ✅ 可扩展性

- **PR 预览**：可配置预览部署
- **多环境**：支持开发/生产环境
- **自定义构建**：灵活的构建脚本
- **主题定制**：完全可控的主题配置

## 目录结构

最终的博客项目结构：

```
my-hexo-blog/
├── .github/
│   └── workflows/
│       └── deploy.yml              # GitHub Actions 工作流
├── source/
│   ├── _posts/                     # 文章目录
│   │   └── hello-world.md
│   ├── _data/
│   │   └── friends.json            # 友链数据
│   ├── about/
│   │   └── index.md                # 关于页面
│   ├── categories/
│   │   └── index.md                # 分类页面
│   ├── tags/
│   │   └── index.md                # 标签页面
│   └── friends/
│       └── index.md                # 友链页面
├── themes/
│   └── windsay/                    # 主题子模块
│       ├── _config.yml             # 主题配置
│       ├── layout/
│       ├── source/
│       └── ...
├── .gitignore                      # Git 忽略文件
├── .gitmodules                     # Git 子模块配置
├── .nvmrc                          # Node.js 版本
├── _config.yml                     # Hexo 主配置
├── package.json                    # npm 配置
└── package-lock.json               # 依赖锁定文件
```

## 常见问题

### Q: 主题更新后如何同步？

```bash
git submodule update --remote themes/windsay
git add themes/windsay
git commit -m "更新主题"
git push
```

### Q: 如何本地测试？

```bash
npm run server
# 访问 http://localhost:4000
```

### Q: 构建失败怎么办？

1. 查看 GitHub Actions 日志
2. 检查 Node.js 版本是否为 18
3. 确认所有依赖已安装
4. 验证配置文件语法

### Q: 如何回滚部署？

在 Cloudflare Pages 项目的 "Deployments" 页面，找到之前的成功部署，点击 "Rollback"。

### Q: 可以使用其他评论系统吗？

可以，主题支持多种评论系统（Gitalk、Valine、Waline 等），在主题的 `_config.yml` 中配置。

## 成本

- **GitHub**: 免费（公开仓库）
- **Cloudflare Pages**: 免费（无限构建和流量）
- **域名**: 已有（blog.windsay.qzz.io）

**总成本**: 0 元/月 🎉

## 下一步

完成部署后，你可以：

1. 自定义主题配置（`themes/windsay/_config.yml`）
2. 添加评论系统
3. 配置网站统计
4. 优化 SEO 设置
5. 添加自定义页面
6. 配置 RSS 订阅
7. 集成其他服务（音乐播放器、相册等）

## 获取帮助

- 📖 [完整部署指南](DEPLOYMENT_GUIDE_CN.md)
- ✅ [部署检查清单](DEPLOYMENT_CHECKLIST.md)
- 📋 [示例配置](examples/)
- 🐛 [提交 Issue](https://github.com/yorelll/windsay/issues)
- 📚 [Hexo 文档](https://hexo.io/zh-cn/docs/)
- ☁️ [Cloudflare Pages 文档](https://developers.cloudflare.com/pages/)

## 总结

本方案提供了：

1. ✅ **完整的文档**：从零到部署的详细说明
2. ✅ **示例配置**：开箱即用的配置文件
3. ✅ **自动化工具**：快速开始脚本
4. ✅ **CI/CD 集成**：GitHub Actions 自动部署
5. ✅ **检查清单**：确保不遗漏步骤
6. ✅ **故障排除**：常见问题解决方案

现在你可以开始享受 Hexo + Windsay + Cloudflare Pages 带来的愉快写作体验了！🚀
