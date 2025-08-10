# 轻量级云服务 (LCS) 部署方案

一个5分钟拉起、用完即走、账单最小（≈ 24 元/月或 0.004 USD/Spot·h）、零外泄的云服务部署方案。

## 方案概述

本方案提供了一种快速部署轻量级云服务的方法，具有以下特点：

- **最小规格**：2C4G 轻量级云主机或 t4g.small 实例
- **最小成本**：腾讯云约 24 元/月，AWS Spot 约 0.004 USD/小时
- **零外泄**：无公网出口，仅允许 SSH 入站连接和 HTTP 访问
- **安全隔离**：Docker 容器运行在隔离环境中
- **临时使用**：用完即销毁，费用归零
- **一键部署**：支持通过 CI/CD 平台或 GitHub Actions 一键部署

## 文件说明

- `main.tf`：Terraform 配置文件，支持腾讯云和 AWS 两种部署方式
- `cloud-init.yaml`：云实例初始化配置
- `spec.json`：AWS Spot 实例配置
- `access.sh`：本地访问脚本，用于建立 SSH 隧道和访问云服务
- `cant.yml`：CI/CD 平台（如 cant）的一键部署配置文件
- `.cIIhr.yml`：GitHub Actions 工作流配置，支持一键部署和销毁
- `deploy.yml`：GitHub Actions 工作流配置，支持部署到自定义服务器

## 部署步骤

### 方式一：腾讯云轻量应用服务器（约 24 元/月）

1. 安装 Terraform（如果尚未安装）：
   ```bash
   # macOS
   brew install terraform
   
   # Ubuntu/Debian
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   sudo apt update && sudo apt install terraform
   ```

2. 配置腾讯云凭证：
   ```bash
   export TENCENTCLOUD_SECRET_ID="你的腾讯云 SecretId"
   export TENCENTCLOUD_SECRET_KEY="你的腾讯云 SecretKey"
   ```

3. 初始化并应用 Terraform 配置：
   ```bash
   terraform init
   terraform apply -auto-approve \
     -var="region=ap-beijing" \
     -var="key_name=mykey" \
     -var="image_id=lighthouse-ubuntu-22.04" \
     -var="plan_id=bundle_2024_gen_2c4g20g" \
     -var="docker_image=nginx:1.25-alpine"
   ```

4. 记录输出的 SSH 命令和 IP 地址。

### 方式二：AWS Spot 实例（约 0.004 USD/小时）

1. 安装 AWS CLI（如果尚未安装）：
   ```bash
   # macOS
   brew install awscli
   
   # Ubuntu/Debian
   sudo apt install awscli
   ```

2. 配置 AWS 凭证：
   ```bash
   aws configure
   ```

3. 初始化并应用 Terraform 配置（指定 AWS 镜像 ID）：
   ```bash
   terraform init
   terraform apply -auto-approve \
     -var="region=us-east-1" \
     -var="key_name=mykey" \
     -var="image_id=ami-0abcdef1234567890" \
     -var="docker_image=nginx:1.25-alpine"
   ```

4. 记录输出的 SSH 命令和 IP 地址。

### 方式三：使用 CI/CD 一键部署

本方案提供了 `cant.yml` 配置文件，可以直接在 cant（或任意 CI/CD/自动化平台）中使用，实现一键部署。

#### 在 cant 平台使用步骤

1. 将本仓库中的所有文件上传到 cant 平台。

2. 在 cant 的「Secrets」中添加以下凭证：
   - 腾讯云部署：`TENCENT_SECRET_ID` 和 `TENCENT_SECRET_KEY`
   - AWS 部署：`AWS_ACCESS_KEY_ID` 和 `AWS_SECRET_ACCESS_KEY`

3. 确保你的 SSH 公钥已上传到对应云平台，并且 `SSH_KEY_NAME` 变量与之匹配。

4. 触发任务执行，等待部署完成。

5. 部署完成后，可以通过 `http://localhost:8080`（或配置的其他端口）访问服务。

#### 自定义部署变量

在 `cant.yml` 中，你可以根据需要修改以下变量：

```yaml
vars:
  CLOUD_PROVIDER: tencent  # 或 aws
  REGION: ap-beijing
  SSH_KEY_NAME: mykey
  IMAGE_ID: img-lightsail-centos7
  PLAN_ID: bundle_small
  DOCKER_IMAGE: nginx:1.25-alpine
  LOCAL_PORT: 8080
```

### 方式四：使用 GitHub Actions 一键部署

本方案提供了 `.cIIhr.yml` GitHub Actions 工作流配置文件，可以实现通过 GitHub 一键部署和销毁云资源。

#### 详细步骤

