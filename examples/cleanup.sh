#!/bin/bash

# Hexo 博客清理脚本
# 用于清理由 quick-start.sh 创建的 Hexo 博客项目
# 
# 使用方法:
#   1. 在博客目录内运行: bash /path/to/cleanup.sh
#   2. 或指定目录: bash cleanup.sh /path/to/blog-directory
#
# 警告: 此操作不可逆，请确保已备份重要内容！

set -e

echo "🧹 Hexo 博客清理脚本"
echo "=========================="
echo ""

# 确定要清理的目录
if [ -n "$1" ]; then
    TARGET_DIR="$1"
else
    TARGET_DIR="$(pwd)"
fi

# 转换为绝对路径以提高安全性
TARGET_DIR=$(cd "$TARGET_DIR" 2>/dev/null && pwd) || {
    echo "❌ 错误: 无法访问目录 '$1'"
    exit 1
}

# 验证目标目录
if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ 错误: 目录 '$TARGET_DIR' 不存在"
    exit 1
fi

# 安全检查：防止删除系统关键目录
case "$TARGET_DIR" in
    /|/bin|/boot|/dev|/etc|/lib|/proc|/root|/sbin|/sys|/usr|/var|$HOME)
        echo "❌ 错误: 拒绝清理系统目录或用户主目录"
        echo "   目标目录: $TARGET_DIR"
        exit 1
        ;;
esac

# 检查是否是 Hexo 项目
# 一个有效的 Hexo 博客目录应该至少有 _config.yml 或 package.json
if [ ! -f "$TARGET_DIR/_config.yml" ] && [ ! -f "$TARGET_DIR/package.json" ]; then
    echo "❌ 错误: '$TARGET_DIR' 似乎不是一个 Hexo 博客目录"
    echo "   (未找到 _config.yml 和 package.json)"
    echo ""
    echo "💡 提示: Hexo 博客目录应该至少包含以下之一:"
    echo "   • _config.yml - Hexo 配置文件"
    echo "   • package.json - npm 项目配置"
    exit 1
fi

echo "📁 目标目录: $TARGET_DIR"
echo ""

# 显示将要删除的内容
echo "⚠️  此脚本将删除以下内容:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "• node_modules/ - npm 依赖包"
echo "• package-lock.json / yarn.lock - 依赖锁文件"
echo "• public/ - 生成的静态文件"
echo "• db.json - Hexo 数据库"
echo "• .deploy_git/ - 部署缓存"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "保留的内容:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "• source/ - 你的文章和页面"
echo "• themes/ - 主题文件（包括 git 子模块）"
echo "• _config.yml - 配置文件"
echo "• scaffolds/ - 文章模板"
echo "• package.json - 项目配置（保留以便重新安装）"
echo "• .git/ - Git 仓库信息"
echo "• .github/ - GitHub Actions 配置"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 询问确认（只需输入单个字符 y 或 Y）
read -p "⚠️  确定要继续吗？输入 y 继续，其他键取消 [y/N]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 清理已取消"
    exit 0
fi

echo ""
echo "🧹 开始清理..."
echo ""

# 使用绝对路径进行操作，避免 cd 带来的安全风险

# 删除 node_modules
if [ -d "$TARGET_DIR/node_modules" ]; then
    echo "🗑️  删除 node_modules..."
    rm -rf "$TARGET_DIR/node_modules"
    echo "✅ 已删除 node_modules"
else
    echo "⏭️  跳过 node_modules (不存在)"
fi

# 删除 package-lock.json
if [ -f "$TARGET_DIR/package-lock.json" ]; then
    echo "🗑️  删除 package-lock.json..."
    rm -f "$TARGET_DIR/package-lock.json"
    echo "✅ 已删除 package-lock.json"
fi

# 删除 yarn.lock
if [ -f "$TARGET_DIR/yarn.lock" ]; then
    echo "🗑️  删除 yarn.lock..."
    rm -f "$TARGET_DIR/yarn.lock"
    echo "✅ 已删除 yarn.lock"
fi

# 删除 public 目录
if [ -d "$TARGET_DIR/public" ]; then
    echo "🗑️  删除 public..."
    rm -rf "$TARGET_DIR/public"
    echo "✅ 已删除 public"
else
    echo "⏭️  跳过 public (不存在)"
fi

# 删除 db.json
if [ -f "$TARGET_DIR/db.json" ]; then
    echo "🗑️  删除 db.json..."
    rm -f "$TARGET_DIR/db.json"
    echo "✅ 已删除 db.json"
fi

# 删除 .deploy_git
if [ -d "$TARGET_DIR/.deploy_git" ]; then
    echo "🗑️  删除 .deploy_git..."
    rm -rf "$TARGET_DIR/.deploy_git"
    echo "✅ 已删除 .deploy_git"
else
    echo "⏭️  跳过 .deploy_git (不存在)"
fi

# 删除 .hexo 缓存目录（如果存在）
if [ -d "$TARGET_DIR/.hexo" ]; then
    echo "🗑️  删除 .hexo..."
    rm -rf "$TARGET_DIR/.hexo"
    echo "✅ 已删除 .hexo"
fi

echo ""
echo "✅ 清理完成！"
echo ""
echo "📊 磁盘空间已释放"
echo ""
echo "💡 后续操作:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "如果你想重新使用此博客:"
echo "  1. 重新安装依赖: npm install"
echo "  2. 预览博客: npm run server"
echo "  3. 生成静态文件: npm run build"
echo ""
echo "如果你想完全删除此博客目录:"
# 安全地获取目录名并显示完整命令
BLOG_DIR_NAME=$(basename "$TARGET_DIR")
if [ -n "$BLOG_DIR_NAME" ] && [ "$BLOG_DIR_NAME" != "." ] && [ "$BLOG_DIR_NAME" != ".." ]; then
    echo "  cd .."
    echo "  rm -rf \"$BLOG_DIR_NAME\""
else
    echo "  请手动删除博客目录"
fi
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
