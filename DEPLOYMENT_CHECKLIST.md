# Cloudflare Pages 部署检查清单

在开始部署之前，请确保你已完成以下步骤。按照顺序勾选每一项。

## 前置准备

- [ ] 已有 GitHub 账号
- [ ] 已有 Cloudflare 账号
- [ ] 域名 `blog.windsay.qzz.io` 已在 Cloudflare 托管（或准备使用 pages.dev 子域名）
- [ ] 本地已安装 Node.js (推荐 v18，最低 v16)
- [ ] 本地已安装 Git
- [ ] 本地已安装 npm

## 第一步：创建博客仓库

- [ ] 在 GitHub 创建新的公开仓库（如 `my-hexo-blog`）
- [ ] **不要初始化 README、.gitignore 或 license**（保持仓库为空）
- [ ] 记录仓库 URL

**注意**：如果仓库已有内容，快速开始脚本支持强制覆盖选项

## 第二步：本地设置博客

### 使用快速开始脚本（推荐）

- [ ] 克隆 windsay 主题仓库或下载 `examples/quick-start.sh`
- [ ] 运行脚本：`bash quick-start.sh <博客目录名> <域名> [远程仓库URL]`
  - 示例：`bash quick-start.sh my-blog blog.example.com https://github.com/yourname/my-blog.git`
- [ ] 脚本将自动检查环境依赖（git, node >= 16, npm）
- [ ] 等待安装完成

**脚本自动完成的任务**：
- ✅ 验证环境依赖和 Node.js 版本
- ✅ 创建博客结构和安装依赖
- ✅ 配置域名和基本信息
- ✅ 添加主题作为 git 子模块
- ✅ 创建必要页面
- ✅ 初始化 Git 仓库
- ✅ 创建初始提交

### 手动设置（高级用户）

- [ ] 创建博客目录
- [ ] 初始化 npm 项目
- [ ] 安装 Hexo 和必要依赖
- [ ] 添加 windsay 主题为子模块
- [ ] 复制示例配置文件

## 第三步：配置博客

- [ ] 编辑 `_config.yml`
  - [ ] 修改网站标题、描述、作者
  - [ ] 设置 `url: https://blog.windsay.qzz.io`
  - [ ] 设置 `theme: windsay`
  - [ ] 设置 `language: zh-CN`
- [ ] 检查 `package.json` 中的依赖
- [ ] 验证 `.gitignore` 包含必要的忽略项

## 第四步：配置 GitHub Actions

- [ ] 复制 `examples/github-actions/deploy.yml` 到 `.github/workflows/`
- [ ] 编辑 `deploy.yml`
  - [ ] 修改 `projectName` 为你的项目名（如 `windsay-blog`）
  - [ ] 确认分支名称（main 或 master）
- [ ] （可选）添加预览部署工作流

## 第五步：获取 Cloudflare 凭证

- [ ] 登录 Cloudflare Dashboard
- [ ] 创建 API Token
  - [ ] 使用 "Edit Cloudflare Workers" 模板
  - [ ] 或设置权限：Account - Cloudflare Pages - Edit
  - [ ] 复制生成的 API Token
- [ ] 获取 Account ID
  - [ ] 在域名页面右侧栏找到 Account ID
  - [ ] 复制 Account ID

## 第六步：配置 GitHub Secrets 和权限

- [ ] 在 GitHub 仓库进入 Settings → Secrets and variables → Actions
- [ ] 添加 Secret：`CLOUDFLARE_API_TOKEN`
  - [ ] 粘贴你的 Cloudflare API Token
- [ ] 添加 Secret：`CLOUDFLARE_ACCOUNT_ID`
  - [ ] 粘贴你的 Cloudflare Account ID
- [ ] **⚠️ 重要：配置 GitHub Actions 权限**
  - [ ] 进入 Settings → Actions → General → Workflow permissions
  - [ ] 勾选 "Read and write permissions"
  - [ ] 否则 GitHub Actions 无法创建 Cloudflare Pages 项目
- [ ] （可选）添加仓库变量 `CUSTOM_DOMAIN`
  - [ ] 进入 Settings → Secrets and variables → Variables
  - [ ] 点击 "New repository variable"
  - [ ] 名称：`CUSTOM_DOMAIN`
  - [ ] 值：你的域名（如 `blog.example.com`）
  - [ ] GitHub Actions 将自动配置 Cloudflare Pages 域名

## 第七步：本地测试