1. **创建 GitHub 仓库**：
   - 浏览器打开 https://github.com/new
   - 取名为 `light-cloud`（或其他名称）
   - 点击 "Create repository"
   - 复制仓库地址（形如 `https://github.com/你的用户名/light-cloud.git`）

2. **本地推送触发部署**：
   - 回到终端，一次性粘贴以下命令（替换为你的仓库地址）：
     ```bash
     cd ~/Desktop
     git init -b main
     git add .
     git commit -m "deploy"
     git remote add origin https://github.com/你的用户名/light-cloud.git
     git push -u origin main
     ```

3. **配置 GitHub Secrets**：
   - 推送完成后，浏览器进入刚建好的仓库
   - 点击 Settings → Secrets and variables → Actions
   - 点击 "New repository secret" 添加以下凭证：
     - `TENCENT_SECRET_ID`：你的腾讯云 SecretId
     - `TENCENT_SECRET_KEY`：你的腾讯云 SecretKey
     - 或 AWS 凭证：`AWS_ACCESS_KEY_ID` 和 `AWS_SECRET_ACCESS_KEY`

4. **查看部署进度**：
   - 回到仓库首页，点击 Actions 标签页
   - 你会看到工作流自动运行
   - 约 3-5 分钟后，当日志出现 `HTTP/1.1 200 OK` 时表示部署成功

5. **访问服务**：
   - 浏览器打开 `http://localhost:8080`

6. **销毁资源**（可选）：
   ```bash
   git checkout -b destroy
   git push -u origin destroy
   ```

#### 一键命令指南

完整的部署到销毁流程只需几个简单命令：

| 步骤 | 操作 | 命令 |
|------|------|------|
| 1 | 进入项目目录 | `cd <项目目录>` |
| 2 | 一键部署 | 复制下面 5 行，回车即可<br>`git init -b main`<br>`git add .`<br>`git commit -m "deploy"`<br>`git remote add origin https://github.com/<用户名>/<仓库>.git`<br>`git push -u origin main` |
| 3 | 等待 3-5 分钟 | GitHub Actions 自动运行 `.cIIhr.yml`，日志出现 `HTTP/1.1 200 OK` 即成功 |
| 4 | 本地访问 | 浏览器打开 `http://localhost:8080` |
| 5 | 一键销毁（可选） | `git checkout -b destroy && git push -u origin destroy` |

完成后资源自动销毁，账单归零。

#### 自定义部署配置

在 `.cIIhr.yml` 文件中，你可以根据需要修改以下环境变量：

```yaml
env:
  CLOUD_PROVIDER: tencent        # 可选 aws / tencent
  REGION: ap-beijing
  KEY_NAME: mykey                # 已上传到云平台的 SSH 公钥名称
  IMAGE: nginx:alpine
  LOCAL_PORT: 8080               # 本地映射端口
```

#### 工作流程说明

- **部署流程**：
  1. 安装 Terraform 和云平台 CLI 工具
  2. 使用 Terraform 部署云资源
  3. 建立 SSH 隧道连接云实例
  4. 验证服务是否正常运行

- **销毁流程**：
  1. 安装 Terraform
  2. 执行 `terraform destroy` 销毁所有资源

### 方式五：使用自定义服务器部署

本方案提供了 `deploy.yml` GitHub Actions 工作流配置文件，可以实现将项目部署到已有的自定义服务器上。

#### 使用步骤

1. 将本仓库中的所有文件（包括 `deploy.yml`）一起推送到 GitHub 仓库。

2. 在 GitHub 仓库的「Settings → Secrets and variables → Actions」中添加以下凭证：
   - `SERVER_HOST`：服务器IP或域名
   - `SERVER_USERNAME`：服务器用户名
   - `SSH_PRIVATE_KEY`：用于连接服务器的SSH私钥
   - 云平台凭证（如果需要）：`TENCENT_SECRET_ID` 和 `TENCENT_SECRET_KEY`

3. 部署和销毁：
   - **部署**：向主分支推送代码即可自动触发部署
   - **销毁**：创建并推送名为 `destroy` 的分支即可自动触发资源销毁

#### 一键命令指南

| 步骤 | 操作 | 命令 |
|------|------|------|
| 1 | 仓库初始化（仅首次需要） | `git init -b main` |
| 2 | 配置自动化工作流 | 确保 `deploy.yml` 文件存在于项目根目录 |
| 3 | 一键更新部署 | 复制下面 3 行，回车即可<br>`git add .`<br>`git commit -m "deploy"`<br>`git push -u origin main` |
| 4 | 等待部署完成 | 在GitHub仓库 → Actions 标签页查看实时日志 |
| 5 | 访问服务 | 浏览器打开 `http://localhost:8080` 或服务器URL |

