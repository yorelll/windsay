#!/usr/bin/env bash

# Hexo 博客快速设置脚本 v2.0
# 用于快速创建一个新的 Hexo 博客项目，使用 windsay 主题
# 
# 重要说明:
# - 此脚本创建的是博客仓库，不是主题仓库
# - windsay 主题将作为 git 子模块添加
# - 你需要创建一个新的 GitHub 仓库来存放博客内容（例如: windsay-blog）

set -euo pipefail

# 定义依赖列表
DEPENDENCIES=("git" "node" "npm")

echo "🔍 检查环境依赖..."
echo ""

# 循环检查依赖
for cmd in "${DEPENDENCIES[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "\033[31m[错误] 未检测到命令: $cmd\033[0m"
        echo "请先安装 $cmd 后再运行此脚本"
        echo ""
        echo "安装提示："
        case "$cmd" in
            git)
                echo "  • macOS: brew install git"
                echo "  • Ubuntu/Debian: sudo apt-get install git"
                echo "  • 官网: https://git-scm.com/"
                ;;
            node|npm)
                echo "  • 推荐使用 nvm 安装 Node.js: https://github.com/nvm-sh/nvm"
                echo "  • 或访问官网: https://nodejs.org/"
                ;;
        esac
        exit 1
    fi
    echo "✅ 已检测到: $cmd ($(command -v "$cmd"))"
done

echo ""

# 检查 Node.js 版本（建议 >= 16）
NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 16 ]; then
    echo -e "\033[31m[错误] Node.js 版本过低: v$NODE_VERSION，建议升级到 v16 或更高版本\033[0m"
    echo ""
    echo "升级方法："
    echo "  • 使用 nvm: nvm install 18 && nvm use 18"
    echo "  • 或访问官网下载: https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js 版本: v$NODE_VERSION (符合要求)"
echo ""

# 配置变量
THEME_REPO_HTTPS="https://github.com/yorelll/windsay"
THEME_REPO_SSH="git@github.com:yorelll/windsay.git"
# GitHub 镜像站（用于加速克隆，适用于中国大陆用户）
THEME_REPO_MIRROR="https://gitee.com/mirrors/windsay"  # 可选的镜像地址
THEME_DIR="themes/windsay"
# Git 克隆配置
GIT_CLONE_DEPTH="1"  # 使用浅克隆减少下载大小

echo "🚀 Hexo 博客快速设置脚本 v2.0"
echo "================================="
echo ""
echo "📝 此脚本将帮助你:"
echo "   • 创建一个完整的 Hexo 博客项目"
echo "   • 配置 windsay 主题"
echo "   • 初始化 hero 区域"
echo "   • 创建第一篇文章"
echo "   • 设置 GitHub Actions 自动部署"
echo "   • 准备好推送到远程仓库"
echo ""
echo "⚠️  重要提醒:"
echo "   • 请先在 GitHub 创建一个博客仓库"
echo "   • 仓库名称必须与下面的参数名称一致"
echo "   • 你需要提供域名用于博客访问"
echo "   • 需要在 GitHub 仓库设置 Cloudflare API 密钥"
echo ""

# 检查参数
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "用法: ./quick-start.sh <博客目录名> <域名> [远程仓库URL]"
    echo ""
    echo "参数说明:"
    echo "  <博客目录名>     - 本地博客目录名，必须与 GitHub 仓库名一致"
    echo "  <域名>           - 博客访问域名（必填，例如: blog.example.com）"
    echo "  [远程仓库URL]    - 可选，GitHub 仓库 URL（例如: https://github.com/用户名/仓库名.git）"
    echo ""
    echo "示例:"
    echo "  ./quick-start.sh windsay-blog blog.windsay.qzz.io"
    echo "  ./quick-start.sh windsay-blog blog.windsay.qzz.io https://github.com/yourname/windsay-blog.git"
    echo "  ./quick-start.sh my-hexo-blog blog.mysite.com git@github.com:yourname/my-hexo-blog.git"
    echo ""
    echo "📌 重要提醒:"
    echo "  1. 博客目录名应该与你的 GitHub 仓库名保持一致"
    echo "  2. 如果目录名是 'windsay-blog'，仓库名也应该是 'windsay-blog'"
    echo "  3. 域名格式: blog.example.com 或 example.com（不包含 https://）"
    echo "  4. 远程仓库支持 HTTPS 和 SSH 两种格式"
    echo ""
    exit 1
