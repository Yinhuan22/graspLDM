#!/bin/bash

# ============================================================================
# graspLDM 全流程对比实验一键运行脚本
# ============================================================================
# 功能：按顺序执行 VAE→Diffusion→Flow Matching 三个模型的训练和对比评估
# 特性：包含错误处理、日志保存、GPU 检查、目录结构验证
# ============================================================================

set -e  # 任何命令失败时立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

# ============================================================================
# 配置变量
# ============================================================================

# 获取项目根目录
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOG_DIR="${PROJECT_ROOT}/output/logs"
CHECKPOINT_DIR="${PROJECT_ROOT}/output/comparison"
RESULTS_DIR="${PROJECT_ROOT}/output/results"

# 日志文件
LOG_FILE="${LOG_DIR}/full_experiment_$(date +%Y%m%d_%H%M%S).log"
VAE_LOG="${LOG_DIR}/01_vae_training_$(date +%Y%m%d_%H%M%S).log"
DIFFUSION_LOG="${LOG_DIR}/02_diffusion_training_$(date +%Y%m%d_%H%M%S).log"
FM_LOG="${LOG_DIR}/03_flow_matching_training_$(date +%Y%m%d_%H%M%S).log"
EVAL_LOG="${LOG_DIR}/04_evaluation_$(date +%Y%m%d_%H%M%S).log"

# 配置文件路径
VAE_CONFIG="${PROJECT_ROOT}/configs/comparison/exp_diffusion_vs_fm.py"
DIFFUSION_CONFIG="${PROJECT_ROOT}/configs/comparison/exp_diffusion_vs_fm.py"
FM_CONFIG="${PROJECT_ROOT}/configs/comparison/exp_diffusion_vs_fm.py"
EVAL_CONFIG="${PROJECT_ROOT}/configs/comparison/exp_diffusion_vs_fm.py"

# 训练参数
NUM_GPUS=1
BATCH_SIZE=32
SKIP_VAE=false
SKIP_DIFFUSION=false
SKIP_FM=false
SKIP_EVAL=false
DEBUG=false

# ============================================================================
# 日志和输出函数
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_step() {
    echo -e "\n${CYAN}═════════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}[STEP]${NC} $1" | tee -a "$LOG_FILE"
    echo -e "${CYAN}═════════════════════════════════════════════════════════${NC}\n" | tee -a "$LOG_FILE"
}

# ============================================================================
# 辅助函数
# ============================================================================

print_header() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════════════════╗"
    echo "║           graspLDM 全流程对比实验一键运行脚本                               ║"
    echo "║        VAE 预训练 → Diffusion → Flow Matching → 对比评估                    ║"
    echo "╚════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-vae)
                SKIP_VAE=true
                log_info "将跳过 VAE 预训练"
                shift
                ;;
            --skip-diffusion)
                SKIP_DIFFUSION=true
                log_info "将跳过 Diffusion 训练"
                shift
                ;;
            --skip-fm)
                SKIP_FM=true
                log_info "将跳过 Flow Matching 训练"
                shift
                ;;
            --skip-eval)
                SKIP_EVAL=true
                log_info "将跳过对比评估"
                shift
                ;;
            --num-gpus)
                NUM_GPUS="$2"
                log_info "GPU 数量: $NUM_GPUS"
                shift 2
                ;;
            --batch-size)
                BATCH_SIZE="$2"
                log_info "批处理大小: $BATCH_SIZE"
                shift 2
                ;;
            --debug)
                DEBUG=true
                log_info "调试模式已启用"
                shift
                ;;
            -h|--help)
                print_usage
                exit 0
                ;;
            *)
                log_error "未知参数: $1"
                print_usage
                exit 1
                ;;
        esac
    done
}

print_usage() {
    cat << 'EOF'
使用方法：
  ./run_full_comparison_experiment.sh [选项]

选项：
  --skip-vae              跳过 VAE 预训练
  --skip-diffusion        跳过 Diffusion 训练
  --skip-fm               跳过 Flow Matching 训练
  --skip-eval             跳过对比评估
  --num-gpus N            指定使用的 GPU 数量（默认：1）
  --batch-size N          指定批处理大小（默认：32）
  --debug                 启用调试模式
  -h, --help              显示此帮助信息

示例：
  # 运行完整流程
  ./run_full_comparison_experiment.sh

  # 跳过 VAE 预训练，直接运行 Diffusion
  ./run_full_comparison_experiment.sh --skip-vae

  # 使用 2 个 GPU，批处理大小为 64
  ./run_full_comparison_experiment.sh --num-gpus 2 --batch-size 64

  # 仅运行评估
  ./run_full_comparison_experiment.sh --skip-vae --skip-diffusion --skip-fm
EOF
}

