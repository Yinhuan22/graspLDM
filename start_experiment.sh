#!/bin/bash

# ============================================================================
# graspLDM 一键启动脚本 - 快速版本
# 功能：一键启动完整的对比实验流程，包含所有检查和日志
# ============================================================================

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 获取项目根目录
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║              graspLDM 全流程对比实验一键启动脚本                           ║"
echo "║                  VAE → Diffusion → Flow Matching → 评估                     ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

# 检查脚本是否存在
if [ ! -f "${PROJECT_ROOT}/run_full_comparison_experiment.sh" ]; then
    echo -e "${YELLOW}⚠ 错误：找不到 run_full_comparison_experiment.sh${NC}"
    echo "请确保在 graspLDM 项目根目录运行此脚本"
    exit 1
fi

# 赋予执行权限
chmod +x "${PROJECT_ROOT}/run_full_comparison_experiment.sh"

# 显示选项说明
echo -e "${BLUE}=== 实验选项 ===${NC}\n"
echo "1. 运行完整流程（推荐）"
echo "   用时：36-74 小时（RTX 4090）"
echo ""
echo "2. 跳过 VAE，仅运行 Diffusion 和 Flow Matching"
echo "   用时：24-48 小时"
echo ""
echo "3. 仅运行对比评估（假设模型已训练）"
echo "   用时：1-2 小时"
echo ""
echo "4. 自定义参数运行"
echo ""
echo "0. 退出"
echo ""

read -p "请选择选项（0-4）: " choice

case $choice in
    1)
        echo -e "\n${GREEN}启动完整流程...${NC}\n"
        "${PROJECT_ROOT}/run_full_comparison_experiment.sh"
        ;;
    2)
        echo -e "\n${GREEN}启动 Diffusion 和 Flow Matching（跳过 VAE）...${NC}\n"
        "${PROJECT_ROOT}/run_full_comparison_experiment.sh" --skip-vae
        ;;
    3)
        echo -e "\n${GREEN}启动对比评估（仅评估）...${NC}\n"
        "${PROJECT_ROOT}/run_full_comparison_experiment.sh" --skip-vae --skip-diffusion --skip-fm
        ;;
    4)
        echo -e "\n${BLUE}=== 高级选项 ===${NC}\n"
        echo "示例命令："
        echo "  # 使用 2 个 GPU，批处理大小 64"
        echo "  ./run_full_comparison_experiment.sh --num-gpus 2 --batch-size 64"
        echo ""
        echo "  # 启用调试模式"
        echo "  ./run_full_comparison_experiment.sh --debug"
        echo ""
        echo "  # 查看所有选项"
        echo "  ./run_full_comparison_experiment.sh --help"
        echo ""
        read -p "请输入命令（不包括前缀 ./run_full_comparison_experiment.sh）: " args
        echo -e "\n${GREEN}启动自定义参数流程...${NC}\n"
        "${PROJECT_ROOT}/run_full_comparison_experiment.sh" $args
        ;;
    0)
        echo -e "\n${YELLOW}已退出${NC}"
        exit 0
        ;;
    *)
        echo -e "\n${YELLOW}无效选项${NC}"
        exit 1
        ;;
esac

# 实验完成
echo -e "\n${GREEN}"
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                   ✅ 实验流程已启动！                                      ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "\n${BLUE}═══ 查看进度 ══════════════════════════════════════════════════════${NC}"
echo "实时查看日志："
echo "  tail -f ./output/logs/full_experiment_*.log"
echo ""
echo "使用 TensorBoard 查看训练曲线："
echo "  tensorboard --logdir ./output/comparison/exp_diffusion_vs_fm/logs"
echo ""
echo "监控 GPU 使用："
echo "  watch -n 1 nvidia-smi"
echo -e "\n${BLUE}════════════════════════════════════════════════════════════════════${NC}\n"
