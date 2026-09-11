# deb_downloader

基于 Docker 容器隔离环境，一键离线下载指定 Ubuntu 版本的软件包及其全部依赖 .deb 并打包，便于在无网目标机器上完成离线安装。

支持本地执行，亦支持通过 GitHub Actions 云端一键下载并自动发布到 GitHub Releases（任何人都可 Fork 本仓库开箱即用）。

---

## 云端一键下载（免本地环境）

无需在本地安装 Docker，直接借助 GitHub Actions 极速云端打包：

### 方式 1：新建 Issue 自动触发（推荐）
1. Fork 本仓库。
2. 进入仓库的 **Issues** 页面，点击 **New Issue**。
3. 选择 **离线包下载申请 (Download Deb)** 模板，选择 Ubuntu 版本并填入软件包名称，点击提交。
4. GitHub Actions 将自动触发打包，并在 Issue 评论区自动回复下载直链及安装命令，随后自动结单。

### 方式 2：Actions 页面手动触发
1. 进入仓库的 **Actions** 标签页。
2. 在左侧选择 **Download and Release Deb** 工作流。
3. 点击右侧 **Run workflow** 下拉菜单，选择 Ubuntu 版本、输入软件包名，点击运行。
4. 运行完成后，在仓库的 **Releases** 页面即可下载打包好的 `.tar.gz` 离线文件。

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

- `.github/workflows/download.yml`：GitHub Actions 自动构建与 Release 发布工作流。
- `.github/ISSUE_TEMPLATE/download.yml`：Issue 可视化下载申请表单模板。
- `download.sh`：主执行脚本（自动构建镜像、下载依赖、打包并清理临时资源）。
- `Dockerfile`：官方 Ubuntu 基础镜像配置。
- `Dockerfile.china`：国内清华源加速配置（支持 Ubuntu 20.04 / 22.04 / 24.04）。
- `Dockerfile_nginx`：配置了 Nginx 官方 APT 源与 GPG 密钥的模板（可作为自定义第三方源参考）。
