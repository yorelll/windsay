# Hexo 博客部署到 Cloudflare Pages 完整指南

本指南将帮助你将使用 windsay 主题的 Hexo 博客部署到 Cloudflare Pages，实现本地 push 后自动发布。

## 架构说明

- **主题仓库**: `yorelll/windsay` - 存放 Hexo 主题文件
- **博客仓库**: 你需要创建一个新的仓库来存放博客内容和文章
- **部署平台**: Cloudflare Pages
- **域名**: blog.windsay.qzz.io

## 第一步：创建博客仓库

### 1.1 在 GitHub 创建新仓库

1. 访问 https://github.com/new
2. 仓库名称建议: `my-hexo-blog` 或 `windsay-blog`
3. 设置为 Public（Cloudflare Pages 免费版需要 public 仓库）
4. 不要初始化 README、.gitignore 或 license

### 1.2 在本地初始化博客项目

```bash
# 创建博客目录
mkdir my-hexo-blog
cd my-hexo-blog

# 初始化 npm 项目
npm init -y

# 安装 Hexo 和必要依赖
npm install hexo-cli -g
npm install hexo --save
npm install hexo-server --save
npm install hexo-deployer-git --save
npm install hexo-generator-archive --save
npm install hexo-generator-category --save
npm install hexo-generator-index --save
npm install hexo-generator-tag --save
npm install hexo-renderer-ejs --save
npm install hexo-renderer-marked --save
npm install hexo-renderer-stylus --save

# 安装主题推荐的插件
npm install hexo-wordcount --save
npm install hexo-generator-search --save
npm install hexo-permalink-pinyin --save
npm install hexo-generator-feed --save
npm install hexo-filter-github-emojis --save

# 初始化 Hexo
hexo init .
```

### 1.3 配置主题

将主题添加为 Git 子模块：

```bash
# 添加主题作为子模块
git submodule add https://github.com/yorelll/windsay.git themes/windsay

# 或者如果你 fork 了主题仓库
git submodule add https://github.com/你的用户名/windsay.git themes/windsay
```

### 1.4 配置博客 _config.yml

编辑根目录的 `_config.yml` 文件：

```yaml
# 网站信息
title: 我的博客
subtitle: '记录生活，分享技术'
description: '这是我的个人博客'
keywords: 博客,技术,生活
author: Your Name
language: zh-CN
timezone: 'Asia/Shanghai'

# URL 配置
url: https://blog.windsay.qzz.io
root: /
permalink: :year/:month/:day/:title/
permalink_defaults:
pretty_urls:
  trailing_index: true
  trailing_html: true

# 目录配置
source_dir: source
public_dir: public
tag_dir: tags
archive_dir: archives
category_dir: categories
code_dir: downloads/code
i18n_dir: :lang
skip_render:

# 写作配置
new_post_name: :title.md
default_layout: post
titlecase: false
external_link:
  enable: true
  field: site
  exclude: ''
filename_case: 0
render_drafts: false
post_asset_folder: false
relative_link: false
future: true

# 主题配置
theme: windsay

# 分页配置
per_page: 12
pagination_dir: page

# 代码高亮配置（Hexo 5.0+）
highlight:
  enable: false
  line_number: true
  auto_detect: false
  tab_replace: ''
  wrap: true
  hljs: false

prismjs:
  enable: true
  preprocess: true
  line_number: true
  tab_replace: ''

# 搜索配置
search:
  path: search.xml
  field: post

# 中文链接转拼音
permalink_pinyin:
  enable: true
  separator: '-'

# RSS 配置
feed:
  type: atom
  path: atom.xml
  limit: 20
  hub:
  content:
  content_limit: 140
  content_limit_delim: ' '
  order_by: -date

# Emoji 支持
githubEmojis:
  enable: true
  className: github-emoji
  inject: true
  styles:
  customEmojis:

# 部署配置（可选，如果使用 hexo deploy）
deploy:
  type: git
  repo: https://github.com/你的用户名/my-hexo-blog.git
  branch: gh-pages
```

## 第二步：配置 Cloudflare Pages 部署

### 2.1 创建必要的配置文件

在博客根目录创建以下文件：

#### package.json（确保包含以下脚本）

