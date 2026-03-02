#!/bin/bash

##############################################################################
# graspLDM 实验结果查看脚本
#
# 用途：在无外网环境下查看和对比实验结果
# 
# 功能：
#   1. 显示训练进度和日志
#   2. 启动 TensorBoard 查看指标
#   3. 对比两种模型的训练曲线
#   4. 生成对比报告
#
# 使用方法：
#   chmod +x view_results.sh
#   ./view_results.sh [--tensorboard] [--compare] [--report]
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

# 参数处理
SHOW_TENSORBOARD=false
SHOW_COMPARE=false
GENERATE_REPORT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --tensorboard) SHOW_TENSORBOARD=true; shift ;;
        --compare) SHOW_COMPARE=true; shift ;;
        --report) GENERATE_REPORT=true; shift ;;
        --all) SHOW_TENSORBOARD=true; SHOW_COMPARE=true; GENERATE_REPORT=true; shift ;;
        *) echo "未知参数: $1"; exit 1 ;;
    esac
done

# 检查项目目录
if [ ! -d "./output/comparison/exp_diffusion_vs_fm" ]; then
    log_error "未找到实验输出目录，请先运行 run_full_experiment.sh"
    exit 1
fi

BASE_DIR="./output/comparison/exp_diffusion_vs_fm"

# ============================================================================
# 1. 显示训练进度
# ============================================================================

log_info "========== 实验结果概览 =========="

# VAE
if [ -d "$BASE_DIR/vae" ]; then
    log_info ""
    log_info "【VAE 预训练】"
    if [ -f "$BASE_DIR/vae/checkpoints/last.ckpt" ]; then
        log_success "✓ 最后检查点: $BASE_DIR/vae/checkpoints/last.ckpt"
        ls -lh "$BASE_DIR/vae/checkpoints/last.ckpt"
    fi
    
    if [ -f "$BASE_DIR/vae/checkpoints/best.ckpt" ]; then
        log_success "✓ 最佳检查点: $BASE_DIR/vae/checkpoints/best.ckpt"
        ls -lh "$BASE_DIR/vae/checkpoints/best.ckpt"
    fi
    
    CKPT_COUNT=$(find "$BASE_DIR/vae/checkpoints" -name "*.ckpt" 2>/dev/null | wc -l)
    log_info "  检查点总数: $CKPT_COUNT"
fi

# Diffusion
if [ -d "$BASE_DIR/ddm" ]; then
    log_info ""
    log_info "【Diffusion 模型训练】"
    if [ -f "$BASE_DIR/ddm/checkpoints/last.ckpt" ]; then
        log_success "✓ 最后检查点: $BASE_DIR/ddm/checkpoints/last.ckpt"
        ls -lh "$BASE_DIR/ddm/checkpoints/last.ckpt"
    fi
    
    if [ -f "$BASE_DIR/ddm/checkpoints/best.ckpt" ]; then
        log_success "✓ 最佳检查点: $BASE_DIR/ddm/checkpoints/best.ckpt"
        ls -lh "$BASE_DIR/ddm/checkpoints/best.ckpt"
    fi
    
    CKPT_COUNT=$(find "$BASE_DIR/ddm/checkpoints" -name "*.ckpt" 2>/dev/null | wc -l)
    log_info "  检查点总数: $CKPT_COUNT"
fi

# FM
if [ -d "$BASE_DIR/fm" ]; then
    log_info ""
    log_info "【Flow Matching 模型训练】"
    if [ -f "$BASE_DIR/fm/checkpoints/last.ckpt" ]; then
        log_success "✓ 最后检查点: $BASE_DIR/fm/checkpoints/last.ckpt"
        ls -lh "$BASE_DIR/fm/checkpoints/last.ckpt"
    else
        log_warn "⚠ 尚未开始或未完成"
    fi
fi

# ============================================================================
# 2. TensorBoard（如果指定）
# ============================================================================

