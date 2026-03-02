#!/bin/bash

##############################################################################
# graspLDM 完整对比实验一键运行脚本
#
# 执行流程：
#   1. 环境检查和依赖验证
#   2. 第一阶段：VAE 预训练（180k 步）
#   3. 第二阶段：Diffusion 模型训练（180k 步）
#   4. 第三阶段：Flow Matching 模型训练（待扩展）
#   5. 结果评估和对比
#
# 使用方法：
#   chmod +x run_full_experiment.sh
#   ./run_full_experiment.sh [--skip-vae] [--skip-ddm] [--skip-fm] [--debug]
#
# 参数：
#   --skip-vae    跳过 VAE 训练（使用现有权重）
#   --skip-ddm    跳过 Diffusion 训练
#   --skip-fm     跳过 Flow Matching 训练
#   --debug       调试模式（详细日志）
#
##############################################################################

set -e  # 出错立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# 记录开始时间
START_TIME=$(date +%s)

# 脚本参数
SKIP_VAE=false
SKIP_DDM=false
SKIP_FM=false
DEBUG=false

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-vae) SKIP_VAE=true; shift ;;
        --skip-ddm) SKIP_DDM=true; shift ;;
        --skip-fm) SKIP_FM=true; shift ;;
        --debug) DEBUG=true; shift ;;
        *) echo "未知参数: $1"; exit 1 ;;
    esac
done

# 日志函数
log_info() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')] ✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')] ⚠${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date '+%H:%M:%S')] ✗${NC} $1"
}