```json
{
  "name": "my-hexo-blog",
  "version": "1.0.0",
  "description": "My Hexo Blog",
  "scripts": {
    "build": "hexo clean && hexo generate",
    "clean": "hexo clean",
    "deploy": "hexo deploy",
    "server": "hexo server",
    "dev": "hexo server --draft"
  },
  "hexo": {
    "version": "7.3.0"
  },
  "dependencies": {
    "hexo": "^7.0.0",
    "hexo-deployer-git": "^4.0.0",
    "hexo-filter-github-emojis": "^3.0.4",
    "hexo-generator-archive": "^2.0.0",
    "hexo-generator-category": "^2.0.0",
    "hexo-generator-feed": "^3.0.0",
    "hexo-generator-index": "^3.0.0",
    "hexo-generator-search": "^2.4.3",
    "hexo-generator-tag": "^2.0.0",
    "hexo-permalink-pinyin": "^2.0.0",
    "hexo-renderer-ejs": "^2.0.0",
    "hexo-renderer-marked": "^6.0.0",
    "hexo-renderer-stylus": "^3.0.0",
    "hexo-server": "^3.0.0",
    "hexo-wordcount": "^6.0.1"
  }
}
```

#### .nvmrc（指定 Node.js 版本）

```
18
```

#### .gitignore

```
.DS_Store
Thumbs.db
db.json
*.log
node_modules/
public/
.deploy*/
.idea/
.vscode/
*.swp
*.swo
*~
.deploy_git/
.idea
.deploy_git
.history
```

### 2.2 创建 GitHub Actions 工作流（推荐）

创建 `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Cloudflare Pages

on:
  push:
    branches:
      - main  # 或 master，根据你的默认分支

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4
      with:
        submodules: true  # 拉取主题子模块
        fetch-depth: 0    # 获取所有历史记录
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install Dependencies
      run: |
        npm ci
    
    - name: Build
      run: |
        npm run build
    
    - name: Publish to Cloudflare Pages
      uses: cloudflare/pages-action@v1
      with:
        apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
        accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
        projectName: windsay-blog  # 你的 Cloudflare Pages 项目名
        directory: public
        gitHubToken: ${{ secrets.GITHUB_TOKEN }}
        branch: main
```

## 第三步：配置 Cloudflare

### 3.1 获取 Cloudflare API Token

1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. 点击右上角头像 → "My Profile" → "API Tokens"
3. 点击 "Create Token"
4. 使用 "Edit Cloudflare Workers" 模板或创建自定义 token
5. 权限设置：
   - Account - Cloudflare Pages - Edit
6. 复制生成的 API Token

### 3.2 获取 Account ID

1. 在 Cloudflare Dashboard 中
2. 选择你的域名
3. 在右侧栏找到 "Account ID"
4. 复制 Account ID

### 3.3 配置 GitHub Secrets

1. 在你的博客 GitHub 仓库中，进入 Settings → Secrets and variables → Actions
2. 添加以下 secrets：
   - `CLOUDFLARE_API_TOKEN`: 你的 Cloudflare API Token
   - `CLOUDFLARE_ACCOUNT_ID`: 你的 Cloudflare Account ID

### 3.4 创建 Cloudflare Pages 项目

#### 方法一：通过 Cloudflare Dashboard 创建

1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. 选择 "Workers & Pages"
3. 点击 "Create application" → "Pages" → "Connect to Git"
4. 选择你的博客仓库
5. 构建配置：
   - **构建命令**: `npm run build`
   - **构建输出目录**: `public`
   - **环境变量**:
     - `NODE_VERSION`: `18`
6. 点击 "Save and Deploy"

#### 方法二：通过 GitHub Actions 自动创建（推荐）

使用上面的 GitHub Actions 配置，第一次 push 时会自动创建项目。

### 3.5 配置自定义域名

1. 在 Cloudflare Pages 项目中
2. 进入 "Custom domains"
3. 点击 "Set up a custom domain"
4. 输入: `blog.windsay.qzz.io`
5. Cloudflare 会自动配置 DNS 记录（因为域名已在 Cloudflare 托管）
6. 等待 SSL 证书生成（通常几分钟）

## 第四步：初始化 Git 并推送

```bash
# 初始化 git 仓库
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit: Hexo blog with windsay theme"

# 添加远程仓库
git remote add origin https://github.com/你的用户名/my-hexo-blog.git

# 推送到 GitHub
git push -u origin main
```

## 第五步：本地写作和发布工作流

### 5.1 创建新文章

```bash
# 创建新文章
hexo new post "文章标题"

# 或创建草稿
hexo new draft "草稿标题"

# 将草稿发布为文章
hexo publish draft "草稿标题"
```

