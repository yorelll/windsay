# 博客配置文件和 GitHub Actions 示例

本目录包含用于设置 Hexo 博客并部署到 Cloudflare Pages 的示例配置文件。

## 文件说明

### blog-config/ - 博客配置文件

用于你的博客仓库根目录的配置文件：

- **_config.yml** - Hexo 主配置文件
- **package.json** - npm 依赖配置
- **.gitignore** - Git 忽略文件配置
- **.nvmrc** - Node.js 版本配置

### github-actions/ - GitHub Actions 工作流

用于自动化部署的 GitHub Actions 配置（放在博客仓库的 `.github/workflows/` 目录）：

- **deploy.yml** - 主部署工作流（推荐使用）
- **deploy-wrangler.yml** - 使用 Wrangler CLI 的替代部署方法
- **preview.yml** - Pull Request 预览部署

## 使用方法

### 1. 设置博客项目

```bash
# 创建博客目录
mkdir my-hexo-blog
cd my-hexo-blog

# 复制配置文件
cp path/to/windsay/examples/blog-config/* .

# 安装依赖
npm install

# 初始化 Hexo
hexo init .

# 添加主题为子模块
git submodule add https://github.com/yorelll/windsay.git themes/windsay
```

### 2. 设置 GitHub Actions

```bash
# 创建工作流目录
mkdir -p .github/workflows

# 复制部署工作流
cp path/to/windsay/examples/github-actions/deploy.yml .github/workflows/

# 可选：复制预览部署工作流
cp path/to/windsay/examples/github-actions/preview.yml .github/workflows/
```

### 3. 配置 GitHub Secrets

在你的 GitHub 仓库中设置以下 secrets：

1. 进入仓库 Settings → Secrets and variables → Actions
2. 添加 secrets：
   - `CLOUDFLARE_API_TOKEN`
   - `CLOUDFLARE_ACCOUNT_ID`

### 4. 修改配置

编辑以下文件中的配置：

- **_config.yml**: 修改 `url` 为你的域名
- **deploy.yml**: 修改 `projectName` 为你的 Cloudflare Pages 项目名
- **package.json**: 修改 `name`、`author` 等信息

## 工作流说明

### deploy.yml（主部署工作流）

**触发条件**:
- 推送到 main 分支
- 手动触发

**功能**:
1. 检出代码和子模块
2. 设置 Node.js 环境
3. 安装依赖
4. 构建 Hexo 站点
5. 部署到 Cloudflare Pages

### deploy-wrangler.yml（替代部署方法）

使用 Cloudflare Wrangler CLI 直接部署，提供更多自定义选项。

### preview.yml（预览部署）

**触发条件**:
- Pull Request 到 main 分支

**功能**:
1. 构建预览版本
2. 部署到单独的预览环境
3. 在 PR 中添加评论

## 注意事项

1. **子模块**: 确保在 `Checkout` 步骤中启用 `submodules: true`
2. **Node.js 版本**: 使用 Node.js 18 以保证兼容性
3. **缓存**: GitHub Actions 会自动缓存 npm 依赖以加速构建
4. **分支名称**: 根据你的仓库修改默认分支名称（main 或 master）

## 自定义

### 修改构建命令

在 `package.json` 中自定义构建脚本：

```json
{
  "scripts": {
    "build": "hexo clean && hexo generate",
    "build:prod": "hexo clean && hexo generate --config _config.yml,_config.prod.yml"
  }
}
```

### 添加环境变量

在工作流文件中添加环境变量：

```yaml
- name: Build
  env:
    NODE_ENV: production
    HEXO_ENV: production
  run: npm run build
```

### 自定义部署分支

```yaml
- name: Publish to Cloudflare Pages
  uses: cloudflare/pages-action@v1
  with:
    # ... 其他配置
    branch: production  # 自定义分支名
```

## 故障排除

### 构建失败

