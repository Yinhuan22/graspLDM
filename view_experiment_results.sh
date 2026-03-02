#!/bin/bash

# ============================================================================
# 实验结果查看脚本 - 简化版
# 功能：快速查看训练日志、checkpoint、对比结果
# ============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 获取项目根目录
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                    graspLDM 实验结果快速查看工具                           ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

echo "📋 快速命令菜单：\n"
echo "1. 查看完整实验日志（最后 50 行）"
echo "   tail -f ./output/logs/full_experiment_*.log"
echo ""
echo "2. 查看 VAE 训练日志"
echo "   tail -f ./output/logs/01_vae_training_*.log"
echo ""
echo "3. 查看 Diffusion 训练日志"
echo "   tail -f ./output/logs/02_diffusion_training_*.log"
echo ""
echo "4. 查看 Flow Matching 训练日志"
echo "   tail -f ./output/logs/03_flow_matching_training_*.log"
echo ""
echo "5. 启动 TensorBoard（查看训练曲线）"
echo "   tensorboard --logdir ./output/comparison/exp_diffusion_vs_fm/logs --port 6006"
echo ""
echo "6. 查看 Checkpoint 大小"
echo "   du -sh ./output/comparison/exp_diffusion_vs_fm/*/checkpoints/"
echo ""
echo "7. 查看对比结果"
echo "   cat ./output/results/comparison_table.csv"
echo ""
echo "8. 监控 GPU 使用"
echo "   watch -n 1 nvidia-smi"
echo ""
echo "9. 查看所有日志文件"
echo "   ls -lh ./output/logs/"
echo ""
echo "0. 退出"
echo ""

read -p "请选择命令（0-9）或直接输入命令: " choice

case $choice in
    1)
        echo ""
        tail -f "./output/logs/full_experiment_"*.log 2>/dev/null || echo "日志文件不存在"
        ;;
    2)
        echo ""
        tail -f "./output/logs/01_vae_training_"*.log 2>/dev/null || echo "VAE 日志文件不存在"
        ;;
    3)
        echo ""
        tail -f "./output/logs/02_diffusion_training_"*.log 2>/dev/null || echo "Diffusion 日志文件不存在"
        ;;
    4)
        echo ""
        tail -f "./output/logs/03_flow_matching_training_"*.log 2>/dev/null || echo "Flow Matching 日志文件不存在"
        ;;
    5)
        echo ""
        tensorboard --logdir "./output/comparison/exp_diffusion_vs_fm/logs" --port 6006 || echo "无法启动 TensorBoard"
        ;;
    6)
        echo ""
        du -sh "./output/comparison/exp_diffusion_vs_fm/*/checkpoints/" 2>/dev/null || echo "Checkpoint 目录不存在"
        ;;
    7)
        echo ""
        if [ -f "./output/results/comparison_table.csv" ]; then
            cat "./output/results/comparison_table.csv"
        else
            echo "对比结果文件不存在"
        fi
        ;;
    8)
        echo ""
        watch -n 1 nvidia-smi
        ;;
    9)
        echo ""
        ls -lh "./output/logs/" 2>/dev/null || echo "日志目录不存在"
        ;;
    0)
        echo "已退出"
        exit 0
        ;;
    *)
        if [ -n "$choice" ]; then
            echo "执行命令: $choice"
            echo ""
            eval "$choice"
        fi
        ;;
esac