if [ "$SHOW_TENSORBOARD" = true ]; then
    log_info ""
    log_info "========== 启动 TensorBoard =========="
    
    if command -v tensorboard &> /dev/null; then
        log_info "TensorBoard 启动命令："
        log_info "  tensorboard --logdir=$BASE_DIR"
        log_info ""
        log_info "在浏览器中打开:"
        log_info "  http://localhost:6006"
        log_info ""
        log_info "按 Ctrl+C 停止 TensorBoard"
        
        # 启动 TensorBoard
        tensorboard --logdir="$BASE_DIR" --host=0.0.0.0 --port=6006
    else
        log_warn "TensorBoard 未安装，无法启动"
        log_info "如需安装: pip install tensorboard"
    fi
fi

# ============================================================================
# 3. 对比分析（如果指定）
# ============================================================================

if [ "$SHOW_COMPARE" = true ]; then
    log_info ""
    log_info "========== 模型对比分析 =========="
    
    # 创建对比脚本
    cat > "/tmp/compare_models.py" << 'EOF'
import os
import sys
import json
from pathlib import Path

base_dir = Path("./output/comparison/exp_diffusion_vs_fm")

print("\n【模型检查点对比】\n")
print(f"{'模型':<15} {'检查点':<25} {'大小':<12} {'修改时间':<20}")
print("-" * 72)

for model_name in ["vae", "ddm", "fm"]:
    ckpt_dir = base_dir / model_name / "checkpoints"
    if ckpt_dir.exists():
        for ckpt_file in ckpt_dir.glob("*.ckpt"):
            size = ckpt_file.stat().st_size
            size_mb = size / (1024 * 1024)
            mtime = ckpt_file.stat().st_mtime
            from datetime import datetime
            mtime_str = datetime.fromtimestamp(mtime).strftime("%Y-%m-%d %H:%M:%S")
            print(f"{model_name:<15} {ckpt_file.name:<25} {size_mb:>10.1f}MB {mtime_str:<20}")

# 检查日志
print("\n【训练日志】\n")
print(f"{'模型':<15} {'日志位置'}")
print("-" * 50)

for model_name in ["vae", "ddm", "fm"]:
    log_dir = base_dir / model_name / "logs"
    if log_dir.exists():
        event_files = list(log_dir.glob("events.out*"))
        if event_files:
            print(f"{model_name:<15} ✓ {str(log_dir)}")
        else:
            print(f"{model_name:<15} ✗ 无日志文件")
    else:
        print(f"{model_name:<15} - 目录不存在")

print("\n")
EOF
    
    python /tmp/compare_models.py
fi

# ============================================================================
# 4. 生成对比报告（如果指定）
# ============================================================================

if [ "$GENERATE_REPORT" = true ]; then
    log_info ""
    log_info "========== 生成对比报告 =========="
    
    REPORT_FILE="./output/comparison/exp_diffusion_vs_fm/REPORT.md"
    
    cat > "$REPORT_FILE" << 'EOF'
# GraspLDM 对比实验报告

## 实验概述

本报告汇总了 Diffusion 模型与 Flow Matching 模型在抓取生成任务上的对比实验结果。

## 实验配置

### 数据集
- **名称**: ACRONYM (Adversarial Robotic Manipulation)
- **位置**: `./data/ACRONYM/`
- **总对象数**: 8837 个
- **点云尺寸**: 1024 点
- **抓取表示**: 6-DoF (MRP 旋转表示)

### 硬件
- **GPU**: RTX 4090（假设）
- **显存**: 24GB（假设）
- **CUDA**: 11.7+

### 训练参数
| 参数 | 值 |
|------|-----|
| 最大步数 | 180,000 |
| Batch Size | 32 |
| 数据加载线程 | 0 |
| 学习率 | 自配置 |
| 优化器 | AdamW（推荐） |

## 第一阶段：VAE 预训练

### 目标
学习抓取数据的低维隐空间表示

### 配置
- **隐向量维度**: 4
- **点云编码维度**: 64
- **编码器**: PVCNN
- **损失函数**: 重构损失 + VAE KL 散度

### 输出
- 权重保存位置: `./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/`
- 日志位置: `./output/comparison/exp_diffusion_vs_fm/vae/logs/`

## 第二阶段：Diffusion 模型训练

### 目标
使用 DDPM（去噪扩散概率模型）从噪声逐步生成抓取

