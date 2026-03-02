#!/bin/bash

##############################################################################
# graspLDM 结果打包下载脚本
#
# 功能：将对比实验结果打包为压缩文件，方便下载到本地
#
# 用法：
#   chmod +x package_results.sh
#   ./package_results.sh
#
# 生成文件：
#   - graspldm_results_full_TIMESTAMP.tar.gz      (完整结果，含日志)
#   - graspldm_results_table_viz_TIMESTAMP.tar.gz (轻量级，仅表格和图片)
#   - graspldm_tensorboard_logs_TIMESTAMP.tar.gz  (TensorBoard 日志)
#
##############################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 获取项目根目录
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PACKAGE_DIR="$PROJECT_ROOT/output/packages"

# 日志文件
LOG_FILE="$PACKAGE_DIR/package_results_$TIMESTAMP.log"

# 日志函数
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

# 打印标题
print_title() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  graspLDM 结果打包脚本                                    ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 创建日志目录
mkdir -p "$PACKAGE_DIR"

# 开始
print_title 2>&1 | tee -a "$LOG_FILE"

log_info "项目根目录: $PROJECT_ROOT"
log_info "输出目录: $PACKAGE_DIR"
log_info "时间戳: $TIMESTAMP"
log_info "日志文件: $LOG_FILE"
echo ""

# 检查结果目录是否存在
log_info "检查结果目录..."

RESULTS_DIR="$PROJECT_ROOT/output/comparison/exp_diffusion_vs_fm"

if [ ! -d "$RESULTS_DIR" ]; then
    log_error "结果目录不存在: $RESULTS_DIR"
    log_error "请先运行: ./run_full_comparison_experiment.sh"
    exit 1
fi

log_success "结果目录已找到"
echo ""

# 检查是否至少有一个子目录
if [ -z "$(find $RESULTS_DIR -mindepth 1 -maxdepth 1 -type d)" ]; then
    log_warning "结果目录为空，可能还未生成任何训练输出"
fi

# 1. 打包完整结果（包含日志）
print_status "打包 1: 完整结果（含日志）" "1/3"

FULL_PACKAGE="$PACKAGE_DIR/graspldm_results_full_$TIMESTAMP.tar.gz"

if tar -czf "$FULL_PACKAGE" \
    -C "$PROJECT_ROOT" \
    output/comparison/exp_diffusion_vs_fm/comparison_results \
    output/logs 2>&1 | tee -a "$LOG_FILE"; then
    
    FULL_SIZE=$(du -h "$FULL_PACKAGE" | cut -f1)
    log_success "完全结果打包完成"
    log_info "文件大小: $FULL_SIZE"
    log_info "文件路径: $FULL_PACKAGE"
else
    log_warning "打包失败或部分失败（可能是某些目录不存在）"
    log_warning "继续下一步..."
fi

echo ""

# 2. 打包轻量级结果（仅表格和图片）
print_status "打包 2: 轻量级结果（表格+图片）" "2/3"

LIGHT_PACKAGE="$PACKAGE_DIR/graspldm_results_table_viz_$TIMESTAMP.tar.gz"

# 检查比较结果目录
COMPARISON_RESULTS="$RESULTS_DIR/comparison_results"

if [ -d "$COMPARISON_RESULTS" ]; then
    if tar -czf "$LIGHT_PACKAGE" \
        -C "$COMPARISON_RESULTS" \
        . 2>&1 | tee -a "$LOG_FILE"; then
        
        LIGHT_SIZE=$(du -h "$LIGHT_PACKAGE" | cut -f1)
        log_success "轻量级结果打包完成"
        log_info "文件大小: $LIGHT_SIZE"
        log_info "文件路径: $LIGHT_PACKAGE"
    else
        log_warning "轻量级打包失败"
    fi
else
    log_warning "比较结果目录不存在: $COMPARISON_RESULTS"
fi

echo ""

# 3. 打包 TensorBoard 日志
print_status "打包 3: TensorBoard 日志" "3/3"

TB_PACKAGE="$PACKAGE_DIR/graspldm_tensorboard_logs_$TIMESTAMP.tar.gz"

# 检查日志目录是否存在
TEMP_DIR=$(mktemp -d)
TB_LOGS_EXIST=false

for model_dir in vae ddm fm; do
    if [ -d "$RESULTS_DIR/$model_dir/logs" ]; then
        cp -r "$RESULTS_DIR/$model_dir/logs" "$TEMP_DIR/$model_dir" 2>/dev/null || true
        TB_LOGS_EXIST=true
    fi
done

if [ "$TB_LOGS_EXIST" = true ]; then
    if tar -czf "$TB_PACKAGE" \
        -C "$TEMP_DIR" \
        . 2>&1 | tee -a "$LOG_FILE"; then
        
        TB_SIZE=$(du -h "$TB_PACKAGE" | cut -f1)
        log_success "TensorBoard 日志打包完成"
        log_info "文件大小: $TB_SIZE"
        log_info "文件路径: $TB_PACKAGE"
    else
        log_warning "TensorBoard 日志打包失败"
    fi
else
    log_warning "未找到 TensorBoard 日志目录"
fi

# 清理临时目录
rm -rf "$TEMP_DIR"

echo ""

# 显示完成摘要
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ 打包完成                                              ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

log_info "输出目录: $PACKAGE_DIR"
log_info "文件列表:"

echo ""
for file in "$PACKAGE_DIR"/*.tar.gz; do
    if [ -f "$file" ]; then
        SIZE=$(du -h "$file" | cut -f1)
        FILENAME=$(basename "$file")
        log_info "  📦 $FILENAME ($SIZE)"
    fi
done

echo ""
log_info "下载提示："
log_info "  使用 SCP 下载到本地："
log_info "  scp -r user@webide_host:$PACKAGE_DIR ~/downloads/"
log_info ""
log_info "  或者下载单个文件："
log_info "  scp user@webide_host:$PACKAGE_DIR/*.tar.gz ~/"

echo ""
log_info "验证文件完整性："
log_info "  tar -tzf <filename>.tar.gz | head -20"

echo ""
log_info "提取压缩包："
log_info "  tar -xzf <filename>.tar.gz"

echo ""
log_success "所有操作已完成！"
log_info "完整日志: $LOG_FILE"

echo ""

##############################################################################
# 辅助函数
##############################################################################

print_status() {
    local message=$1
    local progress=$2
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$message ($progress)${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}