#### 自定义部署配置

在 `deploy.yml` 文件中，你可以根据需要修改以下环境变量：

```yaml
env:
  # 部署配置
  SERVER_HOST: ${{ secrets.SERVER_HOST }}  # 服务器IP或域名
  SERVER_PORT: 22  # SSH端口，默认22
  SERVER_USERNAME: ${{ secrets.SERVER_USERNAME }}  # 服务器用户名
  DEPLOY_PATH: /opt/lcs  # 服务器上的部署路径
  
  # 应用配置
  DOCKER_IMAGE: nginx:alpine  # 可选：如果使用Docker部署
  APP_PORT: 80  # 应用端口
  LOCAL_PORT: 8080  # 本地映射端口
```

#### 工作流程说明

- **部署流程**：
  1. 设置SSH密钥和添加服务器到已知主机
  2. 将项目文件复制到服务器
  3. 在服务器上安装依赖（Terraform和Docker）
  4. 配置云凭证并部署基础设施
  5. 建立SSH隧道并验证服务

- **销毁流程**：
  1. 连接到服务器
  2. 执行 `terraform destroy` 销毁所有资源

## 访问方法

使用提供的 `access.sh` 脚本建立 SSH 隧道并访问云服务：

```bash
# 使脚本可执行
chmod +x access.sh

# 方式1：使用位置参数（适用于CI/CD）
./access.sh <云实例IP> <本地端口>

# 方式2：使用命名参数
# 建立端口转发隧道
./access.sh --ip <云实例IP> --port 8080

# 建立Unix套接字隧道并发送命令
./access.sh --ip <云实例IP> --cmd status

# 使用现有Unix套接字隧道发送命令
socat - UNIX-CONNECT:/tmp/lcs.sock <<< '{"cmd":"status"}'
```

## 销毁资源（账单归零）

### 使用 Terraform

```bash
terraform destroy -auto-approve
```

### 使用 GitHub Actions

将代码推送到 `destroy` 分支：

```bash
git checkout -b destroy
git push origin destroy
```

### 手动销毁 AWS 资源

```bash
# 取消 Spot 实例请求
aws ec2 describe-spot-instance-requests --filters "Name=state,Values=active" --query "SpotInstanceRequests[*].SpotInstanceRequestId" --output text | xargs -I {} aws ec2 cancel-spot-instance-requests --spot-instance-request-ids {}

# 终止相关实例
aws ec2 describe-instances --filters "Name=instance-lifecycle,Values=spot" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text | xargs -I {} aws ec2 terminate-instances --instance-ids {}
```

## 安全注意事项

1. **SSH 密钥**：建议使用 SSH 密钥而非密码进行身份验证。
2. **防火墙规则**：当前配置允许 SSH（端口 22）和 HTTP（端口 80）入站连接，确保不要开放其他端口。
3. **临时使用**：用完即销毁，避免不必要的费用和潜在的安全风险。
4. **凭证安全**：在 CI/CD 平台或 GitHub Actions 中使用 Secrets 存储敏感凭证，避免明文存储。
5. **代码审查**：在部署前，请审查所有代码，确保其安全性。

## 自定义

如需自定义部署，可以修改以下文件：

- `main.tf`：调整云实例规格、区域或其他配置
- `cant.yml`、`.cIIhr.yml` 或 `deploy.yml`：调整 CI/CD 流程或变量
- `access.sh`：自定义访问方式或端口转发配置

## 故障排除

1. **SSH 连接问题**：
   - 检查安全组规则是否正确配置
   - 确认实例已完全启动
   - 验证 SSH 密钥权限（应为 600）

2. **容器启动失败**：
   - SSH 到实例并检查 Docker 日志：`docker logs lcs`
   - 检查 cloud-init 日志：`cat /var/log/cloud-init-output.log`

3. **隧道问题**：
   - 确认 socat 已安装（用于Unix套接字模式）
   - 检查端口转发是否成功：`netstat -an | grep <LOCAL_PORT>`
   - 尝试手动建立 SSH 隧道：`ssh -N -L <LOCAL_PORT>:localhost:80 root@<云IP>`

4. **CI/CD 部署问题**：
   - 检查 Secrets 是否正确配置
   - 查看任务日志，确认每个步骤是否成功执行
   - 确保 SSH 密钥已正确上传到云平台

5. **GitHub Actions 问题**：
   - 检查 GitHub 仓库的 Actions 选项卡中的工作流运行日志
   - 确保 Secrets 已正确添加到仓库设置中
   - 验证 SSH 密钥名称与配置文件中的变量匹配
