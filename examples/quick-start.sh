#!/bin/bash

# Hexo 博客快速设置脚本
# 用于快速创建一个新的 Hexo 博客项目，使用 windsay 主题
# 
# 重要说明:
# - 此脚本创建的是博客仓库，不是主题仓库
# - windsay 主题将作为 git 子模块添加
# - 你需要创建一个新的 GitHub 仓库来存放博客内容（例如: windsay-blog）

set -e

# 配置变量
THEME_REPO_HTTPS="https://github.com/yorelll/windsay"
THEME_REPO_SSH="git@github.com:yorelll/windsay.git"
# GitHub 镜像站（用于加速克隆，适用于中国大陆用户）
THEME_REPO_MIRROR="https://gitee.com/mirrors/windsay"  # 可选的镜像地址
THEME_DIR="themes/windsay"
# Git 克隆配置
GIT_CLONE_DEPTH="1"  # 使用浅克隆减少下载大小

echo "🚀 Hexo 博客快速设置脚本"
echo "=========================="
echo ""
echo "📝 注意事项:"
echo "   • 此脚本将创建一个新的 Hexo 博客项目"
echo "   • windsay 主题将作为 git 子模块添加"
echo "   • 请在 GitHub 创建一个博客仓库 (例如: windsay-blog)"
echo "   • 不要将博客内容提交到 windsay 主题仓库"
echo ""

# 检查参数
if [ -z "$1" ]; then
    echo "用法: ./quick-start.sh <博客目录名>"
    echo "示例: ./quick-start.sh my-hexo-blog"
    echo ""
    echo "推荐的博客目录名: windsay-blog"
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

# 获取安装的 Hexo 版本并更新 package.json
echo ""
echo "📥 安装 Hexo 和必要依赖..."
npm install hexo --save

# 添加 hexo.version 字段到 package.json，这是 hexo 识别项目的关键
HEXO_VERSION=$(node -p "require('./node_modules/hexo/package.json').version")
echo "检测到 Hexo 版本: $HEXO_VERSION"
# 使用 node 来更新 package.json 以保证 JSON 格式正确
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.hexo = { version: '$HEXO_VERSION' };
pkg.private = true;
pkg.scripts = {
  build: 'hexo clean && hexo generate',
  clean: 'hexo clean',
  deploy: 'hexo deploy',
  server: 'hexo server',
  dev: 'hexo server --draft',
  new: 'hexo new'
};
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
"
echo "✅ 已配置 package.json"
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

# 询问用户是否使用镜像站（适用于中国大陆用户）
# 支持环境变量 CLONE_OPTION 以便自动化脚本使用
if [ -z "$CLONE_OPTION" ]; then
    echo ""
    echo "⚡ GitHub 克隆优化选项:"
    echo "1. 使用 GitHub 官方地址 (默认)"
    echo "2. 使用 GitHub 镜像站 (推荐中国大陆用户，速度更快)"
    echo "3. 使用 SSH 方式 (需要配置 SSH 密钥)"
    echo ""
    read -p "请选择克隆方式 [1-3, 默认 1]: " CLONE_OPTION
    CLONE_OPTION=${CLONE_OPTION:-1}
else
    echo "📌 使用预设的克隆选项: $CLONE_OPTION"
fi

case $CLONE_OPTION in
    2)
        REPO_URL="$THEME_REPO_MIRROR"
        echo "📌 使用镜像站: $REPO_URL"
        echo "⚠️  注意: 镜像站可能不是最新版本，建议后续手动更新"
        ;;
    3)
        REPO_URL="$THEME_REPO_SSH"
        echo "📌 使用 SSH: $REPO_URL"
        ;;
    *)
        REPO_URL="$THEME_REPO_HTTPS"
        echo "📌 使用 HTTPS: $REPO_URL"
        ;;
esac

git init

# 配置 git 以优化克隆速度
echo "⚙️  配置 Git 克隆参数..."
# 增加 HTTP 缓冲区大小到 500MB 以处理大文件
git config http.postBuffer 524288000
# 禁用低速限制检查，避免网络波动导致中断
git config http.lowSpeedLimit 0
# 设置超时时间为 10 分钟（600 秒），适合慢速网络
git config http.lowSpeedTime 600

# 尝试添加主题作为 git 子模块，包含重试逻辑
echo "正在克隆主题仓库..."
MAX_RETRIES=3
RETRY_COUNT=0
SUCCESS=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$SUCCESS" = false ]; do
    if [ $RETRY_COUNT -gt 0 ]; then
        echo "重试 ($RETRY_COUNT/$MAX_RETRIES)..."
        sleep 2
    fi
    
    # Note: git submodule doesn't support --depth flag directly
    # We'll use regular submodule add, and users can manually shallow clone if needed
    if git submodule add "$REPO_URL" "$THEME_DIR"; then
        SUCCESS=true
        echo "✅ 主题克隆成功"
        
        # Optional: Try to reduce repository size by cleaning up
        # Note: Converting to shallow clone after full clone is complex and may fail
        # Users can manually run: cd themes/windsay && git fetch --depth 1 && git gc
        if [ "$GIT_CLONE_DEPTH" = "1" ]; then
            echo "⚙️  优化：清理 Git 仓库以节省空间..."
            # Run basic garbage collection to clean up and compress (not aggressive to save time)
            (cd "$THEME_DIR" && git gc --prune=all) 2>/dev/null || true
        fi
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "⚠️  克隆失败，将重试..."
            # 清理失败的克隆尝试
            THEME_NAME=$(basename "$THEME_DIR")
            rm -rf "$THEME_DIR" .git/modules/"$THEME_NAME" 2>/dev/null
        fi
    fi
