#!/usr/bin/env bash
set -e

# 防止 Windows 下 Git Bash 将容器内 Linux 路径 (如 /__tmp__) 自动转换为 Windows 路径
export MSYS_NO_PATHCONV=1

ARCHIVE_DIR="/var/cache/apt/archives"

if [ $# -lt 2 ]; then
  echo "使用说明: $0 <ubuntu_version> <package_name> [in_china | custom_dockerfile]"
  echo "示例:"
  echo "  $0 22.04 curl                  # 使用默认官方源"
  echo "  $0 22.04 curl in_china         # 使用国内清华源加速"
  echo "  $0 22.04 nginx Dockerfile_nginx # 使用特定软件源 (如官方 Nginx)"
  exit 1
fi

UBT_VER=$1
PACKAGE=$2
CUSTOM_OPT=$3

TAR_PATH="${PACKAGE}-${UBT_VER}.tar.gz"

# 确定使用的 Dockerfile
if [ "${CUSTOM_OPT}" == "in_china" ]; then
  dockerfilename="Dockerfile.china"
elif [ -n "${CUSTOM_OPT}" ] && [ -f "${CUSTOM_OPT}" ]; then
  dockerfilename="${CUSTOM_OPT}"
else
  dockerfilename="Dockerfile"
fi

if [ ! -f "${dockerfilename}" ]; then
  echo "错误: 未找到 Dockerfile: ${dockerfilename}"
  exit 1
fi

# 唯一临时镜像名称（包含进程 ID 避免并发冲突）
IMAGE_TAG="tmp_deb_${PACKAGE}_${UBT_VER//./_}_$$"

# 退出时自动清理临时镜像
cleanup() {
  echo "==> 清理临时 Docker 镜像: ${IMAGE_TAG} ..."
  docker rmi -f "${IMAGE_TAG}" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

echo "==> 1. 开始构建 Docker 镜像 (基于 ${dockerfilename}, Ubuntu: ${UBT_VER}) ..."
docker build -t "${IMAGE_TAG}" --build-arg ubuntu_version="${UBT_VER}" -f "${dockerfilename}" .

echo "==> 2. 容器中下载 deb 依赖包并打包 ..."
docker run --rm \
  -v "$(pwd):/__tmp__" \
  "${IMAGE_TAG}" \
  /bin/bash -c "
    rm -f /etc/apt/apt.conf.d/docker-clean
    apt-get update && apt-get install -y --download-only ${PACKAGE}
    deb_count=\$(ls -1 ${ARCHIVE_DIR}/*.deb 2>/dev/null | wc -l)
    if [ \"\$deb_count\" -eq 0 ]; then
      echo '⚠️ 警告: 未在缓存目录找到任何 deb 文件，可能该软件包已在基础镜像中预装或软件名有误。'
      exit 1
    fi
    echo \"==> 共下载到 \$deb_count 个 deb 文件，正在打包为 /__tmp__/${TAR_PATH} ...\"
    tar -czvf /__tmp__/${TAR_PATH} -C ${ARCHIVE_DIR} --exclude='partial*' --exclude='lock*' .
  "

if [ -f "${TAR_PATH}" ]; then
  echo "=========================================================="
  echo "🎉 下载打包完成: $(pwd)/${TAR_PATH}"
  echo "📦 文件大小: $(ls -lh "${TAR_PATH}" | awk '{print $5}')"
  echo "💡 目标机器离线安装方式:"
  echo "   mkdir -p /tmp/debs && tar -zxvf ${TAR_PATH} -C /tmp/debs"
  echo "   cd /tmp/debs && sudo dpkg -i *.deb"
  echo "=========================================================="
else
  echo "❌ 打包失败，未生成 ${TAR_PATH}"
  exit 1
fi