# ============================================================================
# 检查函数
# ============================================================================

check_project_structure() {
    log_step "检查项目目录结构"
    
    local missing_dirs=()
    local missing_files=()
    
    # 检查必要的目录
    local required_dirs=(
        "configs"
        "tools"
        "grasp_ldm"
        "data"
        "data/ACRONYM"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "${PROJECT_ROOT}/${dir}" ]; then
            missing_dirs+=("$dir")
        else
            log_success "✓ 目录存在: $dir"
        fi
    done
    
    # 检查必要的文件
    local required_files=(
        "tools/train_generator.py"
        "tools/evaluate.py"
        "configs/comparison/exp_diffusion_vs_fm.py"
        "setup.py"
        "requirements.txt"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "${PROJECT_ROOT}/${file}" ]; then
            missing_files+=("$file")
        else
            log_success "✓ 文件存在: $file"
        fi
    done
    
    # 报告缺失的文件和目录
    if [ ${#missing_dirs[@]} -gt 0 ] || [ ${#missing_files[@]} -gt 0 ]; then
        log_error "项目结构检查失败！"
        if [ ${#missing_dirs[@]} -gt 0 ]; then
            log_error "缺失的目录: ${missing_dirs[@]}"
        fi
        if [ ${#missing_files[@]} -gt 0 ]; then
            log_error "缺失的文件: ${missing_files[@]}"
        fi
        return 1
    fi
    
    log_success "项目目录结构检查通过！"
    return 0
}

check_gpu_availability() {
    log_step "检查 GPU 可用性"
    
    # 尝试导入 PyTorch 并检查 CUDA
    python3 << 'PYTHON_EOF'
import torch

print("[INFO] PyTorch 版本:", torch.__version__)
print("[INFO] CUDA 可用:", torch.cuda.is_available())

if torch.cuda.is_available():
    print("[SUCCESS] ✓ CUDA 已启用")
    print("[INFO] GPU 设备数量:", torch.cuda.device_count())
    for i in range(torch.cuda.device_count()):
        print(f"[INFO]   GPU {i}: {torch.cuda.get_device_name(i)}")
        print(f"[INFO]   显存: {torch.cuda.get_device_properties(i).total_memory / 1e9:.2f} GB")
else:
    print("[WARNING] ⚠ CUDA 不可用，将使用 CPU（训练会很慢）")

PYTHON_EOF
    
    if [ $? -ne 0 ]; then
        log_warning "GPU 检查出错，继续执行..."
    fi
}

create_log_directories() {
    log_step "创建日志目录"
    
    mkdir -p "$LOG_DIR"
    log_success "✓ 日志目录已创建: $LOG_DIR"
    
    mkdir -p "$CHECKPOINT_DIR"
    log_success "✓ Checkpoint 目录已创建: $CHECKPOINT_DIR"
    
    mkdir -p "$RESULTS_DIR"
    log_success "✓ 结果目录已创建: $RESULTS_DIR"
}

# ============================================================================
# 训练函数
# ============================================================================

train_vae() {
    log_step "第 1/4 步：VAE 预训练"
    
    if [ "$SKIP_VAE" = true ]; then
        log_warning "跳过 VAE 预训练（使用 --skip-vae 指定）"
        return 0
    fi
    
    log_info "启动 VAE 预训练..."
    log_info "配置文件: $VAE_CONFIG"
    log_info "日志文件: $VAE_LOG"
    
    if [ "$DEBUG" = true ]; then
        log_info "调试模式：打印完整命令"
        echo "python3 ${PROJECT_ROOT}/tools/train_generator.py \\"
        echo "  --config ${VAE_CONFIG} \\"
        echo "  --model vae \\"
        echo "  --num-gpus ${NUM_GPUS} \\"
        echo "  --batch-size ${BATCH_SIZE}"
    fi
    
    # 执行 VAE 训练
    if python3 "${PROJECT_ROOT}/tools/train_generator.py" \
        --config "$VAE_CONFIG" \
        --model vae \
        --num-gpus "$NUM_GPUS" \
        --batch-size "$BATCH_SIZE" \
        2>&1 | tee -a "$VAE_LOG"; then
        log_success "VAE 预训练完成！"
        return 0
    else
        log_error "VAE 预训练失败！"
        log_error "请查看日志: $VAE_LOG"
        return 1
    fi
}

train_diffusion() {
    log_step "第 2/4 步：Diffusion 模型训练"
    
    if [ "$SKIP_DIFFUSION" = true ]; then
        log_warning "跳过 Diffusion 训练（使用 --skip-diffusion 指定）"
        return 0
    fi
    
    log_info "启动 Diffusion 训练..."
    log_info "配置文件: $DIFFUSION_CONFIG"
    log_info "日志文件: $DIFFUSION_LOG"
    
    if [ "$DEBUG" = true ]; then
        log_info "调试模式：打印完整命令"
        echo "python3 ${PROJECT_ROOT}/tools/train_generator.py \\"
        echo "  --config ${DIFFUSION_CONFIG} \\"
        echo "  --model ddm \\"
        echo "  --num-gpus ${NUM_GPUS} \\"
        echo "  --batch-size ${BATCH_SIZE}"
    fi
    
    # 执行 Diffusion 训练
    if python3 "${PROJECT_ROOT}/tools/train_generator.py" \
        --config "$DIFFUSION_CONFIG" \
        --model ddm \
        --num-gpus "$NUM_GPUS" \
        --batch-size "$BATCH_SIZE" \
        2>&1 | tee -a "$DIFFUSION_LOG"; then
        log_success "Diffusion 训练完成！"
        return 0
    else
        log_error "Diffusion 训练失败！"
        log_error "请查看日志: $DIFFUSION_LOG"
        return 1
    fi
}

train_flow_matching() {
    log_step "第 3/4 步：Flow Matching 模型训练"
    
    if [ "$SKIP_FM" = true ]; then
        log_warning "跳过 Flow Matching 训练（使用 --skip-fm 指定）"
        return 0
    fi
    
    log_info "启动 Flow Matching 训练..."
    log_info "配置文件: $FM_CONFIG"
    log_info "日志文件: $FM_LOG"
    
    if [ "$DEBUG" = true ]; then
        log_info "调试模式：打印完整命令"
        echo "python3 ${PROJECT_ROOT}/tools/train_generator.py \\"
        echo "  --config ${FM_CONFIG} \\"
        echo "  --model fm \\"
        echo "  --num-gpus ${NUM_GPUS} \\"
        echo "  --batch-size ${BATCH_SIZE}"
    fi
    
    # 执行 Flow Matching 训练
    if python3 "${PROJECT_ROOT}/tools/train_generator.py" \
        --config "$FM_CONFIG" \
        --model fm \
        --num-gpus "$NUM_GPUS" \
        --batch-size "$BATCH_SIZE" \
        2>&1 | tee -a "$FM_LOG"; then
        log_success "Flow Matching 训练完成！"
        return 0
    else
        log_error "Flow Matching 训练失败！"
        log_error "请查看日志: $FM_LOG"
        return 1
    fi
}

evaluate_comparison() {
    log_step "第 4/4 步：对比实验评估"
    
    if [ "$SKIP_EVAL" = true ]; then
        log_warning "跳过对比评估（使用 --skip-eval 指定）"
        return 0
    fi
    
    log_info "启动对比实验评估..."
    log_info "配置文件: $EVAL_CONFIG"
    log_info "日志文件: $EVAL_LOG"
    
    if [ "$DEBUG" = true ]; then
        log_info "调试模式：打印完整命令"
        echo "python3 ${PROJECT_ROOT}/tools/evaluate.py \\"
        echo "  --config ${EVAL_CONFIG}"
    fi
    
    # 执行对比评估
    if python3 "${PROJECT_ROOT}/tools/evaluate.py" \
        --config "$EVAL_CONFIG" \
        2>&1 | tee -a "$EVAL_LOG"; then
        log_success "对比实验评估完成！"
        return 0
    else
        log_error "对比实验评估失败！"
        log_error "请查看日志: $EVAL_LOG"
        return 1
    fi
}

# ============================================================================
# 结果输出函数
# ============================================================================

print_completion_summary() {
    log_step "全流程对比实验完成！"
    
    cat << 'EOF' | tee -a "$LOG_FILE"

╔════════════════════════════════════════════════════════════════════════════╗
║                    ✅ 全流程对比实验完成！                                ║
╚════════════════════════════════════════════════════════════════════════════╝

📊 实验结果位置
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 日志文件目录：
   ./output/logs/
   • full_experiment_*.log          - 完整实验日志
   • 01_vae_training_*.log          - VAE 预训练日志
   • 02_diffusion_training_*.log    - Diffusion 训练日志
   • 03_flow_matching_training_*.log - Flow Matching 训练日志
   • 04_evaluation_*.log            - 对比评估日志

📁 Checkpoint 目录：
   ./output/comparison/exp_diffusion_vs_fm/
   ├─ vae/checkpoints/              - VAE 模型权重
   ├─ ddm/checkpoints/              - Diffusion 模型权重
   ├─ fm/checkpoints/               - Flow Matching 模型权重
   └─ logs/                          - TensorBoard 日志

📁 评估结果目录：
   ./output/results/
   • comparison_table.csv           - 对比结果表格
   • comparison_plots/              - 对比可视化图表
   • evaluation_report.json         - 评估报告

🔍 查看结果的方式
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1️⃣  查看实验日志：
   # 查看完整日志
   tail -f ./output/logs/full_experiment_*.log

   # 查看特定模型的训练日志
   tail -f ./output/logs/01_vae_training_*.log
   tail -f ./output/logs/02_diffusion_training_*.log
   tail -f ./output/logs/03_flow_matching_training_*.log

2️⃣  使用 TensorBoard 查看训练曲线：
   tensorboard --logdir ./output/comparison/exp_diffusion_vs_fm/logs

3️⃣  查看对比结果表格：
   cat ./output/results/comparison_table.csv

4️⃣  查看模型权重信息：
   ls -lh ./output/comparison/exp_diffusion_vs_fm/*/checkpoints/

⏱️  估计实验时间
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

每个模型（180000 步）的训练时间：
  • VAE 预训练: ~12-24 小时
  • Diffusion 训练: ~12-24 小时
  • Flow Matching 训练: ~12-24 小时
  • 对比评估: ~1-2 小时

总计：~37-74 小时（RTX 4090 GPU）

💡 故障排除
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

如果训练失败：
  1. 检查日志文件找出错误原因
  2. 查看 GPU 显存是否足够（RTX 4090 推荐）
  3. 检查数据集路径是否正确
  4. 确认所有依赖包已正确安装

重新运行特定模型的训练：
  # 仅运行 Diffusion
  ./run_full_comparison_experiment.sh --skip-vae --skip-fm --skip-eval

  # 仅运行评估
  ./run_full_comparison_experiment.sh --skip-vae --skip-diffusion --skip-fm

EOF
}

print_error_summary() {
    log_error "实验执行失败！"
    
    cat << 'EOF' | tee -a "$LOG_FILE"

╔════════════════════════════════════════════════════════════════════════════╗
║                    ❌ 实验执行失败                                        ║
╚════════════════════════════════════════════════════════════════════════════╝

📋 故障排查步骤
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. 查看最新的日志文件：
   tail -n 50 ./output/logs/full_experiment_*.log

2. 检查 GPU 状态：
   nvidia-smi

3. 验证数据集完整性：
   find ./data/ACRONYM/grasps -name "*.h5" | wc -l
   # 应该显示 8837 个文件

4. 检查依赖包：
   python3 -c "import torch; print(torch.__version__)"
   python3 -c "import pytorch_lightning; print(pytorch_lightning.__version__)"

5. 重新运行脚本（使用 --debug 选项查看详细信息）：
   ./run_full_comparison_experiment.sh --debug

EOF
}

# ============================================================================
# 主函数
# ============================================================================

main() {
    # 打印头部
    print_header
    
    # 记录开始时间
    START_TIME=$(date +%s)
    log_info "实验开始时间: $(date)"
    
    # 解析命令行参数
    parse_arguments "$@"
    
    # 创建日志目录
    create_log_directories
    
    # 项目结构检查
    if ! check_project_structure; then
        log_error "项目结构检查失败，无法继续"
        exit 1
    fi
    
    # GPU 可用性检查
    check_gpu_availability
    
    # 运行全流程训练和评估
    if ! train_vae; then
        print_error_summary
        exit 1
    fi
    
    if ! train_diffusion; then
        print_error_summary
        exit 1
    fi
    
    if ! train_flow_matching; then
        print_error_summary
        exit 1
    fi
    
    if ! evaluate_comparison; then
        print_error_summary
        exit 1
    fi
    
    # 计算执行时间
    END_TIME=$(date +%s)
    ELAPSED_TIME=$((END_TIME - START_TIME))
    HOURS=$((ELAPSED_TIME / 3600))
    MINUTES=$(((ELAPSED_TIME % 3600) / 60))
    SECONDS=$((ELAPSED_TIME % 60))
    
    log_info "实验完成时间: $(date)"
    log_info "总耗时: ${HOURS}h ${MINUTES}m ${SECONDS}s"
    
    # 输出完成摘要
    print_completion_summary
    
    # 正常退出
    exit 0
}

# ============================================================================
# 脚本入口
# ============================================================================

main "$@"
