# graspLDM 全流程对比实验一键启动指南

## 🚀 5分钟快速开始

### 第1步：确保您在 graspLDM 项目目录

```bash
cd /path/to/graspLDM
ls -la run_full_comparison_experiment.sh  # 验证脚本存在
```

### 第2步：一键启动完整实验流程

```bash
# 方式 A：完全自动化（推荐）
./start_experiment.sh

# 方式 B：直接运行（跳过菜单）
./run_full_comparison_experiment.sh
```

### 第3步：实时监控进度

在**另一个终端**中执行：

```bash
# 方式 1：查看日志文件
tail -f ./output/logs/full_experiment_*.log

# 方式 2：启动 TensorBoard（可视化训练曲线）
tensorboard --logdir ./output/comparison/exp_diffusion_vs_fm/logs --port 6006
# 然后在浏览器打开：http://localhost:6006

# 方式 3：监控 GPU 使用
watch -n 1 nvidia-smi
```

### 第4步：实验完成后查看结果

```bash
# 快速查看工具
./view_experiment_results.sh

# 或手动查看
cat ./output/results/comparison_table.csv     # 对比结果
ls -lh ./output/comparison/exp_diffusion_vs_fm/*/checkpoints/  # Checkpoint 信息
```

---

## 📋 完整的脚本清单

| 脚本文件 | 用途 | 启动方式 |
|---------|------|---------|
| **run_full_comparison_experiment.sh** | 完整的一键运行脚本，包含所有检查和日志 | `./run_full_comparison_experiment.sh [选项]` |
| **start_experiment.sh** | 交互式菜单启动脚本，初学者友好 | `./start_experiment.sh` |
| **view_experiment_results.sh** | 结果查看工具，快速查看日志和 Checkpoint | `./view_experiment_results.sh` |

---

## 🎯 常见使用场景

### 场景 1：第一次运行（完整流程）

```bash
# 启动完整流程（会执行 VAE→Diffusion→FM→评估）
./run_full_comparison_experiment.sh

# 预期耗时：36-74 小时（单个 RTX 4090 GPU）
```

### 场景 2：使用多个 GPU 加速

```bash
# 使用 2 个 GPU，批处理大小为 64
./run_full_comparison_experiment.sh --num-gpus 2 --batch-size 64

# 预期耗时：20-40 小时（加速约 2 倍）
```

### 场景 3：前面的模型已训练，仅运行评估

```bash
# 跳过三个模型的训练，直接运行对比评估
./run_full_comparison_experiment.sh --skip-vae --skip-diffusion --skip-fm

# 预期耗时：1-2 小时
```

### 场景 4：重新训练某个模型

```bash
# 如果 Diffusion 训练失败，仅重新运行 Diffusion 和后续步骤
./run_full_comparison_experiment.sh --skip-vae --skip-fm

# 脚本会从上一个 checkpoint 继续训练
```

---

## 📖 命令行选项

### 基础选项

```bash
# 显示帮助信息
./run_full_comparison_experiment.sh --help

# 跳过 VAE 预训练
./run_full_comparison_experiment.sh --skip-vae

# 跳过 Diffusion 训练
./run_full_comparison_experiment.sh --skip-diffusion

# 跳过 Flow Matching 训练
./run_full_comparison_experiment.sh --skip-fm

# 跳过对比评估
./run_full_comparison_experiment.sh --skip-eval
```

### 高级选项

```bash
# 指定 GPU 数量
./run_full_comparison_experiment.sh --num-gpus 2

# 指定批处理大小
./run_full_comparison_experiment.sh --batch-size 64

# 启用调试模式（输出完整命令）
./run_full_comparison_experiment.sh --debug

# 组合多个选项
./run_full_comparison_experiment.sh --num-gpus 2 --batch-size 64 --skip-vae
```

---

## 📂 输出目录结构

```
graspLDM/
└── output/
    ├── logs/                           # 训练日志
    │   ├── full_experiment_*.log       # 完整日志
    │   ├── 01_vae_training_*.log       # VAE 训练日志
    │   ├── 02_diffusion_training_*.log # Diffusion 训练日志
    │   ├── 03_flow_matching_training_*.log # Flow Matching 训练日志
    │   └── 04_evaluation_*.log         # 评估日志
    │
    ├── comparison/
    │   └── exp_diffusion_vs_fm/
    │       ├── vae/
    │       │   ├── checkpoints/        # VAE 权重
    │       │   └── logs/               # VAE TensorBoard 日志
    │       ├── ddm/
    │       │   ├── checkpoints/        # Diffusion 权重
    │       │   └── logs/               # Diffusion TensorBoard 日志
    │       └── fm/
    │           ├── checkpoints/        # Flow Matching 权重
    │           └── logs/               # Flow Matching TensorBoard 日志
    │
    └── results/
        ├── comparison_table.csv        # 对比结果表格
        ├── comparison_plots/           # 可视化图表
        └── evaluation_report.json      # 评估报告
```

---

