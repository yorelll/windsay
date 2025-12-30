# 博客配置文件

这个目录包含了 Hexo 博客项目根目录需要的配置文件。

## 📁 文件说明

### _config.yml
**Hexo 主配置文件**

这是 Hexo 博客的核心配置文件，需要放在博客项目的根目录。

**重要配置项**：
- `url`: 你的博客网址（例如：https://blog.windsay.qzz.io）
- `theme`: 主题名称，必须设置为 `windsay`
- `language`: 语言设置，中文用户使用 `zh-CN`
- `permalink`: 文章永久链接格式

**需要修改的地方**：
```yaml
# 网站信息
title: 我的博客              # 改成你的博客标题
subtitle: '记录生活，分享技术'  # 改成你的副标题
description: '这是我的个人博客'  # 改成你的描述
author: Your Name           # 改成你的名字

# URL
url: https://blog.windsay.qzz.io  # 改成你的域名
```

### package.json
**npm 依赖管理文件**

包含了所有需要安装的 npm 包。

**主要依赖**：
- Hexo 核心和渲染器
- 主题推荐的插件（搜索、字数统计等）
- 部署插件

**使用方法**：
```bash
# 复制到博客根目录后
npm install
```

### .gitignore
**Git 忽略规则**

定义了哪些文件不需要提交到 Git 仓库。

**忽略的文件**：
- `node_modules/` - npm 依赖包
- `public/` - 生成的静态文件
- `.deploy_git/` - 部署临时文件
- `db.json` - Hexo 数据库
- 其他临时文件

### .nvmrc
**Node.js 版本配置**

指定项目使用的 Node.js 版本。

**当前版本**：18

**使用方法**：
```bash
# 如果安装了 nvm
nvm use
```

## 🚀 使用步骤

### 方法一：使用快速开始脚本（推荐）

```bash
# 脚本会自动复制这些文件
bash examples/quick-start.sh my-blog
```

### 方法二：手动复制

```bash
# 创建博客目录
mkdir my-blog
cd my-blog

# 复制配置文件
cp /path/to/windsay/examples/blog-config/_config.yml .
cp /path/to/windsay/examples/blog-config/package.json .
cp /path/to/windsay/examples/blog-config/.gitignore .
cp /path/to/windsay/examples/blog-config/.nvmrc .

# 安装依赖
npm install

# 添加主题
git init
git submodule add https://github.com/yorelll/windsay themes/windsay

# 创建必要的目录
mkdir -p source/_posts
mkdir -p source/_data
mkdir -p scaffolds
```

## ⚠️ 重要提示

### 1. 仓库分离
这些配置文件应该放在**博客仓库**中，不是主题仓库：

```
博客仓库 (例如: yorelll/windsay-blog)
├── _config.yml          ← 从这里复制
├── package.json         ← 从这里复制
├── .gitignore           ← 从这里复制
├── .nvmrc              ← 从这里复制
├── source/
│   └── _posts/         ← 你的文章
└── themes/
    └── windsay/        ← 主题（作为子模块）
```

### 2. 必须修改的配置

复制后，**必须**修改以下内容：

1. **_config.yml**
   - `title`, `subtitle`, `description`, `author`
   - `url` - 改成你的域名
   - `language` - 如果需要的话

2. **package.json**
   - `name` - 改成你的博客名称
   - `author` - 改成你的名字

### 3. 主题配置

主题有自己的配置文件 `themes/windsay/_config.yml`，这是另一个配置文件，不要混淆。

**博客配置** (`_config.yml` in root):
- 网站基本信息
- URL 和永久链接
- 主题选择
- 插件配置

**主题配置** (`themes/windsay/_config.yml`):
- 主题外观
- 菜单设置
- 评论系统
- 社交链接

## 🔧 配置检查清单

在开始使用前，请确认：

- [ ] 复制了所有配置文件到博客根目录
- [ ] 修改了 `_config.yml` 中的个人信息
- [ ] 修改了 `_config.yml` 中的 URL
- [ ] 确认 `theme` 设置为 `windsay`
- [ ] 运行了 `npm install`
- [ ] 添加了主题作为子模块
- [ ] 创建了必要的目录结构

## 📚 相关文档

- [完整部署指南](../../DEPLOYMENT_GUIDE_CN.md)
- [主题更新指南](../../THEME_UPDATE_GUIDE.md)
- [快速开始脚本](../quick-start.sh)
- [Hexo 官方文档](https://hexo.io/zh-cn/docs/)

## 💡 提示

### 如何验证配置正确

```bash
# 在博客根目录执行
npx hexo version

# 应该显示类似输出：
# hexo: 7.x.x
# hexo-cli: 4.x.x
# ...

# 启动本地服务器
npx hexo server

# 访问 http://localhost:4000
# 应该能看到使用 windsay 主题的博客
```

### 常见问题

**Q: 主题没有生效？**

检查：
1. `_config.yml` 中 `theme: windsay` 是否正确
2. `themes/windsay` 目录是否存在且有内容
3. 运行 `npx hexo clean` 清理缓存

**Q: npm install 失败？**

尝试：
1. 使用 npm 镜像：`npm config set registry https://registry.npmmirror.com`
2. 检查 Node.js 版本：`node -v`（应该是 18.x）
3. 删除 `node_modules` 和 `package-lock.json` 重试

**Q: 如何更新配置文件？**

如果主题仓库更新了示例配置：
1. 查看差异：`git diff themes/windsay/examples/blog-config/_config.yml _config.yml`
2. 手动合并需要的更改
3. 不要直接覆盖，因为你已经做了个性化修改

---

**最后更新**: 2024-12-30
