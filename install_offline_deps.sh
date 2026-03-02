#!/bin/bash

##############################################################################
# graspLDM 离线依赖安装脚本
# 
# 用途：在无外网的 WebIDE 中，从预下载的 wheels/ 目录离线安装所有依赖
# 
# 使用方法：
#   chmod +x install_offline_deps.sh
#   ./install_offline_deps.sh
#
# 前置条件：
#   1. Python 3.8+ 已安装
#   2. 项目根目录中存在 wheels/ 目录，包含所有依赖的 .whl 文件
#   3. 当前目录是项目根目录
##############################################################################

set -e  # 出错立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
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
# 1. 环境检查
# ============================================================================

log_info "========== 第一步：环境检查 =========="

if ! command -v python &> /dev/null; then
    log_error "Python 未找到，请先安装 Python 3.8+"
    exit 1
fi

PYTHON_VERSION=$(python --version 2>&1 | awk '{print $2}')
log_info "Python 版本: $PYTHON_VERSION"

if ! command -v pip &> /dev/null; then
    log_error "pip 未找到，请先安装 pip"
    exit 1
fi

PIP_VERSION=$(pip --version)
log_info "$PIP_VERSION"

# 检查 wheels 目录
if [ ! -d "wheels" ]; then
    log_error "wheels/ 目录不存在！"
    log_error "请确保："
    log_error "  1. 当前目录是项目根目录"
    log_error "  2. wheels/ 目录存在，包含所有依赖的 .whl 文件"
    exit 1
fi

WHEELS_COUNT=$(find wheels -name "*.whl" 2>/dev/null | wc -l)
log_success "找到 $WHEELS_COUNT 个 .whl 文件"

# ============================================================================
# 2. 升级 pip/setuptools/wheel
# ============================================================================

log_info "========== 第二步：升级 pip/setuptools/wheel =========="

# 尝试从 wheels 目录中查找这些工具的 whl
if ls wheels/pip*.whl wheels/setuptools*.whl wheels/wheel*.whl 1>/dev/null 2>&1; then
    log_info "从本地 wheels 升级基础工具..."
    python -m pip install --no-index --no-deps --find-links=./wheels pip setuptools wheel 2>&1 || true
    log_success "基础工具升级完成"
else
    log_warn "wheels 中没有找到 pip/setuptools/wheel，将使用系统版本"
fi

# ============================================================================
# 3. 安装所有依赖
# ============================================================================

log_info "========== 第三步：安装所有依赖 =========="
log_info "开始安装，这可能需要几分钟..."

# 使用 --no-index 和 --find-links 从本地 wheels 安装，忽略依赖关系
# 因为所有依赖已经包含在 wheels 中
python -m pip install \
    --no-index \
    --no-deps \
    --find-links=./wheels \
    --ignore-installed \
    ./wheels/*.whl \
    2>&1 | tail -20  # 只显示最后 20 行

# 检查安装结果
if [ $? -eq 0 ]; then
    log_success "所有依赖安装完成！"
else
    log_warn "依赖安装过程中可能出现错误，但可能已部分安装"
fi

# ============================================================================
# 4. 验证关键依赖
# ============================================================================

log_info "========== 第四步：验证关键依赖 =========="

# 检查列表
REQUIRED_PACKAGES=(
    "torch"
    "torchvision"
    "pytorch_lightning"
    "diffusers"
    "h5py"
    "numpy"
    "scipy"
    "scikit-learn"
    "pandas"
    "trimesh"
    "einops"
    "PIL"
)

ALL_VERIFIED=true

for package in "${REQUIRED_PACKAGES[@]}"; do
    if python -c "import $package" 2>/dev/null; then
        VERSION=$(python -c "import $package; print(getattr($package, '__version__', 'unknown'))" 2>/dev/null || echo "unknown")
        log_success "$package (v$VERSION) ✓"
    else
        log_error "$package ✗"
        ALL_VERIFIED=false
    fi
done

# ============================================================================
# 5. GPU/CUDA 验证（可选）
# ============================================================================

log_info "========== 第五步：GPU/CUDA 验证（可选）=========="

if python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'GPU: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"None\"}')" 2>/dev/null; then
    log_success "PyTorch GPU 检查完成"
else
    log_warn "无法检查 GPU 状态，继续..."
fi

# ============================================================================
# 6. 总结
# ============================================================================

log_info "========== 安装总结 =========="

if [ "$ALL_VERIFIED" = true ]; then
    log_success "✓ 所有关键依赖已验证！"
    log_info "现在可以运行实验了："
    log_info "  1. 修改配置文件路径（使用相对路径）"
    log_info "  2. 运行 ./run_full_experiment.sh 执行完整实验流程"
    exit 0
else
    log_warn "⚠ 部分依赖验证失败，可能需要手动检查"
    exit 1
fi
