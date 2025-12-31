#!/bin/bash

# Hexo 博客更新脚本
# 用于帮助用户自定义和更新博客内容
# 
# 使用方法:
# 1. 在博客目录内运行: bash /path/to/update.sh
# 2. 或从主题目录运行: bash examples/update.sh /path/to/blog

set -e

echo "🔄 Hexo 博客更新助手"
echo "===================="
echo ""
echo "此脚本将帮助你:"
echo "  • 自定义博客配置"
echo "  • 更新主题设置"
echo "  • 管理博客内容"
echo "  • 发布更新到远程仓库"
echo ""

# 检查是否在博客目录中
if [ ! -f "_config.yml" ] && [ ! -f "package.json" ]; then
    if [ -z "$1" ]; then
        echo "❌ 错误: 未检测到 Hexo 博客项目"
        echo ""
        echo "请在博客目录中运行此脚本，或提供博客目录路径:"
        echo "  bash update.sh /path/to/blog"
        exit 1
    else
        cd "$1"
    fi
fi

# 确认是 Hexo 项目
if [ ! -f "_config.yml" ]; then
    echo "❌ 错误: 当前目录不是 Hexo 博客项目"
    exit 1
fi

BLOG_DIR=$(basename "$(pwd)")

echo "📁 当前博客: $BLOG_DIR"
echo "📍 目录: $(pwd)"
echo ""

# 显示菜单
show_menu() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "请选择要执行的操作:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📝 内容管理:"
    echo "  1. 创建新文章"
    echo "  2. 创建草稿"
    echo "  3. 发布草稿"
    echo "  4. 列出所有文章"
    echo ""
    echo "⚙️  配置更新:"
    echo "  5. 修改博客基本信息（标题、作者、描述等）"
    echo "  6. 修改域名配置"
    echo "  7. 自定义主题配置（Hero、音乐、颜色等）"
    echo "  8. 更新友情链接"
    echo ""
    echo "🎨 主题管理:"
    echo "  9. 更新 windsay 主题到最新版本"
    echo "  10. 查看主题版本信息"
    echo ""
    echo "🚀 部署和发布:"
    echo "  11. 本地预览博客"
    echo "  12. 构建静态文件"
    echo "  13. 提交并推送更新到 GitHub（触发自动部署）"
    echo ""
    echo "🔧 维护工具:"
    echo "  14. 清理缓存和临时文件"
    echo "  15. 重新安装依赖"
    echo "  16. 查看博客统计信息"
    echo ""
    echo "  0. 退出"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 创建新文章
create_new_post() {
    echo ""
    read -p "📝 请输入文章标题: " title
    if [ -z "$title" ]; then
        echo "❌ 标题不能为空"
        return
    fi
    
    npx hexo new "$title"
    echo "✅ 文章已创建"
    echo ""
    echo "💡 提示: 文章位于 source/_posts/ 目录"
    echo "   你可以编辑文章添加内容、标签、分类等"
}

# 创建草稿
create_draft() {
    echo ""
    read -p "📝 请输入草稿标题: " title
    if [ -z "$title" ]; then
        echo "❌ 标题不能为空"
        return
    fi
    
    npx hexo new draft "$title"
    echo "✅ 草稿已创建"
    echo ""
    echo "💡 提示: 草稿位于 source/_drafts/ 目录"
    echo "   完成后使用选项 3 发布草稿"
}

