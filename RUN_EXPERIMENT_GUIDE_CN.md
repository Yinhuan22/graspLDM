# graspLDM 全流程对比实验运行指南

## 📋 概述

本文档提供详细的使用说明，帮助您使用一键脚本运行 graspLDM 的完整对比实验流程：

1. **VAE 预训练** (180000 步，~12-24小时)
2. **Diffusion 模型训练** (180000 步，~12-24小时)
3. **Flow Matching 模型训练** (180000 步，~12-24小时)
4. **对比实验评估** (~1-2小时)

---

## 🚀 快速开始

### 第1步：赋予脚本执行权限

```bash
cd /path/to/graspLDM
chmod +x run_full_comparison_experiment.sh
```

### 第2步：运行完整流程

```bash
# 方式 A：简单运行（使用默认参数）
./run_full_comparison_experiment.sh

# 方式 B：使用 2 个 GPU，批处理大小为 64
./run_full_comparison_experiment.sh --num-gpus 2 --batch-size 64

# 方式 C：跳过 VAE，直接运行 Diffusion
./run_full_comparison_experiment.sh --skip-vae

# 方式 D：启用调试模式（查看完整命令）
./run_full_comparison_experiment.sh --debug
```

### 第3步：查看结果

```bash
# 查看最新的日志
tail -f ./output/logs/full_experiment_*.log

# 使用 TensorBoard 查看训练曲线
tensorboard --logdir ./output/comparison/exp_diffusion_vs_fm/logs
```

---

## 📖 详细使用说明

### 命令行选项

| 选项 | 说明 | 默认值 | 示例 |
|------|------|--------|------|
| `--skip-vae` | 跳过 VAE 预训练 | 不跳过 | `./run_full_comparison_experiment.sh --skip-vae` |
| `--skip-diffusion` | 跳过 Diffusion 训练 | 不跳过 | `./run_full_comparison_experiment.sh --skip-diffusion` |
| `--skip-fm` | 跳过 Flow Matching 训练 | 不跳过 | `./run_full_comparison_experiment.sh --skip-fm` |
| `--skip-eval` | 跳过对比评估 | 不跳过 | `./run_full_comparison_experiment.sh --skip-eval` |
| `--num-gpus N` | 使用的 GPU 数量 | 1 | `./run_full_comparison_experiment.sh --num-gpus 2` |
| `--batch-size N` | 批处理大小 | 32 | `./run_full_comparison_experiment.sh --batch-size 64` |
| `--debug` | 启用调试模式 | 关闭 | `./run_full_comparison_experiment.sh --debug` |
| `-h, --help` | 显示帮助信息 | - | `./run_full_comparison_experiment.sh --help` |

---

## 💡 使用场景

### 场景 1：第一次完整运行

```bash
# 运行完整流程，使用 1 个 GPU
./run_full_comparison_experiment.sh

# 预期耗时：36-72 小时
```

### 场景 2：使用多个 GPU 加速

```bash
# 使用 2 个 GPU，增加批处理大小
./run_full_comparison_experiment.sh --num-gpus 2 --batch-size 64

# 预期耗时：18-36 小时（加速约 2 倍）
```

### 场景 3：前面的步骤已完成，仅需运行评估

```bash
# 跳过三个模型的训练，直接运行对比评估
./run_full_comparison_experiment.sh --skip-vae --skip-diffusion --skip-fm

# 预期耗时：1-2 小时
```

### 场景 4：重新训练 Diffusion 模型

```bash
# 跳过 VAE（使用已有的权重），运行 Diffusion 和 FM
./run_full_comparison_experiment.sh --skip-vae

# 预期耗时：24-48 小时
```

### 场景 5：断点续传（某个模型训练中断）

```bash
# 如果 Diffusion 训练中断，仅重新运行 Diffusion 和后续步骤
./run_full_comparison_experiment.sh --skip-vae --skip-fm

# 脚本会从上一个检查点继续训练
```

---

## 📊 实验结果查看

### 日志文件位置

