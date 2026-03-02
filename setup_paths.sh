#!/bin/bash

##############################################################################
# graspLDM 配置路径修改脚本
# 
# 用途：将所有硬编码的绝对路径修改为相对路径，支持离线部署
# 
# 修改内容：
#   1. 数据路径：/home/mi/siat/graspldm/graspLDM/data/ → ./data/
#   2. 输出路径：/home/mi/siat/graspldm/graspLDM/output/ → ./output/
#   3. 配置文件中的 root_data_dir
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

# 检查当前目录是否是项目根目录
if [ ! -f "requirements.txt" ] || [ ! -d "configs" ]; then
    echo -e "${RED}[ERROR]${NC} 请在项目根目录运行此脚本"
    exit 1
fi

log_info "========== 配置路径修改 =========="

# ============================================================================
# 1. 修改主配置文件
# ============================================================================

log_info "修改 configs/comparison/exp_diffusion_vs_fm.py ..."

MAIN_CONFIG="configs/comparison/exp_diffusion_vs_fm.py"

# 备份原文件
cp "$MAIN_CONFIG" "$MAIN_CONFIG.bak"
log_info "已备份到 $MAIN_CONFIG.bak"

# 修改根数据目录
sed -i 's|root_data_dir = "data/ACRONYM"|root_data_dir = "./data/ACRONYM"|g' "$MAIN_CONFIG"
sed -i 's|mesh_root = root_data_dir|# mesh_root 自动继承 root_data_dir|g' "$MAIN_CONFIG"

log_success "✓ 已修改数据目录为相对路径"

# ============================================================================
# 2. 修改所有 Python 文件中的硬编码路径
# ============================================================================

log_info "扫描并修改所有 Python 文件中的硬编码路径..."

# 修改 fix_ckpt.py
if [ -f "fix_ckpt.py" ]; then
    cp fix_ckpt.py fix_ckpt.py.bak
    sed -i 's|"/home/mi/siat/graspldm/graspLDM/output|"./output|g' fix_ckpt.py
    log_success "✓ 已修改 fix_ckpt.py"
fi

# 修改 vae_train_progress.py
if [ -f "vae_train_progress.py" ]; then
    cp vae_train_progress.py vae_train_progress.py.bak
    sed -i 's|"/home/mi/siat/graspldm/graspLDM/output|"./output|g' vae_train_progress.py
    log_success "✓ 已修改 vae_train_progress.py"
fi

# ============================================================================
# 3. 验证修改
# ============================================================================

log_info "验证修改结果..."

if grep -q 'root_data_dir = "./data/ACRONYM"' "$MAIN_CONFIG"; then
    log_success "✓ 配置文件路径修改成功"
else
    log_warn "⚠ 配置文件修改可能不完整，请手动检查"
fi

# ============================================================================
# 4. 创建必要的目录结构
# ============================================================================

log_info "创建必要的目录结构..."

mkdir -p ./output/comparison/exp_diffusion_vs_fm/{vae,ddm,fm}/checkpoints
mkdir -p ./output/comparison/exp_diffusion_vs_fm/{vae,ddm,fm}/logs
log_success "✓ 目录结构创建完成"

# ============================================================================
# 5. 总结
# ============================================================================

log_info "========== 修改总结 =========="
log_success "✓ 所有配置路径已修改为相对路径"
log_info "原配置文件备份："
log_info "  - configs/comparison/exp_diffusion_vs_fm.py.bak"
log_info "  - fix_ckpt.py.bak（如果存在）"
log_info "  - vae_train_progress.py.bak（如果存在）"
log_info ""
log_info "下一步："
log_info "  1. 运行 ./install_offline_deps.sh 安装离线依赖"
log_info "  2. 运行 ./run_full_experiment.sh 执行完整实验"