### 配置
- **扩散步数**: 1000
- **噪声调度**: Linear
- **beta 范围**: [0.00005, 0.001]
- **去噪网络**: TimeConditionedResNet1D

### 输出
- 权重保存位置: `./output/comparison/exp_diffusion_vs_fm/ddm/checkpoints/`
- 日志位置: `./output/comparison/exp_diffusion_vs_fm/ddm/logs/`

## 第三阶段：Flow Matching（待实现）

### 目标
使用连续流匹配方法训练生成模型

### 状态
- ⏳ 开发中

## 结果对比

### 模型大小对比
| 模型 | 权重大小 | 推理速度 |
|------|--------|--------|
| VAE | TBD | - |
| Diffusion | TBD | TBD |
| Flow Matching | TBD | TBD |

### 生成质量对比
| 指标 | Diffusion | Flow Matching | 说明 |
|------|-----------|---------------|------|
| 成功率 (Success Rate) | TBD | TBD | 生成的抓取能否成功执行 |
| 多样性 (Diversity) | TBD | TBD | 生成的抓取的多样性 |
| 推理时间 (Latency) | TBD | TBD | 生成一个抓取的平均时间 |
| 吞吐量 (Throughput) | TBD | TBD | 每秒能生成的抓取数 |

## 关键文件

- 配置文件: `./configs/comparison/exp_diffusion_vs_fm.py`
- 训练脚本: `./tools/train_generator.py`
- 推理脚本: `./tools/generate_grasps.py`
- 数据集: `./data/ACRONYM/`

## 复现步骤

### 1. 环境准备
```bash
# 安装离线依赖
./install_offline_deps.sh

# 修改路径为相对路径
./setup_paths.sh
```

### 2. 运行完整实验
```bash
./run_full_experiment.sh
```

### 3. 查看结果
```bash
# 启动 TensorBoard
./view_results.sh --tensorboard

# 生成对比报告
./view_results.sh --report

# 显示模型对比
./view_results.sh --compare
```

## 故障排除

### 数据加载卡死
- **现象**: 训练启动后停在 `Epoch 0: 0%`
- **原因**: `num_workers_per_gpu` 过大
- **解决**: 在配置中设置 `num_workers_per_gpu = 0`

### 显存不足
- **现象**: CUDA out of memory
- **原因**: Batch size 过大或显存不足
- **解决**: 
  1. 减小 batch size: `--batch-size 16`
  2. 减小点云点数: 在配置中修改 `pc_num_points = 512`

### 训练中断恢复
```bash
# 配置中设置 resume_training_from_last = True
# 重启训练
./run_full_experiment.sh --skip-vae
```

## 相关资源

- 项目主页: https://github.com/kuldeepbarad/GraspLDM
- 论文: https://arxiv.org/abs/XXXX（待更新）
- ACRONYM 数据集: https://github.com/NVlabs/acronym

## 版本信息

- **创建时间**: $(date)
- **项目版本**: graspLDM v1.0
- **Python**: 3.8+
- **PyTorch**: 1.13.1+cu117

---

*此报告由自动生成脚本生成，更新时间: $(date)*
EOF
    
    log_success "✓ 对比报告已生成: $REPORT_FILE"
    
    # 显示报告路径
    log_info ""
    log_info "查看报告:"
    log_info "  cat $REPORT_FILE"
fi

# ============================================================================
# 5. 摘要
# ============================================================================

log_info ""
log_info "========== 常用操作 =========="

log_info ""
log_info "【查看训练曲线】"
log_info "  ./view_results.sh --tensorboard"
log_info ""
log_info "【对比模型信息】"
log_info "  ./view_results.sh --compare"
log_info ""
log_info "【生成完整报告】"
log_info "  ./view_results.sh --report"
log_info ""
log_info "【所有操作】"
log_info "  ./view_results.sh --all"

log_info ""
log_info "【生成抓取（推理）】"
log_info "  python tools/generate_grasps.py --exp_path ./output/comparison/exp_diffusion_vs_fm/vae --mode VAE"
log_info "  python tools/generate_grasps.py --exp_path ./output/comparison/exp_diffusion_vs_fm/ddm --mode LDM"

log_info ""
log_success "✓ 实验结果查看完成"