```
./output/logs/
├── full_experiment_YYYYMMDD_HHMMSS.log      # 完整实验日志
├── 01_vae_training_YYYYMMDD_HHMMSS.log      # VAE 预训练日志
├── 02_diffusion_training_YYYYMMDD_HHMMSS.log # Diffusion 训练日志
├── 03_flow_matching_training_YYYYMMDD_HHMMSS.log # Flow Matching 训练日志
└── 04_evaluation_YYYYMMDD_HHMMSS.log        # 对比评估日志
```

### 查看日志的方式

```bash
# 1. 查看完整实验日志（最后 100 行）
tail -n 100 ./output/logs/full_experiment_*.log

# 2. 实时监控日志（持续输出新内容）
tail -f ./output/logs/full_experiment_*.log

# 3. 查看特定模型的训练日志
grep "VAE" ./output/logs/full_experiment_*.log | tail -n 20

# 4. 统计训练步数
grep "step" ./output/logs/02_diffusion_training_*.log | tail -n 5

# 5. 查看所有错误信息
grep "ERROR" ./output/logs/full_experiment_*.log
```

### Checkpoint 目录结构

```
./output/comparison/exp_diffusion_vs_fm/
├── vae/
│   ├── checkpoints/
│   │   ├── last.ckpt              # VAE 最新权重
│   │   ├── best.ckpt              # VAE 最优权重
│   │   └── *.ckpt                 # VAE 中间检查点
│   └── logs/                       # VAE TensorBoard 日志
├── ddm/
│   ├── checkpoints/
│   │   ├── last.ckpt              # Diffusion 最新权重
│   │   ├── best.ckpt              # Diffusion 最优权重
│   │   └── *.ckpt                 # Diffusion 中间检查点
│   └── logs/                       # Diffusion TensorBoard 日志
└── fm/
    ├── checkpoints/
    │   ├── last.ckpt              # Flow Matching 最新权重
    │   ├── best.ckpt              # Flow Matching 最优权重
    │   └── *.ckpt                 # Flow Matching 中间检查点
    └── logs/                       # Flow Matching TensorBoard 日志
```

### 使用 TensorBoard 可视化

```bash
# 启动 TensorBoard
tensorboard --logdir ./output/comparison/exp_diffusion_vs_fm/logs --port 6006

# 在浏览器中打开
# http://localhost:6006

# 查看不同模型的训练曲线
# • Scalars：训练损失、评估指标
# • Graphs：模型结构
# • Histograms：权重分布
```

### 对比评估结果

```bash
# 查看对比结果表格
cat ./output/results/comparison_table.csv

# 生成的内容示例：
# Model,Success_Rate,Grasp_Quality,Diversity,Speed
# VAE,0.85,0.92,0.78,1.0x
# Diffusion,0.88,0.95,0.85,0.8x
# Flow Matching,0.87,0.94,0.82,0.9x
```

---

## ⏱️ 时间估计

### 单个 GPU 运行时间（RTX 4090）

| 阶段 | 步数 | 预估时间 |
|------|------|---------|
| VAE 预训练 | 180000 | 12-24 小时 |
| Diffusion 训练 | 180000 | 12-24 小时 |
| Flow Matching 训练 | 180000 | 12-24 小时 |
| 对比评估 | - | 1-2 小时 |
| **总计** | - | **37-74 小时** |

### 使用多 GPU 的加速比

| GPU 数量 | 预期加速比 | 预估总时间 |
|---------|-----------|----------|
| 1 | 1.0x | 37-74 小时 |
| 2 | ~1.8x | 20-41 小时 |
| 4 | ~3.5x | 10-21 小时 |
| 8 | ~6.5x | 5-11 小时 |

---

## 🔧 故障排除

### 问题 1：脚本执行失败

**症状**：权限被拒绝

**解决方案**：
```bash
chmod +x run_full_comparison_experiment.sh
```

---

### 问题 2：GPU 显存不足

**症状**：`CUDA out of memory` 错误

**解决方案**：
```bash
# 方式 A：减少批处理大小
./run_full_comparison_experiment.sh --batch-size 16

# 方式 B：清理 GPU 显存
nvidia-smi
nvidia-smi --query-compute-apps=pid --format=csv --no-header | xargs -I {} kill {}

# 方式 C：检查其他 GPU 进程
ps aux | grep python
```