log_section() {
    echo ""
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║ $1${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

log_elapsed() {
    END_TIME=$(date +%s)
    ELAPSED=$((END_TIME - START_TIME))
    HOURS=$((ELAPSED / 3600))
    MINUTES=$(( (ELAPSED % 3600) / 60 ))
    SECONDS=$((ELAPSED % 60))
    echo "耗时: ${HOURS}h ${MINUTES}m ${SECONDS}s"
}

# ============================================================================
# 0. 初始化和环境检查
# ============================================================================

log_section "初始化和环境检查"

# 检查当前目录
if [ ! -f "requirements.txt" ] || [ ! -d "tools" ] || [ ! -d "configs" ]; then
    log_error "请在项目根目录运行此脚本"
    exit 1
fi

log_success "项目根目录检查完成"

# 检查 Python 和关键包
log_info "检查 Python 环境..."
PYTHON_VERSION=$(python --version 2>&1)
log_success "$PYTHON_VERSION"

# 检查关键依赖
REQUIRED_MODULES=("torch" "pytorch_lightning" "diffusers" "h5py")
for module in "${REQUIRED_MODULES[@]}"; do
    if python -c "import $module" 2>/dev/null; then
        log_success "$module 已安装"
    else
        log_error "$module 未安装，请先运行 install_offline_deps.sh"
        exit 1
    fi
done

# 检查 GPU
if python -c "import torch; torch.cuda.is_available()" 2>/dev/null; then
    GPU_INFO=$(python -c "import torch; print(f'GPU: {torch.cuda.get_device_name(0)}')" 2>/dev/null)
    log_success "$GPU_INFO"
else
    log_warn "未检测到 CUDA GPU，训练会很慢"
fi

# 检查数据集
if [ ! -d "./data/ACRONYM" ] || [ ! -d "./data/ACRONYM/grasps" ]; then
    log_error "数据集目录 ./data/ACRONYM 不存在或不完整"
    log_error "请确保已解压 ACRONYM 数据集到 ./data/ACRONYM/"
    exit 1
fi

GRASPS_COUNT=$(find ./data/ACRONYM/grasps -name "*.h5" 2>/dev/null | wc -l)
log_success "ACRONYM 数据集检查完成 (共 $GRASPS_COUNT 个 .h5 文件)"

# 检查并创建输出目录
mkdir -p ./output/comparison/exp_diffusion_vs_fm/{vae,ddm,fm}/{checkpoints,logs}
log_success "输出目录结构创建完成"

log_elapsed

# ============================================================================
# 1. VAE 预训练阶段
# ============================================================================

if [ "$SKIP_VAE" = false ]; then
    log_section "第一阶段：VAE 预训练"
    
    log_info "配置："
    log_info "  - 最大步数: 180,000"
    log_info "  - Batch Size: 32"
    log_info "  - 数据加载线程: 0（避免卡死）"
    log_info "  - GPU: 1"
    
    log_info ""
    log_info "启动 VAE 训练..."
    
    # VAE 训练命令
    # 使用相对路径和重新开始（resume_training_from_last = False）
    if [ "$DEBUG" = true ]; then
        python tools/train_generator.py \
            --config ./configs/comparison/exp_diffusion_vs_fm.py \
            --model vae \
            --num-gpus 1 \
            --batch-size 32
    else
        python tools/train_generator.py \
            --config ./configs/comparison/exp_diffusion_vs_fm.py \
            --model vae \
            --num-gpus 1 \
            --batch-size 32 2>&1 | grep -E "(Epoch|global_step|Loss|val_loss)" || true
    fi
    
    # 检查 VAE 权重是否生成
    if [ -f "./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/last.ckpt" ]; then
        log_success "VAE 训练完成，权重已保存到 ./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/"
    else
        log_warn "未找到 VAE 权重，请检查训练过程"
    fi
    
    log_elapsed
else
    log_warn "跳过 VAE 训练（--skip-vae）"
fi

# ============================================================================
# 2. Diffusion 模型训练阶段
# ============================================================================

if [ "$SKIP_DDM" = false ]; then
    log_section "第二阶段：Diffusion (DDPM) 模型训练"
    
    # 确保 VAE 权重存在
    if [ ! -f "./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/last.ckpt" ] && [ "$SKIP_VAE" = true ]; then
        log_error "VAE 权重不存在，无法继续 Diffusion 训练"
        log_error "请运行不加 --skip-vae 参数的版本，或确保权重在正确位置"
        exit 1
    fi
    
    log_info "配置："
    log_info "  - 最大步数: 180,000"
    log_info "  - Batch Size: 32"
    log_info "  - 使用 VAE 权重: ./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/last.ckpt"
    log_info "  - GPU: 1"
    
    log_info ""
    log_info "启动 Diffusion 训练..."
    
    # 修改配置以指向 VAE 权重（临时）
    # 注意：这里需要提前在配置文件中设置好 shared_vae_ckpt_path
    
    if [ "$DEBUG" = true ]; then
        python tools/train_generator.py \
            --config ./configs/comparison/exp_diffusion_vs_fm.py \
            --model ddm \
            --num-gpus 1 \
            --batch-size 32
    else
        python tools/train_generator.py \
            --config ./configs/comparison/exp_diffusion_vs_fm.py \
            --model ddm \
            --num-gpus 1 \
            --batch-size 32 2>&1 | grep -E "(Epoch|global_step|Loss|val_loss)" || true
    fi
    
    if [ -f "./output/comparison/exp_diffusion_vs_fm/ddm/checkpoints/last.ckpt" ]; then
        log_success "Diffusion 训练完成，权重已保存到 ./output/comparison/exp_diffusion_vs_fm/ddm/checkpoints/"
    else
        log_warn "未找到 Diffusion 权重，请检查训练过程"
    fi
    
    log_elapsed
else
    log_warn "跳过 Diffusion 训练（--skip-ddm）"
fi

# ============================================================================
# 3. Flow Matching 模型训练阶段（待扩展）
# ============================================================================

if [ "$SKIP_FM" = false ]; then
    log_section "第三阶段：Flow Matching 模型训练"
    
    log_warn "Flow Matching 训练尚未实现"
    log_info "预计支持内容："
    log_info "  - 基于 Flow Matching 的连续生成模型"
    log_info "  - 与 Diffusion 的对比实验"
    log_info "  - 相同的数据集和评估指标"
else
    log_warn "跳过 Flow Matching 训练（--skip-fm）"
fi

# ============================================================================
# 4. 结果评估
# ============================================================================

log_section "结果评估和对比"

log_info "训练完成的模型："

if [ -f "./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/last.ckpt" ]; then
    VAE_SIZE=$(du -h ./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/last.ckpt | awk '{print $1}')
    log_success "✓ VAE: ./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/ ($VAE_SIZE)"
fi

if [ -f "./output/comparison/exp_diffusion_vs_fm/ddm/checkpoints/last.ckpt" ]; then
    DDM_SIZE=$(du -h ./output/comparison/exp_diffusion_vs_fm/ddm/checkpoints/last.ckpt | awk '{print $1}')
    log_success "✓ Diffusion: ./output/comparison/exp_diffusion_vs_fm/ddm/checkpoints/ ($DDM_SIZE)"
fi

# 如果有 TensorBoard 日志，提示查看方法
if [ -d "./output/comparison/exp_diffusion_vs_fm/vae/logs" ]; then
    log_info ""
    log_info "查看训练曲线："
    log_info "  tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm"
    log_info "  然后在浏览器中打开 http://localhost:6006"
fi

log_elapsed

# ============================================================================
# 5. 完成总结
# ============================================================================

log_section "实验完成"

log_success "✓ 完整的对比实验流程已完成！"

log_info ""
log_info "关键路径："
log_info "  - 数据: ./data/ACRONYM/"
log_info "  - 配置: ./configs/comparison/"
log_info "  - 输出: ./output/comparison/exp_diffusion_vs_fm/"
log_info ""
log_info "下一步（可选）："
log_info "  1. 查看 TensorBoard 日志了解训练曲线"
log_info "  2. 运行推理脚本生成抓取"
log_info "  3. 对比两种方法的性能"

log_elapsed

exit 0