1. 检查 Node.js 版本是否正确
2. 确保所有依赖都在 `package.json` 中
3. 查看构建日志中的错误信息

### 主题未加载

1. 确保子模块已正确添加
2. 检查 `_config.yml` 中的 `theme: windsay` 配置
3. 验证 `themes/windsay` 目录存在

### 部署失败

1. 验证 Cloudflare API Token 和 Account ID
2. 确保 Cloudflare Pages 项目已创建
3. 检查工作流权限设置

### 网络和克隆问题

#### 快速克隆选项

脚本现在提供三种克隆方式：

1. **GitHub HTTPS (默认)** - 适合网络环境良好的用户
2. **GitHub 镜像站** - 推荐中国大陆用户使用，速度更快
3. **SSH 方式** - 需要配置 SSH 密钥

**自动化脚本使用**：
```bash
# 使用环境变量跳过交互式提示
CLONE_OPTION=1 bash examples/quick-start.sh my-blog  # HTTPS
CLONE_OPTION=2 bash examples/quick-start.sh my-blog  # 镜像站
CLONE_OPTION=3 bash examples/quick-start.sh my-blog  # SSH
```

**优化特性**：
- 使用浅克隆 (`--depth 1`) 减少下载大小
- 自动配置 Git 超时和缓冲区设置
- 失败时自动重试 3 次
- 失败时自动清理残留文件

#### 问题：TLS 连接错误

如果在运行 `quick-start.sh` 时遇到类似错误：
```
fatal: unable to access 'https://github.com/yorelll/windsay.git/': 
GnuTLS recv error (-110): The TLS connection was non-properly terminated.
```

**解决方案**：

1. **使用快速开始脚本的重试功能**
   ```bash
   # 脚本会自动重试 3 次
   bash examples/quick-start.sh my-blog
   ```

2. **检查网络连接**
   ```bash
   ping github.com
   curl -I https://github.com
   ```

3. **使用 SSH 克隆（推荐）**
   
   编辑 `quick-start.sh` 或手动操作：
   ```bash
   # 确保已配置 SSH 密钥
   git submodule add git@github.com:yorelll/windsay.git themes/windsay
   ```

4. **配置 Git 使用代理**
   ```bash
   # HTTP 代理
   git config --global http.proxy http://proxy.example.com:8080
   
   # SOCKS5 代理
   git config --global http.proxy socks5://127.0.0.1:1080
   ```

5. **增加超时时间**
   ```bash
   git config --global http.postBuffer 524288000
   git config --global http.lowSpeedLimit 0
   git config --global http.lowSpeedTime 999999
   ```

6. **直接克隆（非子模块方式）**
   ```bash
   cd my-blog
   git clone https://github.com/yorelll/windsay themes/windsay
   ```

7. **手动下载主题**
   ```bash
   # 下载 ZIP 文件
   wget https://github.com/yorelll/windsay/archive/refs/heads/main.zip
   unzip main.zip
   mv windsay-main themes/windsay
   ```

#### 问题：子模块初始化失败

**症状**：`themes/windsay` 目录存在但为空

**解决方案**：
```bash
# 初始化并更新子模块
git submodule init
git submodule update

# 或一次性命令
git submodule update --init --recursive
```

#### 问题：快速开始脚本中断

**症状**：脚本执行到一半停止

**解决方案**：
```bash
# 1. 进入已创建的目录
cd my-blog

# 2. 手动完成剩余步骤
# 如果主题未克隆
git submodule add https://github.com/yorelll/windsay themes/windsay

# 如果配置文件未复制
cp themes/windsay/examples/blog-config/_config.yml .
cp themes/windsay/examples/blog-config/.gitignore .

# 如果页面未创建
npx hexo new page "categories"
npx hexo new page "tags"
npx hexo new page "about"
npx hexo new page "friends"
```

## 更多信息

详细的部署指南请参考 [DEPLOYMENT_GUIDE_CN.md](../DEPLOYMENT_GUIDE_CN.md)