---

### 问题 3：数据集路径错误

**症状**：`FileNotFoundError: data/ACRONYM` 错误

**解决方案**：
```bash
# 检查数据集是否存在
ls -la ./data/ACRONYM/

# 如果不存在，检查是否需要解压
unzip acronym.tar.gz -d ./data/ACRONYM/

# 验证数据文件数量
find ./data/ACRONYM/grasps -name "*.h5" | wc -l
# 应该显示 8837
```

---

### 问题 4：依赖包缺失

**症状**：`ModuleNotFoundError: No module named '...'` 错误

**解决方案**：
```bash
# 安装依赖包
pip install -r requirements.txt

# 或使用离线包
pip install --no-index --find-links=./wheels wheels/*.whl
```

---

### 问题 5：训练中断

**症状**：脚本输出错误信息后停止

**解决方案**：
```bash
# 1. 查看详细的错误日志
tail -n 50 ./output/logs/full_experiment_*.log

# 2. 从上一个检查点恢复
# 脚本会自动检测已保存的 checkpoint 并从中恢复

# 3. 使用 --debug 标志获取更多信息
./run_full_comparison_experiment.sh --debug
```

---

## 🎯 最佳实践

### 1. 监控磁盘空间

```bash
# 检查磁盘使用情况
df -h ./

# 预留至少 500GB 的空间用于：
# - 数据集：~100 GB
# - Checkpoint：~50 GB
# - 日志和输出：~50 GB
# - 缓冲区：~200 GB
```

### 2. 监控 GPU 使用

```bash
# 实时监控 GPU
watch -n 1 nvidia-smi

# 或使用 GPU 监控工具
gpustat --watch
```

### 3. 记录实验参数

```bash
# 每次运行前记录配置
echo "实验时间: $(date)" >> experiments.log
echo "命令: ./run_full_comparison_experiment.sh $@" >> experiments.log
echo "GPU 数量: $NUM_GPUS" >> experiments.log
echo "批处理大小: $BATCH_SIZE" >> experiments.log
```

### 4. 定期备份结果

```bash
# 实验完成后备份
tar -czf results_backup_$(date +%Y%m%d).tar.gz ./output/

# 上传到云存储或外置磁盘
cp results_backup_*.tar.gz /backup/path/
```

---

## 📞 常见问题

**Q: 能否中途停止脚本并恢复？**
A: 可以。训练框架会自动保存 checkpoint。使用 `--skip-vae` 或相关选项跳过已完成的步骤。

**Q: 如何修改训练步数？**
A: 编辑配置文件 `configs/comparison/exp_diffusion_vs_fm.py` 中的 `max_steps` 参数。

**Q: 能否在多台机器上并行运行？**
A: 可以，但需要确保数据集同步。建议使用 NFS 或其他共享存储。

**Q: 如何查看实时的训练进度？**
A: 使用 TensorBoard：`tensorboard --logdir ./output/comparison/exp_diffusion_vs_fm/logs`

**Q: 脚本出错后如何恢复？**
A: 1. 查看日志找出错误原因；2. 修复问题；3. 使用 `--skip-*` 选项跳过已完成的步骤重新运行。

---

## 📞 获取帮助

```bash
# 显示脚本帮助信息
./run_full_comparison_experiment.sh --help

# 显示调试信息
./run_full_comparison_experiment.sh --debug

# 检查路径配置
python3 verify_paths.py

# 检查 GPU 可用性
python3 -c "import torch; print('GPU:', torch.cuda.device_count())"
```

---

## 📚 相关文档

- [项目部署指南](README_DEPLOYMENT_CN.md)
- [路径配置说明](PATH_MODIFICATION_REPORT_CN.md)
- [快速参考指南](QUICK_START_CN.md)

---

**最后更新**: 2026年3月2日  
**脚本版本**: 1.0  
**兼容性**: Python 3.8+, PyTorch 1.13.1+, PyTorch Lightning 1.8.6+