# 发布草稿
publish_draft() {
    echo ""
    echo "📋 可用的草稿:"
    if [ -d "source/_drafts" ]; then
        ls source/_drafts/*.md 2>/dev/null | sed 's|source/_drafts/||' | sed 's|.md||' | nl
    else
        echo "   (没有草稿)"
        return
    fi
    echo ""
    read -p "请输入草稿文件名（不含 .md）: " draft
    if [ -z "$draft" ]; then
        echo "❌ 文件名不能为空"
        return
    fi
    
    npx hexo publish "$draft"
    echo "✅ 草稿已发布到 source/_posts/"
}

# 列出所有文章
list_posts() {
    echo ""
    echo "📚 所有文章:"
    if [ -d "source/_posts" ]; then
        ls -lh source/_posts/*.md 2>/dev/null | awk '{print $9, "(" $5 ")"}'
        echo ""
        echo "总计: $(ls source/_posts/*.md 2>/dev/null | wc -l) 篇文章"
    else
        echo "   (没有文章)"
    fi
}

# 修改博客基本信息
update_blog_info() {
    echo ""
    echo "📝 当前博客信息:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    grep -E "^title:|^subtitle:|^description:|^author:|^language:" _config.yml | head -5
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "💡 提示: 你可以直接编辑 _config.yml 文件来修改这些信息"
    echo ""
    read -p "是否现在用编辑器打开 _config.yml? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ${EDITOR:-nano} _config.yml
        echo "✅ 配置已更新"
    fi
}

# 修改域名配置
update_domain() {
    echo ""
    current_domain=$(grep "^url:" _config.yml | awk '{print $2}')
    echo "📍 当前域名: $current_domain"
    echo ""
    read -p "请输入新域名（例如: https://blog.example.com）: " new_domain
    
    if [ -z "$new_domain" ]; then
        echo "❌ 域名不能为空"
        return
    fi
    
    # 验证域名格式
    if [[ ! "$new_domain" =~ ^https?:// ]]; then
        new_domain="https://$new_domain"
    fi
    
    # 更新域名（兼容 macOS 和 Linux）
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|^url:.*|url: $new_domain|" _config.yml
    else
        sed -i "s|^url:.*|url: $new_domain|" _config.yml
    fi
    echo "✅ 域名已更新为: $new_domain"
    echo ""
    echo "⚠️  注意: 请确保在 Cloudflare Pages 中也配置了相同的域名"
}

# 自定义主题配置
customize_theme() {
    echo ""
    echo "🎨 主题配置文件位置:"
    echo "  • 主题默认配置: themes/windsay/_config.yml"
    echo "  • 自定义配置: source/_data/theme_config.yml"
    echo ""
    echo "💡 提示:"
    echo "  • 可以在 source/_data/theme_config.yml 中自定义主题"
    echo "  • 此文件会覆盖主题的默认配置"
    echo "  • 可以修改: Hero 区域、音乐、颜色、菜单等"
    echo ""
    
    if [ ! -f "source/_data/theme_config.yml" ]; then
        read -p "是否创建自定义主题配置文件? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mkdir -p source/_data
            cp themes/windsay/_config.yml source/_data/theme_config.yml
            echo "✅ 已创建 source/_data/theme_config.yml"
        else
            return
        fi
    fi
    
    read -p "是否现在用编辑器打开主题配置? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ${EDITOR:-nano} source/_data/theme_config.yml
        echo "✅ 主题配置已更新"
    fi
}

# 更新友情链接
update_friends() {
    echo ""
    echo "👥 友情链接配置文件: source/_data/friends.json"
    echo ""
    echo "💡 示例格式:"
    cat << 'EOF'
[{
    "avatar": "http://image.example.com/avatar.jpg",
    "name": "朋友名称",
    "introduction": "朋友介绍",
    "url": "https://friend-blog.com/",
    "title": "访问博客"
}]
EOF
    echo ""
    read -p "是否现在用编辑器打开友情链接配置? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ${EDITOR:-nano} source/_data/friends.json
        echo "✅ 友情链接已更新"
    fi
}

# 更新主题
update_theme() {
    echo ""
    echo "🔄 更新 windsay 主题..."
    
    if [ -d "themes/windsay/.git" ]; then
        cd themes/windsay
        git pull origin main
        cd ../..
        echo "✅ 主题已更新到最新版本"
    else
        echo "⚠️  主题不是通过 git 子模块安装的"
        echo "   请手动下载最新版本: https://github.com/yorelll/windsay"
    fi
}

# 查看主题版本
show_theme_version() {
    echo ""
    if [ -d "themes/windsay/.git" ]; then
        cd themes/windsay
        echo "🏷️  当前版本:"
        git log -1 --pretty=format:"  提交: %h%n  日期: %ad%n  说明: %s" --date=short
        cd ../..
    else
        echo "⚠️  无法获取版本信息（主题不是通过 git 安装）"
    fi
    echo ""
}

# 本地预览
preview_blog() {
    echo ""
    echo "🌐 启动本地预览服务器..."
    echo "   访问: http://localhost:4000"
    echo "   按 Ctrl+C 停止服务器"
    echo ""
    npm run server
}

# 构建静态文件
build_blog() {
    echo ""
    echo "🔨 构建静态文件..."
    npm run build
    echo "✅ 构建完成"
    echo "   静态文件位于: public/ 目录"
}

# 提交并推送
commit_and_push() {
    echo ""
    echo "📊 Git 状态:"
    git status --short
    echo ""
    read -p "是否要提交所有更改? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "已取消"
        return
    fi
    
    echo ""
    read -p "请输入提交说明: " commit_msg
    if [ -z "$commit_msg" ]; then
        commit_msg="Update blog content"
    fi
    
    git add .
    git commit -m "$commit_msg"
    
    echo ""
    echo "✅ 已提交更改"
    echo ""
    read -p "是否要推送到 GitHub（将触发自动部署）? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push
        echo ""
        echo "✅ 已推送到 GitHub"
        echo "   GitHub Actions 将自动构建和部署你的博客"
        echo "   可以在仓库的 Actions 标签查看部署进度"
    fi
}

# 清理缓存
clean_cache() {
    echo ""
    echo "🧹 清理缓存和临时文件..."
    npm run clean
    echo "✅ 清理完成"
}

# 重新安装依赖
reinstall_deps() {
    echo ""
    echo "📦 重新安装依赖..."
    echo "   这可能需要几分钟时间..."
    rm -rf node_modules package-lock.json
    npm install
    echo "✅ 依赖已重新安装"
}

# 查看统计信息
show_stats() {
    echo ""
    echo "📊 博客统计信息:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    post_count=$(find source/_posts -name "*.md" 2>/dev/null | wc -l)
    draft_count=$(find source/_drafts -name "*.md" 2>/dev/null | wc -l)
    
    echo "  文章数量: $post_count 篇"
    echo "  草稿数量: $draft_count 篇"
    
    if [ -f "package.json" ]; then
        echo ""
        echo "  依赖包数量: $(cat package.json | grep -c '\"' || echo "未知")"
    fi
    
    if [ -d ".git" ]; then
        echo ""
        echo "  Git 提交数: $(git rev-list --count HEAD 2>/dev/null || echo "未知")"
        echo "  最后提交: $(git log -1 --pretty=format:"%ar: %s" 2>/dev/null || echo "未知")"
    fi
    
    if [ -d "public" ]; then
        echo ""
        echo "  静态文件: $(du -sh public 2>/dev/null | cut -f1 || echo "未知")"
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 主循环
while true; do
    echo ""
    show_menu
    read -p "请选择 [0-16]: " choice
    
    case $choice in
        1) create_new_post ;;
        2) create_draft ;;
        3) publish_draft ;;
        4) list_posts ;;
        5) update_blog_info ;;
        6) update_domain ;;
        7) customize_theme ;;
        8) update_friends ;;
        9) update_theme ;;
        10) show_theme_version ;;
        11) preview_blog ;;
        12) build_blog ;;
        13) commit_and_push ;;
        14) clean_cache ;;
        15) reinstall_deps ;;
        16) show_stats ;;
        0) 
            echo ""
            echo "👋 再见！"
            exit 0
            ;;
        *)
            echo "❌ 无效的选择，请输入 0-16"
            ;;
    esac
    
    echo ""
    read -p "按回车键继续..." 
done