## 🔍 查看结果的方式

### 方式 1：查看日志

```bash
# 查看最新的完整日志（最后 100 行）
tail -n 100 ./output/logs/full_experiment_*.log

# 持续监控日志（实时输出）
tail -f ./output/logs/full_experiment_*.log

# 查看特定模型的日志
tail -f ./output/logs/01_vae_training_*.log
tail -f ./output/logs/02_diffusion_training_*.log
tail -f ./output/logs/03_flow_matching_training_*.log
```

### 方式 2：使用 TensorBoard 可视化

```bash
# 启动 TensorBoard
tensorboard --logdir ./output/comparison/exp_diffusion_vs_fm/logs --port 6006

# 在浏览器中打开
# http://localhost:6006

# 在 TensorBoard 中可以看到：
# • Scalars：训练损失、验证指标
# • Graphs：模型结构
# • Histograms：权重分布变化
# • Projector：嵌入空间可视化
```

### 方式 3：查看 Checkpoint 信息

```bash
# 查看 Checkpoint 文件大小
du -sh ./output/comparison/exp_diffusion_vs_fm/*/checkpoints/

# 列出所有 Checkpoint 文件
ls -lh ./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/
ls -lh ./output/comparison/exp_diffusion_vs_fm/ddm/checkpoints/
ls -lh ./output/comparison/exp_diffusion_vs_fm/fm/checkpoints/
```

### 方式 4：查看对比结果

```bash
# 查看对比结果表格（CSV 格式）
cat ./output/results/comparison_table.csv

# 用 Excel 或其他工具打开
open ./output/results/comparison_table.csv

# 统计数据
grep -E "^(VAE|Diffusion|Flow)" ./output/results/comparison_table.csv
```

---

## ⚠️ 常见问题

### Q: 脚本找不到怎么办？

```bash
# 验证脚本是否存在
ls -la run_full_comparison_experiment.sh

# 如果不存在，确保您在正确的项目目录
pwd
ls -la  # 应该看到 grasp_ldm、configs、tools 等目录
```

### Q: 脚本执行权限不足怎么办？

```bash
# 赋予执行权限
chmod +x run_full_comparison_experiment.sh start_experiment.sh view_experiment_results.sh

# 验证权限
ls -la *.sh | grep -E "^-rwx"
```

### Q: 如何中途停止脚本？

```bash
# 按 Ctrl+C 停止脚本

# 已保存的 checkpoint 会被保留，下次可以继续运行
# 使用 --skip-* 选项跳过已完成的步骤

./run_full_comparison_experiment.sh --skip-vae --skip-diffusion
```

### Q: GPU 显存不足怎么办？

```bash
# 减少批处理大小
./run_full_comparison_experiment.sh --batch-size 16

# 如果还是不够，可能需要：
# 1. 使用更多 GPU：--num-gpus 2
# 2. 升级 GPU（推荐 RTX 4090 24GB）
# 3. 修改配置文件降低模型大小
```

### Q: 如何查看实时训练进度？

```bash
# 终端 1：启动训练
./run_full_comparison_experiment.sh

# 终端 2：实时查看日志
tail -f ./output/logs/full_experiment_*.log

# 终端 3：启动 TensorBoard
tensorboard --logdir ./output/comparison/exp_diffusion_vs_fm/logs --port 6006

# 然后在浏览器打开：http://localhost:6006
```

---

## ✅ 检查清单

在启动实验前，请检查：

- ✅ 您在 graspLDM 项目根目录
- ✅ 脚本文件存在：`run_full_comparison_experiment.sh`
- ✅ 脚本有执行权限：`ls -la run_full_comparison_experiment.sh | grep -q x`
- ✅ 数据集已准备：`ls data/ACRONYM/grasps/ | wc -l` 应该显示 8837
- ✅ GPU 可用：`nvidia-smi` 应该显示 GPU 信息
- ✅ 依赖包已安装：`python3 -c "import torch; print(torch.__version__)"`
- ✅ 磁盘空间足够：`df -h` 应该有 500+ GB 可用空间

---

## 🎓 详细文档

如需更详细的信息，请查看：

- [完整运行指南](RUN_EXPERIMENT_GUIDE_CN.md) - 详细的使用说明
- [修改总结](MODIFICATION_COMPLETE_SUMMARY_CN.md) - 代码修改说明
- [部署指南](README_DEPLOYMENT_CN.md) - 环境部署说明
- [快速参考](QUICK_START_CN.md) - 快速参考卡

---

## 🎉 开始您的第一次实验！

```bash
# 一键启动
./start_experiment.sh

# 或者直接运行
./run_full_comparison_experiment.sh

# 然后在另一个终端查看进度
tail -f ./output/logs/full_experiment_*.log
```

**预计实验时间**：36-74 小时（单个 RTX 4090）  
**实验流程**：VAE (12-24h) → Diffusion (12-24h) → Flow Matching (12-24h) → 评估 (1-2h)

祝您实验顺利！🚀
