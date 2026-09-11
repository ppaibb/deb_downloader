# deb_downloader

基于 Docker 容器隔离环境，一键离线下载指定 Ubuntu 版本的软件包及其全部依赖 .deb 并打包，便于在无网目标机器上完成离线安装。

---

## 快速使用

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

- `download.sh`：主执行脚本（自动构建镜像、下载依赖、打包并清理临时资源）。
- `Dockerfile`：官方 Ubuntu 基础镜像配置。
- `Dockerfile.china`：国内清华源加速配置（支持 Ubuntu 20.04 / 22.04 / 24.04）。
- `Dockerfile_nginx`：配置了 Nginx 官方 APT 源与 GPG 密钥的模板（可作为自定义第三方源参考）。
