# deb_downloader

基于 Docker 容器隔离环境，一键离线下载指定 Ubuntu 版本的软件包及其全部依赖 .deb 并打包，便于在无网目标机器上完成离线安装。

支持本地执行，亦支持通过 GitHub Actions 网页端一键在线打包并自动发布到 GitHub Releases（任何人都可 Fork 本仓库开箱即用）。

---

## 云端一键打包（GitHub Actions 免本地环境）

无需在本地安装 Docker，直接在 GitHub 页面点击即可打包：

1. **Fork 本仓库** 到自己的 GitHub 账号下。
2. 进入仓库的 **Actions** 标签页。
3. 在左侧列表点击 **Download and Release Deb**。
4. 点击页面右侧的 **Run workflow** 按钮：
   - **Ubuntu 版本**：下拉选择版本（如 22.04、20.04、24.04 等）。
   - **软件包名称**：输入需要下载的软件名（例如 `nginx`、`curl` 或 `docker-ce`）。
   - **自定义源/Dockerfile（可选）**：留空默认使用官方源；若需国内源加速可填 `Dockerfile.china`；特定软件源可填 `Dockerfile_nginx`。
   - 点击绿色的 **Run workflow** 按钮启动任务。
5. 任务运行完成后（通常约 1~2 分钟）：
   - 点击该次运行的记录，在 **Summary** 页面即可直接点击直链下载。
   - 或者直接前往仓库的 **Releases** 页面下载打包好的 `<package_name>-<ubuntu_version>.tar.gz` 文件。

---

## 本地命令行使用

### 命令格式
```bash
bash download.sh <ubuntu_version> <package_name> [in_china | custom_dockerfile]
```

### 常用示例

1. **默认官方源下载**（以 Ubuntu 22.04 下载 curl 为例）：
   ```bash
   bash download.sh 22.04 curl
   ```

2. **国内镜像加速下载**（使用清华源加速国内下载）：
   ```bash
   bash download.sh 22.04 curl in_china
   ```

3. **下载指定第三方官方源**（如官方最新版 nginx）：
   ```bash
   bash download.sh 22.04 nginx Dockerfile_nginx
   ```

执行完成后，将在当前目录生成：`<package_name>-<ubuntu_version>.tar.gz`。

---

## 目标机器离线安装

将生成的压缩包拷贝到无网的目标 Ubuntu 机器上，执行以下命令即可：

```bash
# 1. 解压到临时目录
mkdir -p /tmp/debs && tar -zxvf <package>-<version>.tar.gz -C /tmp/debs

# 2. 批量安装所有依赖及主程序
cd /tmp/debs && sudo dpkg -i *.deb
```

---

## 文件说明

- `.github/workflows/download.yml`：GitHub Actions 手动一键构建与 Release 自动发布工作流。
- `download.sh`：主执行脚本（自动构建镜像、下载依赖、打包并清理临时资源）。
- `Dockerfile`：官方 Ubuntu 基础镜像配置。
- `Dockerfile.china`：国内清华源加速配置（支持 Ubuntu 20.04 / 22.04 / 24.04）。
- `Dockerfile_nginx`：配置了 Nginx 官方 APT 源与 GPG 密钥的模板（可作为自定义第三方源参考）。
