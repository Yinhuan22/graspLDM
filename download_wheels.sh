#!/bin/bash

##############################################################################
# 在有网络的环境下下载 graspLDM 离线依赖的 wheels
#
# 使用方法：
#   1. 在有网络的 Linux 机器上运行此脚本
#   2. 脚本会下载所有依赖到 graspldm_wheels/ 目录
#   3. 将生成的 wheels 压缩包传输到 WebIDE
#
# 注意：
#   - 需要 Python 3.8+ 和 pip
#   - 推荐在 x86_64 Linux 系统上运行（与 WebIDE 架构一致）
#   - 下载的文件可能很大（50-100GB）
#
##############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ============================================================================
# 0. 环境检查
# ============================================================================

log_info "========== 环境检查 =========="

if ! command -v python &> /dev/null; then
    log_error "Python 未找到"
    exit 1
fi

PYTHON_VERSION=$(python --version 2>&1)
log_success "$PYTHON_VERSION"

if ! command -v pip &> /dev/null; then
    log_error "pip 未找到，请确保 Python 中已安装 pip"
    exit 1
fi

# 检查网络连接（尝试 ping PyPI）
if ! ping -c 1 pypi.org &> /dev/null; then
    log_warn "⚠ 无法连接到 PyPI，请检查网络连接"
    read -p "是否继续？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# ============================================================================
# 1. 创建输出目录
# ============================================================================

log_info "========== 创建输出目录 =========="

WHEELS_DIR="graspldm_wheels"
mkdir -p "$WHEELS_DIR"
log_success "创建目录: $WHEELS_DIR"

# ============================================================================
# 2. 升级 pip 和下载工具
# ============================================================================

log_info "========== 升级 pip =========="

python -m pip install --upgrade pip setuptools wheel
log_success "pip/setuptools/wheel 升级完成"

# ============================================================================
# 3. 下载所有依赖
# ============================================================================

log_info "========== 下载依赖包 =========="

# 需要下载 requirements.txt
if [ ! -f "requirements.txt" ]; then
    log_error "requirements.txt 未找到，请在项目根目录运行此脚本"
    exit 1
fi

log_info "开始下载，这可能需要 30 分钟到几小时..."
log_info "下载位置: $WHEELS_DIR/"

# 使用 pip download 下载所有 wheels（不包括源码包）
python -m pip download \
    -r requirements.txt \
    -d "$WHEELS_DIR" \
    --no-deps \
    --python-version 38 \
    --only-binary=:all: \
    --platform manylinux2014_x86_64 \
    2>&1 | tail -30

log_success "依赖包下载完成"

# ============================================================================
# 4. 验证下载
# ============================================================================

log_info "========== 验证下载 =========="

WHEELS_COUNT=$(find "$WHEELS_DIR" -name "*.whl" | wc -l)
log_success "共下载 $WHEELS_COUNT 个 .whl 文件"

# 列出关键包
log_info ""
log_info "关键包清单:"
log_info "  - PyTorch:"
ls "$WHEELS_DIR"/torch*.whl 2>/dev/null | head -3 || log_warn "  未找到 torch wheels"

log_info "  - TorchVision:"
ls "$WHEELS_DIR"/torchvision*.whl 2>/dev/null | head -3 || log_warn "  未找到 torchvision wheels"

log_info "  - PyTorch Lightning:"
ls "$WHEELS_DIR"/pytorch_lightning*.whl 2>/dev/null || log_warn "  未找到 pytorch_lightning wheels"

log_info "  - Diffusers:"
ls "$WHEELS_DIR"/diffusers*.whl 2>/dev/null || log_warn "  未找到 diffusers wheels"

log_info "  - H5PY:"
ls "$WHEELS_DIR"/h5py*.whl 2>/dev/null | head -1 || log_warn "  未找到 h5py wheels"

# ============================================================================
# 5. 计算大小和创建压缩包
# ============================================================================

log_info ""
log_info "========== 创建压缩包 =========="

TOTAL_SIZE=$(du -sh "$WHEELS_DIR" | awk '{print $1}')
log_info "总大小: $TOTAL_SIZE"

# 创建 tar.gz 压缩包
ARCHIVE_NAME="graspldm_wheels_$(date +%Y%m%d).tar.gz"
log_info "创建压缩包: $ARCHIVE_NAME"

tar -czf "$ARCHIVE_NAME" "$WHEELS_DIR"
log_success "压缩包创建完成"

# 也创建 zip 版本（便于 Windows 传输）
ARCHIVE_ZIP="graspldm_wheels_$(date +%Y%m%d).zip"
log_info "创建 zip 压缩包: $ARCHIVE_ZIP"

zip -r -q "$ARCHIVE_ZIP" "$WHEELS_DIR" -x "$WHEELS_DIR/.gitkeep"
log_success "zip 压缩包创建完成"

# ============================================================================
# 6. 总结
# ============================================================================

log_info ""
log_info "========== 完成总结 =========="

log_success "✓ 所有 wheels 已下载完成"

log_info ""
log_info "输出文件:"
log_info "  - 目录: $WHEELS_DIR/"
log_info "  - tar.gz: $ARCHIVE_NAME ($(du -h "$ARCHIVE_NAME" | awk '{print $1}'))"
log_info "  - zip: $ARCHIVE_ZIP ($(du -h "$ARCHIVE_ZIP" | awk '{print $1}'))"

log_info ""
log_info "下一步："
log_info "  1. 将以下任一文件传输到 WebIDE:"
log_info "     - 推荐: $ARCHIVE_TAR"
log_info "     - 或: $ARCHIVE_ZIP"
log_info ""
log_info "  2. 在 WebIDE 中解压:"
log_info "     tar -xzf $ARCHIVE_NAME"
log_info "     或"
log_info "     unzip $ARCHIVE_ZIP"
log_info ""
log_info "  3. 运行离线安装脚本:"
log_info "     ./install_offline_deps.sh"

log_info ""
log_info "提示："
log_info "  - 如果只需要部分包，可以手动删除 $WHEELS_DIR/ 中不需要的 .whl"
log_info "  - 保留最小集合: torch, torchvision, pytorch-lightning, diffusers, h5py, numpy, scipy 等"
log_info "  - 大约 150 个包是正常的，总大小 50-100 GB"