fi

BLOG_DIR=$1
DOMAIN=$2
REMOTE_REPO=$3

# 验证域名格式
if [[ ! "$DOMAIN" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)*$ ]]; then
    echo "❌ 错误: 无效的域名格式: $DOMAIN"
    echo "   域名示例: blog.example.com 或 example.com"
    echo "   请不要包含 https:// 或尾部斜杠"
    exit 1
fi

echo ""
echo "📋 配置信息确认:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  博客目录名: $BLOG_DIR"
echo "  博客域名:   https://$DOMAIN"
echo "  GitHub 仓库: https://github.com/<你的用户名>/$BLOG_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "确认以上信息正确？(y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消设置"
    exit 1
fi

# 检查目录是否存在
if [ -d "$BLOG_DIR" ]; then
    echo "❌ 错误: 目录 '$BLOG_DIR' 已存在"
    exit 1
fi

echo ""
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
# 检查 hexo 是否安装成功
if [ ! -f "node_modules/hexo/package.json" ]; then
    echo "❌ 错误: Hexo 安装失败，未找到 hexo 包"
    exit 1
fi

HEXO_VERSION=$(node -p "require('./node_modules/hexo/package.json').version")
if [ -z "$HEXO_VERSION" ]; then
    echo "❌ 错误: 无法获取 Hexo 版本"
    exit 1
fi

echo "检测到 Hexo 版本: $HEXO_VERSION"

# 使用 node 来更新 package.json 以保证 JSON 格式正确
# 使用环境变量传递版本号以避免注入风险
HEXO_VERSION="$HEXO_VERSION" node -e "
try {
  const fs = require('fs');
  const hexoVersion = process.env.HEXO_VERSION;
  
  // 严格验证版本号格式 (例如: 7.3.0, 8.1.1)
  if (!hexoVersion || !/^\\d+(?:\\.\\d+)*$/.test(hexoVersion)) {
    throw new Error('Invalid Hexo version format: ' + hexoVersion);
  }
  
  const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
  pkg.hexo = { version: hexoVersion };
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
  console.log('✅ 已配置 package.json');
} catch (error) {
  console.error('❌ 错误: 更新 package.json 失败:', error.message);
  process.exit(1);
}
"

# 检查 package.json 更新是否成功
if [ $? -ne 0 ]; then
    echo "❌ 错误: package.json 配置失败"
    exit 1
fi
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

CLONE_OPTION=""
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
echo "📋 复制并配置示例文件..."

# 复制配置文件并更新域名
if [ -f "$THEME_DIR/examples/blog-config/_config.yml" ]; then
    cp "$THEME_DIR/examples/blog-config/_config.yml" _config.yml
    # 使用 sed 更新域名（兼容 macOS 和 Linux）
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|url: https://blog.windsay.qzz.io|url: https://$DOMAIN|g" _config.yml
        sed -i '' "s|title: 我的博客|title: $BLOG_DIR|g" _config.yml
    else
        # Linux
        sed -i "s|url: https://blog.windsay.qzz.io|url: https://$DOMAIN|g" _config.yml
        sed -i "s|title: 我的博客|title: $BLOG_DIR|g" _config.yml
    fi
    echo "✅ 已复制并配置 _config.yml"
    echo "   - 域名已设置为: https://$DOMAIN"
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
    # 更新 Cloudflare Pages 项目名（兼容 macOS 和 Linux）
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|projectName: windsay-blog|projectName: $BLOG_DIR|g" .github/workflows/deploy.yml
    else
        sed -i "s|projectName: windsay-blog|projectName: $BLOG_DIR|g" .github/workflows/deploy.yml
    fi
    echo "✅ 已复制并配置部署工作流"
    echo "   - Cloudflare 项目名已设置为: $BLOG_DIR"
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
echo "🎨 初始化 Hero 区域..."
# 复制主题配置文件到 source/_data 目录以便自定义
mkdir -p source/_data
if [ -f "$THEME_DIR/_config.yml" ]; then
    cp "$THEME_DIR/_config.yml" source/_data/theme_config.yml
    echo "✅ 已复制主题配置到 source/_data/theme_config.yml"
    echo "   你可以稍后编辑此文件来自定义 hero 区域、音乐等"
fi

echo ""
echo "📝 复制第一篇文章模板..."
# 复制第一篇欢迎文章模板（如果存在）
if [ -f "$THEME_DIR/examples/blog-config/welcome-post.md" ]; then
    cp "$THEME_DIR/examples/blog-config/welcome-post.md" source/_posts/welcome-to-my-blog.md
    # 更新日期
    FIRST_POST_DATE=$(date +%Y-%m-%d\ %H:%M:%S)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|date: .*|date: $FIRST_POST_DATE|g" source/_posts/welcome-to-my-blog.md
        sed -i '' "s|author: .*|author: $BLOG_DIR|g" source/_posts/welcome-to-my-blog.md
    else
        sed -i "s|date: .*|date: $FIRST_POST_DATE|g" source/_posts/welcome-to-my-blog.md
        sed -i "s|author: .*|author: $BLOG_DIR|g" source/_posts/welcome-to-my-blog.md
    fi
    echo "✅ 已复制并配置第一篇文章: source/_posts/welcome-to-my-blog.md"
else
    echo "⚠️  警告: 未找到第一篇文章模板，请手动创建"
fi

echo ""
echo "🔧 初始化 Git 仓库并准备提交..."
# 如果还没有初始化 git
if [ ! -d ".git" ]; then
    git init
    echo "✅ 已初始化 Git 仓库"
fi

# 添加所有文件
git add .
echo "✅ 已添加所有文件到 Git"

# 创建初始提交
git commit -m "Initial commit: Setup Hexo blog with windsay theme

- Configure blog with domain: https://$DOMAIN
- Add windsay theme as git submodule
- Initialize hero section configuration
- Create first welcome article
- Setup GitHub Actions for auto-deployment to Cloudflare Pages
- Project name: $BLOG_DIR
"
echo "✅ 已创建初始提交"

# 设置默认分支为 main
git branch -M main
echo "✅ 已设置默认分支为 main"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 博客设置完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 已完成的工作:"
echo "  ✅ 创建 Hexo 博客项目结构"
echo "  ✅ 安装所有必要的依赖包"
echo "  ✅ 添加 windsay 主题作为 Git 子模块"
echo "  ✅ 配置博客基本信息和域名: https://$DOMAIN"
echo "  ✅ 初始化 Hero 区域配置"
echo "  ✅ 创建第一篇欢迎文章"
echo "  ✅ 创建必要页面 (分类、标签、关于、友链)"
echo "  ✅ 配置 GitHub Actions 自动部署"
echo "  ✅ 初始化 Git 并创建初始提交"
echo ""

# 推送到远程仓库
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 推送到 GitHub 仓库"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 如果没有提供远程仓库URL，询问用户
if [ -z "$REMOTE_REPO" ]; then
    echo "⚠️  在推送代码之前，请确保已完成以下配置:"
    echo ""
    echo "  1️⃣ 在 GitHub 创建远程仓库"
    echo "     • 访问: https://github.com/new"
    echo "     • 仓库名称必须为: $BLOG_DIR"
    echo "     • 设置为 Public（Cloudflare Pages 免费版要求）"
    echo "     • ❌ 不要初始化 README、.gitignore 或 license"
    echo ""
    echo "  2️⃣ 配置 Cloudflare Pages 项目"
    echo "     • 访问: https://dash.cloudflare.com/"
    echo "     • 创建名为 '$BLOG_DIR' 的 Pages 项目"
    echo ""
    echo "  3️⃣ 配置 GitHub Secrets"
    echo "     • CLOUDFLARE_API_TOKEN"
    echo "     • CLOUDFLARE_ACCOUNT_ID"
    echo "     • 在仓库的 Settings > Secrets and variables > Actions 中添加"
    echo ""
    echo "  4️⃣ 配置 GitHub Actions 权限 ⚠️  重要！"
    echo "     • 访问仓库 Settings → Actions → General → Workflow permissions"
    echo "     • 勾选 \"Read and write permissions\""
    echo "     • 否则 GitHub Actions 无法创建 Cloudflare Pages 项目"
    echo ""
    echo "  5️⃣ （可选）配置自定义域名"
    echo "     • 在仓库 Settings → Secrets and variables → Variables 中"
    echo "     • 添加变量 CUSTOM_DOMAIN，值为: $DOMAIN"
    echo "     • GitHub Actions 将自动配置 Cloudflare Pages 域名"
    echo ""
    read -p "是否已完成以上配置？(y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "请先完成配置后再继续。"
        echo "你可以稍后手动推送代码:"
        echo "  cd $BLOG_DIR"
        echo "  git remote add origin <你的仓库URL>"
        echo "  git push -u origin main"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📖 获取 Cloudflare API 凭据"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "  API Token: https://dash.cloudflare.com/profile/api-tokens"
        echo "  Account ID: 在 Cloudflare 控制台右侧可找到"
        echo ""
        echo "  完整部署指南: $THEME_DIR/DEPLOYMENT_GUIDE_CN.md"
        echo ""
        exit 0
    fi
    
    echo ""
    echo "请输入远程仓库 URL:"
    echo "  • HTTPS 格式: https://github.com/用户名/$BLOG_DIR.git"
    echo "  • SSH 格式:   git@github.com:用户名/$BLOG_DIR.git"
    echo ""
    read -p "远程仓库 URL: " REMOTE_REPO
    
    if [ -z "$REMOTE_REPO" ]; then
        echo "❌ 错误: 远程仓库 URL 不能为空"
        echo "你可以稍后手动推送代码:"
        echo "  cd $BLOG_DIR"
        echo "  git remote add origin <你的仓库URL>"
        echo "  git push -u origin main"
        exit 1
    fi
fi

echo ""
echo "📌 准备推送到远程仓库: $REMOTE_REPO"
echo ""

# 检测是SSH还是HTTPS
if [[ "$REMOTE_REPO" =~ ^git@ ]]; then
    echo "🔑 检测到 SSH 方式推送"
    echo "⚠️  请确保已配置 SSH 密钥:"
    echo "  • 生成密钥: ssh-keygen -t ed25519 -C \"your_email@example.com\""
    echo "  • 添加到 GitHub: https://github.com/settings/keys"
    echo ""
else
    echo "🌐 检测到 HTTPS 方式推送"
    echo "⚠️  可能需要输入 GitHub 用户名和密码（或 Personal Access Token）"
    echo "  • 创建 Token: https://github.com/settings/tokens"
    echo ""
fi

read -p "确认推送到远程仓库？(y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "已取消推送。你可以稍后手动推送代码:"
    echo "  cd $BLOG_DIR"
    echo "  git remote add origin $REMOTE_REPO"
    echo "  git push -u origin main"
    echo ""
    exit 0
fi

# 添加远程仓库
echo ""
echo "🔗 添加远程仓库..."
if git remote add origin "$REMOTE_REPO" 2>/dev/null; then
    echo "✅ 远程仓库添加成功"
else
    # 如果远程仓库已存在，尝试更新
    if git remote set-url origin "$REMOTE_REPO" 2>/dev/null; then
        echo "✅ 远程仓库 URL 已更新"
    else
        echo "❌ 错误: 添加远程仓库失败"
        echo "请检查仓库 URL 是否正确"
        exit 1
    fi
fi

# 检查远程仓库是否为空
echo ""
echo "🔍 检查远程仓库状态..."
if git ls-remote "$REMOTE_REPO" HEAD &>/dev/null; then
    echo "⚠️  检测到远程仓库非空"
    echo ""
    echo "这通常发生在以下情况："
    echo "  • 之前的部署失败，远程仓库已有内容"
    echo "  • 仓库创建时自动初始化了 README 或 .gitignore"
    echo ""
    echo "选项："
    echo "  1. 强制覆盖远程仓库内容（推荐用于重新部署）"
    echo "  2. 取消操作（手动处理后重试）"
    echo ""
    read -p "请选择 [1/2]: " choice
    
    if [ "$choice" = "1" ]; then
        echo ""
        echo "⚠️  将使用强制推送覆盖远程仓库内容"
        FORCE_PUSH=true
    else
        echo ""
        echo "已取消。请手动清理远程仓库后重试。"
        echo ""
        echo "清理方法："
        echo "  1. 删除远程仓库"
        echo "  2. 重新创建一个空仓库（不要初始化任何文件）"
        echo "  3. 重新运行此脚本"
        exit 1
    fi
else
    echo "✅ 远程仓库为空，可以推送"
    FORCE_PUSH=false
fi

# 推送到远程仓库
echo ""
echo "📤 推送代码到远程仓库..."
echo "   这可能需要几分钟时间..."
echo ""

if [ "$FORCE_PUSH" = true ]; then
    if git push -u origin main --force; then
        PUSH_SUCCESS=true
    else
        PUSH_SUCCESS=false
    fi
else
    if git push -u origin main; then
        PUSH_SUCCESS=true
    else
        PUSH_SUCCESS=false
    fi
fi

if [ "$PUSH_SUCCESS" = true ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 推送成功！"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "✅ 代码已成功推送到 GitHub"
    echo "✅ GitHub Actions 将自动开始构建和部署"
    echo ""
    echo "📊 后续步骤:"
    echo "  1. 访问你的 GitHub 仓库查看 Actions 运行状态"
    echo "  2. 等待部署完成（通常需要 2-5 分钟）"
    echo "  3. 访问你的博客: https://$DOMAIN"
    echo ""
    echo "🔗 快捷链接:"
    # 从REMOTE_REPO提取仓库信息，支持.git后缀
    if [[ "$REMOTE_REPO" =~ github\.com[:/]([^/]+)/([^/]+?)(?:\.git)?$ ]]; then
        REPO_OWNER="${BASH_REMATCH[1]}"
        REPO_NAME="${BASH_REMATCH[2]}"
        echo "  • GitHub 仓库: https://github.com/$REPO_OWNER/$REPO_NAME"
        echo "  • Actions 状态: https://github.com/$REPO_OWNER/$REPO_NAME/actions"
    fi
    echo "  • 博客地址: https://$DOMAIN"
    echo ""
else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  推送遇到问题"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "常见问题及解决方案:"
    echo ""
    echo "1. 远程仓库包含本地没有的提交 (rejected 或 non-fast-forward):"
    echo "   cd $BLOG_DIR"
    echo "   git pull origin main --allow-unrelated-histories"
    echo "   git push -u origin main"
    echo ""
    echo "2. 需要身份验证 (HTTPS):"
    echo "   • 使用 Personal Access Token 代替密码"
    echo "   • 创建 Token: https://github.com/settings/tokens"
    echo "   • 或改用 SSH 方式"
    echo ""
    echo "3. SSH 密钥未配置:"
    echo "   • 生成密钥: ssh-keygen -t ed25519 -C \"your_email@example.com\""
    echo "   • 添加到 GitHub: https://github.com/settings/keys"
    echo ""
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 本地开发和更新"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "常用命令:"
echo "  • 本地预览:      cd $BLOG_DIR && npm run server"
echo "    然后访问:      http://localhost:4000"
echo "  • 创建新文章:    cd $BLOG_DIR && npm run new \"文章标题\""
echo "  • 清理缓存:      cd $BLOG_DIR && npm run clean"
echo "  • 生成静态文件:  cd $BLOG_DIR && npm run build"
echo ""
echo "发布更新到博客:"
echo "  1. cd $BLOG_DIR"
echo "  2. 编辑文件（配置、文章等）"
echo "  3. git add ."
echo "  4. git commit -m \"更新说明\""
echo "  5. git push"
echo "  6. GitHub Actions 将自动重新部署"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📖 文档资源"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  • 完整部署指南:   $THEME_DIR/DEPLOYMENT_GUIDE_CN.md"
echo "  • 主题更新指南:   $THEME_DIR/THEME_UPDATE_GUIDE.md"
echo "  • 文档索引:       $THEME_DIR/DOCUMENTATION_INDEX.md"
echo "  • 更新脚本:       $THEME_DIR/examples/update.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "祝你写作愉快！🎉"
echo ""
