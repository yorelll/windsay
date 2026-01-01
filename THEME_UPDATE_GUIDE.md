# Windsay 主题更新与维护指南

本指南详细说明如何更新 windsay 主题、维护博客内容，以及两者之间的关系。

## 📚 目录

- [仓库架构](#仓库架构)
- [更新主题](#更新主题)
- [修改主题](#修改主题)
- [博客内容更新](#博客内容更新)
- [常见问题](#常见问题)

## 仓库架构

### 两个独立仓库

Windsay 采用主题与内容分离的架构：

```
1️⃣  主题仓库 (yorelll/windsay)
   └─ Hexo 主题文件
   └─ 布局、样式、脚本
   └─ 文档和示例

2️⃣  博客仓库 (例如: yorelll/windsay-blog)
   └─ 博客配置 (_config.yml)
   └─ 文章内容 (source/_posts/)
   └─ 页面 (source/)
   └─ themes/windsay (作为 git 子模块)
```

### 为什么要分离？

**优点**:
- ✅ 主题和内容独立维护
- ✅ 主题可以单独更新，不影响博客内容
- ✅ 博客内容可以单独备份
- ✅ 多个博客可以共享同一个主题
- ✅ 主题更新不会覆盖你的文章和配置

**缺点**:
- ⚠️ 需要管理两个仓库
- ⚠️ 需要了解 git 子模块的使用

## 更新主题

### 方法一：使用 update.sh 脚本（推荐）⭐

最简单和最安全的方式是使用 `update.sh` 脚本，它提供了自动的 git stash 保护：

```bash
# 在博客根目录执行
cd my-hexo-blog
bash ../windsay/examples/update.sh
# 选择菜单选项 12：更新 windsay 主题到最新版本
```

**脚本自动处理**：
- ✅ 检测主题目录是否有本地修改
- ✅ 如果有修改，提供三个选项：
  1. 暂存本地更改后更新（推荐）- 自动使用 git stash
  2. 放弃本地更改并更新
  3. 取消更新
- ✅ 执行主题更新
- ✅ 自动恢复暂存的更改
- ✅ 如果恢复时有冲突，提供详细的解决指导
- ✅ 提示是否需要迁移主题配置到 `source/_data/theme_config.yml`

### 方法二：在博客项目中手动更新主题子模块

如果主题仓库已有更新，你可以在博客项目中手动更新主题：

**注意**：手动更新前建议先备份或暂存本地修改！

```bash
# 进入博客项目目录
cd my-hexo-blog

# 进入主题目录
cd themes/windsay

# 检查是否有本地修改
git status

# 如果有本地修改，建议先暂存
git stash save "Backup before theme update"

# 拉取最新的主题更新
git pull origin main

# 恢复暂存的修改（如果之前暂存了）
git stash pop

# 返回博客根目录
cd ../..

# 提交子模块更新
git add themes/windsay
git commit -m "Update windsay theme to latest version"
git push origin main
```

### 方法三：使用一行命令更新所有子模块

```bash
# 在博客根目录执行
git submodule update --remote themes/windsay

# 提交更新
git add themes/windsay
git commit -m "Update windsay theme"
git push origin main
```

### 查看主题版本

```bash
# 使用 update.sh 脚本
cd my-hexo-blog
bash ../windsay/examples/update.sh
# 选择菜单选项 13：查看主题版本信息

# 或手动查看
cd themes/windsay
git log -1 --oneline
git tag -l
```

## 修改主题

### 场景一：临时修改（仅用于当前博客）

如果你只想为自己的博客定制主题，不打算贡献回主题仓库：

```bash
# 在博客项目中直接修改主题文件
cd themes/windsay

# 编辑主题文件
# 例如: vim layout/index.ejs

# 提交到博客仓库（注意：这会"分离"子模块）
cd ../..
git add themes/windsay
git commit -m "Customize theme for my blog"
git push origin main
```

**注意**: 这种方法会使主题子模块处于"分离头指针"状态，将来难以同步主题仓库的更新。

### 场景二：Fork 主题仓库（推荐用于大量定制）

如果你需要大量定制主题：

1. **Fork 主题仓库**
   ```bash
   # 在 GitHub 上 fork yorelll/windsay 到你的账号
   # 例如: <your-username>/windsay
   ```

2. **更新博客项目使用你 fork 的主题**
   ```bash
   # 删除原有的主题子模块
   cd my-hexo-blog
   git submodule deinit themes/windsay
   git rm themes/windsay
   rm -rf .git/modules/themes/windsay
   
   # 添加你 fork 的主题
   git submodule add https://github.com/<your-username>/windsay.git themes/windsay
   
   # 提交更改
   git add .
   git commit -m "Switch to forked theme repository"
   git push origin main
   ```

3. **在你的主题 fork 中修改**
   ```bash
   cd themes/windsay
   
   # 创建新分支
   git checkout -b custom-features
   
   # 修改主题文件
   # ...
   
   # 提交到你的 fork
   git add .
   git commit -m "Add custom features"
   git push origin custom-features
   ```

4. **在博客中使用修改后的主题**
   ```bash
   cd themes/windsay
   git checkout custom-features
   git pull origin custom-features
   
   cd ../..
   git add themes/windsay
   git commit -m "Update to custom theme version"
   git push origin main
   ```

### 场景三：贡献回主题仓库

如果你的修改对其他人也有用：

1. **Fork 并克隆主题仓库**
   ```bash
   # Fork yorelll/windsay 到你的账号
   
   # 克隆你的 fork
   git clone https://github.com/<your-username>/windsay.git
   cd windsay
   
   # 添加上游仓库
   git remote add upstream https://github.com/yorelll/windsay.git
   ```

2. **创建功能分支并修改**
   ```bash
   # 创建新分支
   git checkout -b feature/new-feature
   
   # 修改主题文件
   # ...
   
   # 提交更改
   git add .
   git commit -m "Add new feature"
   git push origin feature/new-feature
   ```

3. **创建 Pull Request**
   - 在 GitHub 上从你的 fork 创建 PR 到 `yorelll/windsay`
   - 等待审核和合并

4. **在博客中测试修改**
   ```bash
   cd my-hexo-blog/themes/windsay
   
   # 添加你的 fork 作为远程仓库
   git remote add myfork https://github.com/<your-username>/windsay.git
   
   # 获取并切换到你的分支
   git fetch myfork
   git checkout feature/new-feature
   
   # 测试
   cd ../..
   hexo server
   ```

## 博客内容更新

### 日常写作流程

```bash
# 创建新文章
npx hexo new "文章标题"

# 编辑文章
# 文件位于: source/_posts/文章标题.md

# 本地预览
npx hexo server

# 访问 http://localhost:4000 查看效果

# 提交并发布
git add source/_posts/
git commit -m "Add new post: 文章标题"
git push origin main
```

### GitHub Actions 自动部署

推送到 main 分支后，GitHub Actions 会自动：

1. 检出代码和主题子模块
2. 安装依赖
3. 构建静态网站
4. 部署到 Cloudflare Pages

查看部署状态：
- GitHub 仓库 → Actions 标签
- 或查看 Cloudflare Pages 控制台

## 主题开发与测试

### 本地开发主题

如果你在开发主题功能：

```bash
# 克隆主题仓库
git clone https://github.com/yorelll/windsay.git
cd windsay

# 创建测试博客
cd ..
mkdir test-blog
cd test-blog

# 初始化 Hexo 项目
npm init -y
npm install hexo --save
# ... 安装其他依赖

# 链接主题（开发模式）
ln -s /path/to/windsay themes/windsay

# 或者复制主题
cp -r /path/to/windsay themes/

# 配置 _config.yml
# theme: windsay

# 启动开发服务器
npx hexo server --debug
```

### 主题热重载

使用 Hexo 的 watch 模式：

```bash
# 方法一：使用 hexo server 的 watch 功能
npx hexo server --watch

# 方法二：监听主题文件变化
npx hexo server & 
while inotifywait -e modify -r themes/windsay/; do
    npx hexo clean && npx hexo generate
done
```

## 版本管理最佳实践

### 主题版本标记

在主题仓库中使用 Git 标签标记版本：

```bash
cd windsay

# 创建版本标签
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# 列出所有版本
git tag -l
```

### 博客项目锁定主题版本

```bash
cd my-hexo-blog/themes/windsay

# 切换到特定版本
git checkout v1.0.0

cd ../..
git add themes/windsay
git commit -m "Lock theme to version 1.0.0"
git push origin main
```

## 常见问题

### Q1: 如何查看主题是否有更新？

```bash
cd themes/windsay

# 获取远程更新信息
git fetch origin

# 查看本地和远程的差异
git log HEAD..origin/main --oneline
```

### Q2: 更新主题后网站样式错乱怎么办？

```bash
# 清理缓存并重新生成
npx hexo clean
npx hexo generate
npx hexo server
```

### Q3: 我修改了主题文件，但更新主题会覆盖我的修改吗？

是的。解决方案：
1. Fork 主题仓库（推荐）
2. 在主题配置文件中修改，而不是直接修改代码
3. 使用主题的自定义功能（如果提供）

### Q4: 如何回退到旧版本的主题？

```bash
cd themes/windsay

# 查看历史版本
git log --oneline

# 回退到特定提交
git checkout <commit-hash>

# 或回退到特定标签
git checkout v1.0.0

cd ../..
git add themes/windsay
git commit -m "Rollback theme to v1.0.0"
git push origin main
```

### Q5: 子模块没有正确初始化怎么办？

```bash
# 在博客根目录执行
git submodule init
git submodule update

# 或一次性执行
git submodule update --init --recursive
```

### Q6: 如何彻底删除并重新添加主题？

```bash
# 删除子模块
git submodule deinit themes/windsay
git rm themes/windsay
rm -rf .git/modules/themes/windsay

# 重新添加
git submodule add https://github.com/yorelll/windsay.git themes/windsay

# 提交更改
git add .
git commit -m "Reinstall theme submodule"
git push origin main
```

### Q7: 主题更新后需要更新博客配置吗？

通常不需要，但有时主题的重大更新可能需要：
1. 查看主题的 CHANGELOG.md
2. 查看主题的 README.md 中的配置说明
3. 对比 `themes/windsay/_config.yml` 和你的博客 `_config.yml`

### Q8: 如何在不同环境使用不同的主题版本？

使用 Git 分支：

```bash
# 生产环境使用 main 分支
git checkout main
cd themes/windsay
git checkout v1.0.0

# 开发环境使用 dev 分支
git checkout dev
cd themes/windsay
git checkout main  # 或最新的开发版本
```

## 完整工作流示例

### 场景：更新博客内容并同步最新主题

```bash
# 1. 进入博客目录
cd my-hexo-blog

# 2. 更新主题到最新版本
cd themes/windsay
git pull origin main
cd ../..

# 3. 创建新文章
npx hexo new "我的新文章"

# 4. 编辑文章
vim source/_posts/我的新文章.md

# 5. 本地预览
npx hexo clean
npx hexo server

# 6. 提交所有更改
git add .
git commit -m "Update theme and add new post"
git push origin main

# 7. 等待 GitHub Actions 自动部署
```

### 场景：修改主题并发布

```bash
# 1. Fork 主题仓库并克隆
git clone https://github.com/<your-username>/windsay.git
cd windsay

# 2. 创建功能分支
git checkout -b feature/custom-style

# 3. 修改主题
# 编辑文件...

# 4. 提交到你的 fork
git add .
git commit -m "Customize theme style"
git push origin feature/custom-style

# 5. 在博客项目中使用你的修改
cd ../my-hexo-blog
git submodule deinit themes/windsay
git rm themes/windsay
git submodule add https://github.com/<your-username>/windsay.git themes/windsay

cd themes/windsay
git checkout feature/custom-style
cd ../..

# 6. 测试
npx hexo clean
npx hexo server

# 7. 提交
git add .
git commit -m "Use customized theme"
git push origin main
```

## 相关文档

- [部署指南](DEPLOYMENT_GUIDE_CN.md) - 完整的部署说明
- [文档索引](DOCUMENTATION_INDEX.md) - 所有文档的索引
- [README](README_CN.md) - 主题使用说明
- [快速开始脚本](examples/quick-start.sh) - 一键设置博客

## 获取帮助

如果遇到问题：

1. 查看 [GitHub Issues](https://github.com/yorelll/windsay/issues)
2. 搜索相关问题或创建新 issue
3. 查看 Hexo 官方文档
4. 查看 Git 子模块文档

---

**最后更新**: 2024-12-30
**维护者**: yorelll
