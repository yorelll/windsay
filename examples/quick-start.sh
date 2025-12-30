#!/bin/bash

# Hexo 博客快速设置脚本
# 用于快速创建一个新的 Hexo 博客项目，使用 windsay 主题

set -e

echo "🚀 Hexo 博客快速设置脚本"
echo "=========================="
echo ""

# 检查参数
if [ -z "$1" ]; then
    echo "用法: ./quick-start.sh <博客目录名>"
    echo "示例: ./quick-start.sh my-hexo-blog"
    exit 1
fi

BLOG_DIR=$1

# 检查目录是否存在
if [ -d "$BLOG_DIR" ]; then
    echo "❌ 错误: 目录 '$BLOG_DIR' 已存在"
    exit 1
fi

echo "📁 创建博客目录: $BLOG_DIR"
mkdir -p "$BLOG_DIR"
cd "$BLOG_DIR"

echo ""
echo "📦 初始化 npm 项目..."
npm init -y

echo ""
echo "📥 安装 Hexo 和必要依赖..."
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

echo ""
echo "📥 安装主题推荐插件..."
npm install hexo-wordcount --save
npm install hexo-generator-search --save
npm install hexo-permalink-pinyin --save
npm install hexo-generator-feed --save
npm install hexo-filter-github-emojis --save

echo ""
echo "📝 创建 Hexo 基础目录结构..."
mkdir -p source/_posts
mkdir -p source/_data
mkdir -p scaffolds
mkdir -p themes

# 创建基础 scaffold 文件
cat > scaffolds/post.md << 'SCAFFOLD'
---
title: {{ title }}
date: {{ date }}
tags:
categories:
---
SCAFFOLD

cat > scaffolds/page.md << 'SCAFFOLD'
---
title: {{ title }}
date: {{ date }}
---
SCAFFOLD

cat > scaffolds/draft.md << 'SCAFFOLD'
---
title: {{ title }}
tags:
---
SCAFFOLD

echo ""
echo "🎨 添加 windsay 主题..."
git init
git submodule add https://github.com/yorelll/windsay.git themes/windsay

echo ""
echo "📋 复制示例配置文件..."
THEME_PATH="themes/windsay"

# 复制配置文件
if [ -f "$THEME_PATH/examples/blog-config/_config.yml" ]; then
    cp "$THEME_PATH/examples/blog-config/_config.yml" _config.yml
    echo "✅ 已复制 _config.yml"
else
    echo "⚠️  警告: 未找到示例配置文件，使用默认配置"
fi

# 复制 .gitignore
if [ -f "$THEME_PATH/examples/blog-config/.gitignore" ]; then
    cp "$THEME_PATH/examples/blog-config/.gitignore" .gitignore
    echo "✅ 已复制 .gitignore"
fi

# 复制 .nvmrc
if [ -f "$THEME_PATH/examples/blog-config/.nvmrc" ]; then
    cp "$THEME_PATH/examples/blog-config/.nvmrc" .nvmrc
    echo "✅ 已复制 .nvmrc"
fi

# 创建 GitHub Actions 目录
echo ""
echo "🔧 设置 GitHub Actions..."
mkdir -p .github/workflows

if [ -f "$THEME_PATH/examples/github-actions/deploy.yml" ]; then
    cp "$THEME_PATH/examples/github-actions/deploy.yml" .github/workflows/
    echo "✅ 已复制部署工作流"
fi

echo ""
echo "📄 创建必要的页面..."
npx hexo new page "categories"
npx hexo new page "tags"
npx hexo new page "about"
npx hexo new page "friends"

# 更新页面的 front-matter
echo "---
title: categories
date: $(date +%Y-%m-%d\ %H:%M:%S)
type: \"categories\"
layout: \"categories\"
---" > source/categories/index.md

echo "---
title: tags
date: $(date +%Y-%m-%d\ %H:%M:%S)
type: \"tags\"
layout: \"tags\"
---" > source/tags/index.md

echo "---
title: about
date: $(date +%Y-%m-%d\ %H:%M:%S)
type: \"about\"
layout: \"about\"
---" > source/about/index.md

echo "---
title: friends
date: $(date +%Y-%m-%d\ %H:%M:%S)
type: \"friends\"
layout: \"friends\"
---" > source/friends/index.md

# 创建 friends 数据文件
mkdir -p source/_data
echo "[]" > source/_data/friends.json

echo ""
echo "✅ 设置完成！"
echo ""
echo "接下来的步骤:"
echo "1. cd $BLOG_DIR"
echo "2. 编辑 _config.yml 修改网站信息和域名"
echo "3. 编辑 .github/workflows/deploy.yml 修改 Cloudflare 项目名"
echo "4. 在 GitHub 创建远程仓库"
echo "5. 设置 GitHub Secrets (CLOUDFLARE_API_TOKEN 和 CLOUDFLARE_ACCOUNT_ID)"
echo "6. git add . && git commit -m \"Initial commit\""
echo "7. git remote add origin <你的仓库URL>"
echo "8. git push -u origin main"
echo ""
echo "本地预览: npx hexo server"
echo "访问: http://localhost:4000"
echo ""
echo "📚 详细文档请查看: $THEME_PATH/DEPLOYMENT_GUIDE_CN.md"