### 5.2 本地预览

```bash
# 启动本地服务器
hexo server

# 或使用 npm script
npm run server

# 访问 http://localhost:4000
```

### 5.3 发布到 Cloudflare

```bash
# 方式1: 通过 git push（推荐）
git add .
git commit -m "新文章：文章标题"
git push

# GitHub Actions 会自动构建并部署到 Cloudflare Pages
```

### 5.4 查看部署状态

1. 在 GitHub 仓库的 "Actions" 标签查看构建状态
2. 在 Cloudflare Pages 项目中查看部署历史
3. 访问 https://blog.windsay.qzz.io 查看网站

## 第六步：主题更新

当主题仓库有更新时：

```bash
# 更新主题子模块
git submodule update --remote themes/windsay

# 提交更新
git add themes/windsay
git commit -m "更新 windsay 主题"
git push
```

## 常见问题

### Q1: 构建失败，提示找不到主题

**解决方案**: 确保在 `.github/workflows/deploy.yml` 中启用了 `submodules: true`

### Q2: 部署后样式丢失

**解决方案**: 
1. 检查 `_config.yml` 中的 `url` 和 `root` 配置
2. 确保 `url: https://blog.windsay.qzz.io`
3. 确保 `root: /`

### Q3: 如何使用 hexo-wordcount 插件

主题已配置使用 hexo-wordcount，确保已安装：

```bash
npm install hexo-wordcount --save
```

在主题的 `_config.yml` 中启用：

```yaml
postInfo:
  date: true
  update: true
  wordCount: true
  totalCount: true
  min2read: true
  readCount: true
```

### Q4: 构建时间过长

**解决方案**:
1. 使用 `npm ci` 而不是 `npm install`（在 CI/CD 中）
2. 启用 npm 缓存（GitHub Actions 已配置）
3. 减少不必要的插件

### Q5: 如何回滚到之前的版本

```bash
# 在 Cloudflare Pages 项目中
# 进入 "Deployments"
# 找到之前的成功部署
# 点击 "Rollback to this deployment"
```

## 目录结构

最终的博客仓库目录结构：

```
my-hexo-blog/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── source/
│   ├── _posts/         # 文章目录
│   ├── _data/          # 数据文件
│   ├── about/
│   ├── categories/
│   ├── tags/
│   └── friends/
├── themes/
│   └── windsay/        # 主题子模块
├── .gitignore
├── .nvmrc
├── _config.yml         # Hexo 配置
├── package.json
└── package-lock.json
```

## 性能优化建议

### 1. 图片优化

- 使用图床服务（腾讯云 COS、七牛云、又拍云等）
- 压缩图片后再上传
- 使用 WebP 格式

### 2. CDN 配置

Cloudflare Pages 自带全球 CDN，无需额外配置。

### 3. 缓存优化

在 Cloudflare Pages 项目中配置缓存规则：
- HTML: 短时间缓存（1小时）
- CSS/JS: 长时间缓存（1年）
- 图片: 长时间缓存（1年）

## 安全建议

1. **保护 Secrets**: 不要在代码中硬编码 API Token
2. **使用 HTTPS**: Cloudflare 自动提供 SSL
3. **定期更新依赖**: `npm audit` 检查安全漏洞
4. **保护主题配置**: 不要在公开仓库中存放敏感信息（如评论系统的密钥）

## 进阶配置

### 使用环境变量

在 Cloudflare Pages 项目设置中添加环境变量：

```
NODE_VERSION=18
HEXO_ENV=production
```

在 `_config.yml` 中使用：

```yaml
# 生产环境使用压缩
minify:
  html:
    enable: true
  css:
    enable: true
  js:
    enable: true
```

### 配置多环境

创建 `_config.production.yml` 用于生产环境特定配置。

## 参考资源

- [Hexo 官方文档](https://hexo.io/zh-cn/docs/)
- [Cloudflare Pages 文档](https://developers.cloudflare.com/pages/)
- [windsay 主题仓库](https://github.com/yorelll/windsay)
- [Cloudflare Pages GitHub Action](https://github.com/cloudflare/pages-action)

## 技术支持

如有问题，可以：
1. 查看主题仓库的 [Issues](https://github.com/yorelll/windsay/issues)
2. 查看 Hexo 官方文档
3. 查看 Cloudflare 社区论坛
