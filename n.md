# 轻量级云服务 (LCS) 部署总结

## 五步完成部署

1. **按照快速指南创建GitHub仓库**
   - 浏览器打开 https://github.com/new
   - 取名 light-cloud
   - 点击 Create repository
   - 复制仓库地址

2. **执行一键推送命令**
   ```bash
   cd ~/Desktop
   git init -b main
   git add .
   git commit -m "deploy"
   git remote add origin https://github.com/你的用户名/light-cloud.git
   git push -u origin main
   ```

3. **配置必要的Secrets**
   - 进入仓库 → Settings → Secrets and variables → Actions
   - 添加两条密钥：
     - `TENCENT_SECRET_ID`
     - `TENCENT_SECRET_KEY`

4. **等待自动部署完成**
   - 进入仓库 → Actions 标签页
   - 等待 3-5 分钟
   - 日志出现 `HTTP/1.1 200 OK` 表示成功

5. **通过浏览器访问部署的服务**
   - 打开 `http://localhost:8080`

## 用完即毁（可选）

```bash
git checkout -b destroy
git push -u origin destroy
```

## 文件说明

- **快速指南.md** - 一页式部署步骤表格
- **README.md** - 完整技术文档和五种部署方式
- **main.tf** - Terraform 配置文件
- **access.sh** - SSH 隧道脚本
- **.cIIhr.yml** - GitHub Actions 工作流配置
- **deploy.yml** - 自定义服务器部署配置