- [ ] 运行 `npm install` 确保依赖安装完整
- [ ] 运行 `npm run server` 启动本地服务器
- [ ] 访问 `http://localhost:4000` 检查网站
- [ ] 检查主题是否正确加载
- [ ] 检查导航菜单是否正常工作

## 第八步：创建必要页面

- [ ] 创建分类页面：`hexo new page "categories"`
  - [ ] 设置 `type: "categories"` 和 `layout: "categories"`
- [ ] 创建标签页面：`hexo new page "tags"`
  - [ ] 设置 `type: "tags"` 和 `layout: "tags"`
- [ ] 创建关于页面：`hexo new page "about"`
  - [ ] 设置 `type: "about"` 和 `layout: "about"`
- [ ] 创建友链页面：`hexo new page "friends"`
  - [ ] 设置 `type: "friends"` 和 `layout: "friends"`
  - [ ] 创建 `source/_data/friends.json`

## 第九步：第一次部署

- [ ] 初始化 Git 仓库：`git init`
- [ ] 添加所有文件：`git add .`
- [ ] 提交更改：`git commit -m "Initial commit"`
- [ ] 添加远程仓库：`git remote add origin <你的仓库URL>`
- [ ] 推送到 GitHub：`git push -u origin main`
- [ ] 在 GitHub Actions 中查看构建状态
- [ ] 等待构建和部署完成（通常 3-5 分钟）

## 第十步：配置 Cloudflare Pages

### 方式一：通过 GitHub Actions 自动创建（推荐）

- [ ] 等待第一次部署完成
- [ ] Cloudflare Pages 项目会自动创建

### 方式二：手动创建

- [ ] 在 Cloudflare Dashboard 选择 "Workers & Pages"
- [ ] 点击 "Create application" → "Pages"
- [ ] 连接到你的 GitHub 仓库
- [ ] 设置构建命令：`npm run build`
- [ ] 设置输出目录：`public`
- [ ] 添加环境变量：`NODE_VERSION=18`
- [ ] 保存并部署

## 第十一步：配置自定义域名

- [ ] 在 Cloudflare Pages 项目中进入 "Custom domains"
- [ ] 点击 "Set up a custom domain"
- [ ] 输入：`blog.windsay.qzz.io`
- [ ] 等待 DNS 自动配置
- [ ] 等待 SSL 证书生成（通常几分钟）
- [ ] 访问 `https://blog.windsay.qzz.io` 验证部署成功

## 第十二步：日常使用

- [ ] 创建新文章：`hexo new post "文章标题"`
- [ ] 编辑文章内容
- [ ] 本地预览：`npm run server`
- [ ] 提交更改：`git add . && git commit -m "新文章：xxx"`
- [ ] 推送部署：`git push`
- [ ] 在 GitHub Actions 查看构建状态
- [ ] 访问网站确认更新

## 可选步骤

- [ ] 配置评论系统（Gitalk、Valine 等）
- [ ] 配置网站统计（Google Analytics、百度统计等）
- [ ] 自定义主题配置（修改 `themes/windsay/_config.yml`）
- [ ] 添加自定义 CSS/JS
- [ ] 配置 CDN 加速静态资源
- [ ] 设置 Pull Request 预览部署

## 故障排除清单

如果遇到问题，请检查：

- [ ] Node.js 版本是否为 18
- [ ] 所有依赖是否正确安装（运行 `npm install`）
- [ ] `_config.yml` 中的 `theme: windsay` 是否正确
- [ ] 主题子模块是否正确克隆（检查 `themes/windsay/` 目录）
- [ ] GitHub Secrets 是否正确设置
- [ ] Cloudflare API Token 权限是否足够
- [ ] GitHub Actions 工作流文件是否在正确位置
- [ ] 域名 DNS 设置是否正确
- [ ] 查看 GitHub Actions 构建日志
- [ ] 查看 Cloudflare Pages 部署日志

## 需要帮助？

- 📖 查看 [完整部署指南](DEPLOYMENT_GUIDE_CN.md)
- 💡 查看 [示例配置文件](examples/)
- 🐛 提交 [GitHub Issue](https://github.com/yorelll/windsay/issues)
- 📚 查看 [Hexo 官方文档](https://hexo.io/zh-cn/docs/)
- ☁️ 查看 [Cloudflare Pages 文档](https://developers.cloudflare.com/pages/)

---

完成所有步骤后，你应该能够：
- ✅ 通过 `https://blog.windsay.qzz.io` 访问你的博客
- ✅ 通过 `git push` 一键发布新文章
- ✅ 享受全球 CDN 加速
- ✅ 获得免费的 HTTPS 支持