done

if [ "$SUCCESS" = false ]; then
    echo ""
    echo "❌ 错误: 无法克隆主题仓库"
    echo ""
    echo "可能的原因和解决方案:"
    echo "1. 网络连接问题 - 请检查网络连接并重试"
    echo "2. GitHub 访问速度慢 - 重新运行脚本并选择镜像站选项 (选项 2)"
    echo "3. 配置 Git 代理:"
    echo "   git config --global http.proxy http://proxy.example.com:8080"
    echo "   或 git config --global http.proxy socks5://127.0.0.1:1080"
    echo "4. 使用 SSH 方式 - 重新运行脚本并选择 SSH 选项 (选项 3)"
    echo ""
    echo "手动解决方法:"
    echo "1. cd $BLOG_DIR"
    echo "2. git submodule add $THEME_REPO_HTTPS $THEME_DIR"
    echo "   或者使用浅克隆直接克隆（非子模块）:"
    echo "   git clone --depth 1 $THEME_REPO_HTTPS $THEME_DIR"
    echo ""
    exit 1
fi

echo ""
echo "📋 复制示例配置文件..."

# 复制配置文件
if [ -f "$THEME_DIR/examples/blog-config/_config.yml" ]; then
    cp "$THEME_DIR/examples/blog-config/_config.yml" _config.yml
    echo "✅ 已复制 _config.yml"
else
    echo "⚠️  警告: 未找到示例配置文件，使用默认配置"
fi

# 复制 .gitignore
if [ -f "$THEME_DIR/examples/blog-config/.gitignore" ]; then
    cp "$THEME_DIR/examples/blog-config/.gitignore" .gitignore
    echo "✅ 已复制 .gitignore"
fi

# 复制 .nvmrc
if [ -f "$THEME_DIR/examples/blog-config/.nvmrc" ]; then
    cp "$THEME_DIR/examples/blog-config/.nvmrc" .nvmrc
    echo "✅ 已复制 .nvmrc"
fi

# 创建 GitHub Actions 目录
echo ""
echo "🔧 设置 GitHub Actions..."
mkdir -p .github/workflows

if [ -f "$THEME_DIR/examples/github-actions/deploy.yml" ]; then
    cp "$THEME_DIR/examples/github-actions/deploy.yml" .github/workflows/
    echo "✅ 已复制部署工作流"
fi

echo ""
echo "📄 创建必要的页面..."

# 创建页面目录（不依赖 hexo new page 命令）
echo "创建页面目录结构..."
mkdir -p source/categories
mkdir -p source/tags
mkdir -p source/about
mkdir -p source/friends

# 直接创建页面文件而不是使用 npx hexo new page
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

echo "✅ 已创建必要的页面文件"

# 创建 friends 数据文件
mkdir -p source/_data
echo "[]" > source/_data/friends.json

echo ""
echo "✅ 设置完成！"
echo ""
echo "📚 重要说明:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  仓库分离架构"
echo "   • 主题仓库: https://github.com/yorelll/windsay"
echo "   • 博客仓库: 你需要创建一个新仓库存放博客内容"
echo "   • 建议博客仓库名: windsay-blog 或 my-hexo-blog"
echo ""
echo "2️⃣  主题作为子模块"
echo "   • windsay 主题已作为 git 子模块添加到 themes/windsay"
echo "   • 可独立更新主题，不影响博客内容"
echo "   • 主题更新命令: cd themes/windsay && git pull origin main"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🚀 接下来的步骤:"
echo "1. cd $BLOG_DIR"
echo "2. 编辑 _config.yml 修改网站信息和域名"
echo "3. 编辑 .github/workflows/deploy.yml 修改 Cloudflare 项目名"
echo ""
echo "4. 在 GitHub 创建博客仓库（例如: windsay-blog）"
echo "   访问: https://github.com/new"
echo "   • 仓库名称: windsay-blog（推荐）或其他名称"
echo "   • 设置为 Public"
echo "   • 不要初始化 README、.gitignore 或 license"
echo ""
echo "5. 设置 GitHub Secrets"
echo "   仓库 Settings → Secrets and variables → Actions"
echo "   添加: CLOUDFLARE_API_TOKEN 和 CLOUDFLARE_ACCOUNT_ID"
echo ""
echo "6. 提交并推送到 GitHub"
echo "   git add ."
echo "   git commit -m \"Initial commit: Setup Hexo blog with windsay theme\""
echo "   git branch -M main"
echo "   git remote add origin https://github.com/你的用户名/windsay-blog.git"
echo "   git push -u origin main"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 常用命令:"
echo "• 本地预览: npx hexo server 或 npm run server"
echo "• 访问: http://localhost:4000"
echo "• 创建新文章: npx hexo new \"文章标题\" 或 npm run new \"文章标题\""
echo "• 清理缓存: npx hexo clean 或 npm run clean"
echo "• 生成静态文件: npx hexo generate 或 npm run build"
echo ""
echo "🧹 清理和维护:"
echo "• 清理依赖和临时文件: bash $THEME_DIR/examples/cleanup.sh"
echo "  （释放磁盘空间，保留文章和配置）"
echo ""
echo "📖 详细文档:"
echo "• 部署指南: $THEME_DIR/DEPLOYMENT_GUIDE_CN.md"
echo "• 主题更新指南: $THEME_DIR/THEME_UPDATE_GUIDE.md"
echo "• 文档索引: $THEME_DIR/DOCUMENTATION_INDEX.md"
echo ""
