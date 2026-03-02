# WebIDE 离线部署 GraspLDM 完整指南

> **面向场景**: 全新、无外网的 WebIDE 环境，从零开始完整部署 graspLDM 项目及对比实验
>
> **目标**: 一键完成 VAE → Diffusion → Flow Matching 的全流程对比实验

---

## 目录

1. [快速开始](#快速开始)
2. [详细部署步骤](#详细部署步骤)
3. [离线依赖安装](#离线依赖安装)
4. [配置文件修改](#配置文件修改)
5. [一键运行实验](#一键运行实验)
6. [查看实验结果](#查看实验结果)
7. [故障排除](#故障排除)
8. [附录：关键文件清单](#附录关键文件清单)

---

## 快速开始

如果你已经有所有资源（代码 + 数据 + wheels），只需 3 步：

```bash
# 第 1 步：设置路径为相对路径
chmod +x setup_paths.sh install_offline_deps.sh run_full_experiment.sh view_results.sh
./setup_paths.sh

# 第 2 步：安装离线依赖
./install_offline_deps.sh

# 第 3 步：一键运行完整实验
./run_full_experiment.sh
```

实验完成后，查看结果：

```bash
# 启动 TensorBoard 查看训练曲线
./view_results.sh --tensorboard
```

---

## 详细部署步骤

### 第 0 步：准备资源

在 WebIDE 中创建如下目录结构：

```
workspace/
├── graspLDM/                        # 项目代码（从 graspLDM.zip 解压）
│   ├── configs/
│   ├── tools/
│   ├── grasp_ldm/
│   ├── data/
│   │   └── ACRONYM/
│   │       ├── grasps/              # 8837 个 .h5 文件
│   │       ├── acronym/
│   │       └── splits/
│   ├── wheels/                      # 离线 .whl 包（从外网环境下载）
│   │   ├── torch*.whl
│   │   ├── torchvision*.whl
│   │   ├── pytorch-lightning*.whl
│   │   └── ... (其他依赖)
│   ├── install_offline_deps.sh      # 新增：安装脚本
│   ├── setup_paths.sh               # 新增：路径修改脚本
│   ├── run_full_experiment.sh       # 新增：一键运行脚本
│   ├── view_results.sh              # 新增：结果查看脚本
│   ├── requirements.txt
│   └── environment.yml
```

#### 资源检查清单

- [ ] graspLDM 项目代码完整（至少包含 configs/、tools/、grasp_ldm/）
- [ ] ACRONYM 数据集完整（./data/ACRONYM/grasps/ 有 8837 个 .h5 文件）
- [ ] wheels/ 目录包含所有必要的 .whl 文件
- [ ] Python 3.8+ 已预装
- [ ] GPU 驱动已安装（nvidia-smi 可用）

### 第 1 步：修改配置文件路径

**目的**: 将所有硬编码的绝对路径修改为相对路径，支持离线环境

运行提供的脚本：

```bash
chmod +x setup_paths.sh
./setup_paths.sh
```

**脚本作用**:
1. 修改 `configs/comparison/exp_diffusion_vs_fm.py` 中的 `root_data_dir`
2. 修改 `fix_ckpt.py`、`vae_train_progress.py` 中的硬编码路径
3. 创建输出目录结构
4. 备份原配置文件（.bak）

**手动修改**（如需）:

编辑 `configs/comparison/exp_diffusion_vs_fm.py`：

```python
# 修改前
root_data_dir = "/home/mi/siat/graspldm/graspLDM/data/ACRONYM"

# 修改后
root_data_dir = "./data/ACRONYM"
```

### 第 2 步：离线安装依赖

**前置条件**:
- `wheels/` 目录存在，包含所有依赖的 .whl 文件
- pip 可用（通常预装）

运行脚本：

```bash
chmod +x install_offline_deps.sh
./install_offline_deps.sh
```

**脚本作用**:
1. 检查 Python 环境和 pip
2. 从 `wheels/` 目录离线安装所有依赖
3. 验证关键包是否安装成功
4. 检查 GPU/CUDA 可用性

**预期输出**:

```
[INFO] Python 版本: 3.8.x
[SUCCESS] 找到 150 个 .whl 文件
[SUCCESS] torch (v1.13.1) ✓
[SUCCESS] torchvision (v0.14.1) ✓
[SUCCESS] pytorch-lightning (v1.8.6) ✓
[SUCCESS] GPU: NVIDIA RTX 4090 ✓
```

**如果出现错误**:

- `wheels 目录不存在`: 检查资源是否完整
- `pip 未找到`: 运行 `python -m pip --version`
- `某个包安装失败`: 检查该包的 .whl 文件是否在 wheels/ 中

### 第 3 步：准备数据

确保 ACRONYM 数据集已完整解压到 `./data/ACRONYM/`：

```bash
# 验证数据集
ls -la ./data/ACRONYM/
# 应该看到: grasps/ acronym/ splits/ 等目录

# 检查 h5 文件数量
find ./data/ACRONYM/grasps -name "*.h5" | wc -l
# 应该输出: 8837 (或接近的数字)
```

如果数据集不完整，需要在有网络的环境下下载并解压：

```bash
# 在有网环境下执行
cd /path/to/external_env
wget https://github.com/NVlabs/acronym/archive/refs/heads/master.zip
unzip master.zip
cd acronym-master
# ... 按照官方说明下载数据 ...

# 然后打包
tar -czf acronym.tar.gz grasps/ acronym/ splits/
# 将 acronym.tar.gz 传输到 WebIDE，解压到 ./data/ACRONYM/
```

### 第 4 步：一键运行完整实验

#### 4.1 基础运行

运行完整的 VAE → Diffusion 对比实验：

```bash
chmod +x run_full_experiment.sh
./run_full_experiment.sh
```

**预期耗时**:
- VAE 预训练: ~12-24 小时（RTX 4090，180k 步）
- Diffusion 训练: ~12-24 小时（180k 步）
- 总耗时: ~24-48 小时

**运行日志示例**:

```
[12:00:00] 初始化和环境检查
[12:00:05] ✓ 项目根目录检查完成
[12:00:10] ✓ Python 3.8.x
[12:00:15] ✓ torch 已安装
[12:00:20] ✓ GPU: NVIDIA RTX 4090
[12:00:30] ✓ ACRONYM 数据集检查完成 (共 8837 个 .h5 文件)

[12:00:30] 第一阶段：VAE 预训练
[12:00:35] 启动 VAE 训练...
[12:05:00] Epoch 0: 100%|██████████| 300/300 [02:45<00:00, 1.81it/s], Loss: 0.250
...（每个 epoch 会输出进度）
```

#### 4.2 高级选项

```bash
# 跳过 VAE，仅训练 Diffusion（使用现有 VAE 权重）
./run_full_experiment.sh --skip-vae

# 跳过 Diffusion，仅训练 VAE
./run_full_experiment.sh --skip-ddm

# 跳过 Flow Matching（当前为默认）
./run_full_experiment.sh --skip-fm

# 调试模式（显示详细日志）
./run_full_experiment.sh --debug

# 组合使用
./run_full_experiment.sh --skip-vae --debug
```

#### 4.3 中断和恢复

如果训练中途中断：

```bash
# 1. 确认进程已终止
ps -ef | grep train_generator.py | grep -v grep

# 如果还有进程运行
pkill -f train_generator.py

# 2. 修改配置以恢复训练
# 编辑 configs/comparison/exp_diffusion_vs_fm.py
resume_training_from_last = True  # 从上次检查点继续

# 3. 重新运行（仅运行中断的阶段）
./run_full_experiment.sh --skip-vae  # 如果 VAE 已完成
```

---

## 离线依赖安装

### 从外网环境下载 wheels

在有网络的机器上执行：

```bash
# 创建临时目录
mkdir -p /tmp/graspldm_wheels
cd /tmp/graspldm_wheels

# 下载所有依赖
pip download -r requirements.txt \
    --destination-directory . \
    --no-deps \
    --python-version 38 \
    --only-binary=:all: \
    --platform manylinux2014_x86_64

# 查看下载的文件
ls -lh *.whl | wc -l  # 应该有 100+ 个文件

# 创建 zip 或 tar，传输到 WebIDE
tar -czf graspldm_wheels.tar.gz *.whl
# 或
zip -r graspldm_wheels.zip *.whl
```

然后在 WebIDE 中解压到 `./wheels/` 目录。

### 验证 wheels 完整性

```bash
# 检查是否包含关键包
ls wheels/ | grep -i torch
ls wheels/ | grep -i pytorch
ls wheels/ | grep -i diffusers
ls wheels/ | grep -i h5py

# 完整性检查
python -c "
import os
from pathlib import Path
wheels = list(Path('wheels').glob('*.whl'))
print(f'找到 {len(wheels)} 个 .whl 文件')
for whl in sorted(wheels)[:10]:
    print(f'  - {whl.name}')
print('  ...')
"
```

---

## 配置文件修改

### 关键配置参数

编辑 `configs/comparison/exp_diffusion_vs_fm.py`：

#### 1. 训练参数调整

```python
# 训练步数（推荐值：180000，可按硬件调整）
max_steps = 180000

# Batch size（推荐值：32，如显存不足改为 16）
batch_size = 32

# GPU 数量（单机推荐：1）
num_gpus = 1

# 数据加载线程数（重要：务必设为 0 避免卡死）
num_workers_per_gpu = 0

# 数据路径（修改为相对路径）
root_data_dir = "./data/ACRONYM"
```

#### 2. 恢复训练配置

```python
# 是否从最后的检查点恢复
resume_training_from_last = False  # 从头开始
# 或
resume_training_from_last = True   # 从检查点继续

# 指定特定的 VAE 权重
shared_vae_ckpt_path = "./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/last.ckpt"
```

#### 3. 模型架构参数

```python
# 点云处理
pc_num_points = 1024        # 点云点数
pc_latent_dims = 64         # 点云编码维度
pc_latent_channels = 3      # 点云特征通道

# 抓取表示
grasp_latent_dims = 4       # 抓取隐向量维度
grasp_pose_dims = 6         # 抓取位姿维度（6-DoF）

# 编码器参数
dropout = 0.1
```

#### 4. 数据增强配置

```python
augs_config = [
    dict(type="RandomRotation", args=dict(p=0.5, max_angle=180, is_degree=True)),
    dict(type="PointcloudJitter", args=dict(p=1, sigma=0.005, clip=0.005)),
    dict(type="RandomPointcloudDropout", args=dict(p=0.5, max_dropout_ratio=0.4)),
]
```

### 修改配置的常见问题

**问题 1**: 数据加载卡死

```python
# ✗ 错误配置
num_workers_per_gpu = 7

# ✓ 正确配置（笔记本/单机推荐）
num_workers_per_gpu = 0
```

**问题 2**: 显存溢出

```python
# ✓ 减小 batch size
batch_size = 16

# ✓ 减小点云点数
pc_num_points = 512
```

**问题 3**: 训练速度过慢

```python
# ✓ 增加数据加载线程（如果有足够 RAM）
num_workers_per_gpu = 4

# ✓ 减小验证频率
check_val_every_n_epoch = 20
```

---

## 一键运行实验

### 完整实验流程

```bash
./run_full_experiment.sh
```

脚本将自动执行：

```
┌─────────────────────────────────────────┐
│ 1. 初始化和环境检查                      │
│    ✓ Python 版本检查                     │
│    ✓ 依赖包验证                          │
│    ✓ GPU/CUDA 检查                       │
│    ✓ 数据集验证                          │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│ 2. VAE 预训练（第一阶段）               │
│    输出: ./output/.../vae/checkpoints/   │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│ 3. Diffusion 训练（第二阶段）           │
│    输出: ./output/.../ddm/checkpoints/   │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│ 4. Flow Matching（第三阶段，待实现）    │
│    输出: ./output/.../fm/checkpoints/    │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│ 5. 结果评估和对比                       │
│    输出: 总结报告和性能指标              │
└─────────────────────────────────────────┘
```

### 实验输出目录结构

```
./output/comparison/exp_diffusion_vs_fm/
├── vae/
│   ├── checkpoints/
│   │   ├── last.ckpt              # 最后检查点
│   │   ├── best.ckpt              # 最佳权重
│   │   └── ... (中间检查点)
│   ├── logs/
│   │   └── events.out.tfevents... # TensorBoard 日志
│   └── exp_diffusion_vs_fm.py     # 配置副本
├── ddm/
│   ├── checkpoints/
│   │   ├── last.ckpt
│   │   ├── best.ckpt
│   │   └── ...
│   ├── logs/
│   │   └── events.out.tfevents...
│   └── exp_diffusion_vs_fm.py
└── fm/
    ├── checkpoints/
    ├── logs/
    └── exp_diffusion_vs_fm.py
```

### 监控训练进度

在训练过程中，使用另一个终端查看进度：

```bash
# 实时查看最新日志
tail -f ./output/comparison/exp_diffusion_vs_fm/vae/logs/*.txt

# 检查 GPU 占用
watch -n 1 nvidia-smi

# 监控磁盘空间（checkpoints 会很大）
du -sh ./output/comparison/exp_diffusion_vs_fm/*/checkpoints
```

---

## 查看实验结果

### 方法 1: 使用结果查看脚本

```bash
chmod +x view_results.sh

# 显示检查点和日志摘要
./view_results.sh

# 启动 TensorBoard 查看训练曲线
./view_results.sh --tensorboard

# 对比模型信息
./view_results.sh --compare

# 生成完整对比报告
./view_results.sh --report

# 所有操作
./view_results.sh --all
```

### 方法 2: 手动启动 TensorBoard

```bash
# 启动 TensorBoard（监听本地 6006 端口）
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --host=0.0.0.0 --port=6006

# 在浏览器中打开
http://localhost:6006
```

**TensorBoard 界面**:
- **SCALARS**: 显示 loss、val_loss、lr 等指标曲线
- **IMAGES**: 显示可视化的抓取和点云（如果保存）
- **HPARAMS**: 超参数对比

### 方法 3: 直接检查权重和日志

```bash
# 查看 VAE 权重信息
ls -lh ./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/

# 查看 Diffusion 权重信息
ls -lh ./output/comparison/exp_diffusion_vs_fm/ddm/checkpoints/

# 检查训练日志中的关键信息
find ./output/comparison/exp_diffusion_vs_fm -name "*.log" -o -name "*.txt" | xargs grep -i "loss\|epoch\|step"
```

### 生成的对比报告

脚本会生成 `./output/comparison/exp_diffusion_vs_fm/REPORT.md`，包含：

- 实验配置摘要
- 各阶段训练进度
- 模型大小对比
- 生成质量指标对比
- 故障排除建议

查看报告：

```bash
cat ./output/comparison/exp_diffusion_vs_fm/REPORT.md
```

---

## 故障排除

### 常见问题速查表

| 问题 | 原因 | 解决方案 |
|------|------|--------|
| 数据加载卡死 | `num_workers_per_gpu` 过大 | 设置为 0 |
| CUDA out of memory | Batch size 过大 | 减小至 16 或 8 |
| 训练 global_step 不涨 | checkpoint 中 global_step 被错误标记 | 运行 `python fix_ckpt.py` |
| 找不到 VAE 权重 | 路径错误或 VAE 未训练 | 检查 checkpoint 存在并重新训练 |
| TensorBoard 无法启动 | 端口被占用 | 改用其他端口：`tensorboard --port=6007` |
| wheels 安装失败 | 文件不完整或版本不匹配 | 检查 wheels 目录，重新下载 |

### 详细问题排查

#### 1. 数据加载卡死（最常见）

**症状**:
```
Sanity Checking: 0%
(冻结，无进度）
```

**原因**: `num_workers_per_gpu` 过大导致多线程卡死

**解决**:
```python
# configs/comparison/exp_diffusion_vs_fm.py
num_workers_per_gpu = 0  # 改为 0，使用主线程加载
```

#### 2. 显存溢出

**症状**:
```
RuntimeError: CUDA out of memory.
```

**原因**: Batch size 过大或点云点数过多

**解决方案 A**：减小 batch size
```python
batch_size = 16  # 从 32 改为 16
```

**解决方案 B**：减小点云点数
```python
pc_num_points = 512  # 从 1024 改为 512
```

**解决方案 C**：启用梯度累积
```python
# 在 trainer 配置中添加
accumulate_grad_batches = 2
```

#### 3. 训练假死（global_step 不涨）

**症状**:
```
Epoch 5: 100%|██████████| 300/300, Loss: 0.250
Epoch 6: 100%|██████████| 300/300, Loss: 0.250  # Loss 不变
# ... global_step 始终是初始值
```

**原因**: 旧 checkpoint 中的状态问题

**解决**:
```bash
# 清空 checkpoint
rm -rf ./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/

# 或运行修复脚本
python fix_ckpt.py

# 重新训练
python tools/train_generator.py --config ./configs/comparison/exp_diffusion_vs_fm.py --model vae --num-gpus 1 --batch-size 32
```

#### 4. 找不到 VAE 权重

**症状**:
```
FileNotFoundError: [Errno 2] No such file or directory: 'path/to/vae/checkpoints/last.ckpt'
```

**原因**: 
- VAE 尚未训练完成
- 路径配置错误
- 权重被意外删除

**解决**:
```bash
# 1. 检查权重是否存在
ls -la ./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/

# 2. 如果不存在，重新训练 VAE
./run_full_experiment.sh

# 3. 如果使用绝对路径，改为相对路径
# configs/comparison/exp_diffusion_vs_fm.py
shared_vae_ckpt_path = "./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/last.ckpt"
```

#### 5. TensorBoard 无法连接

**症状**:
```
Listening on localhost:6006
# 浏览器无法访问
```

**原因**:
- 端口被占用
- 防火墙阻止
- TensorBoard 进程不在前台

**解决**:
```bash
# 方案 A：改用其他端口
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6007

# 方案 B：后台运行
nohup tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm > tb.log 2>&1 &

# 方案 C：检查占用的端口
lsof -i :6006

# 方案 D：在 WebIDE 中配置端口转发
# 在 WebIDE 设置中配置本地端口映射
```

#### 6. 训练中断恢复

**症状**: 意外终止训练进程

**恢复步骤**:
```bash
# 1. 确保进程已停止
pkill -f train_generator.py
sleep 2
ps -ef | grep train_generator.py

# 2. 修改配置以从检查点恢复
# configs/comparison/exp_diffusion_vs_fm.py
resume_training_from_last = True

# 3. 重新启动（仅运行中断的阶段）
./run_full_experiment.sh --skip-vae  # 如果 VAE 已完成

# 4. 验证恢复
# 应该看到日志: "Restored all states from the checkpoint file"
```

### 获取帮助

如遇到以上未列出的问题：

```bash
# 1. 查看完整日志
cat ./output/comparison/exp_diffusion_vs_fm/vae/logs/*.txt

# 2. 检查 Python 错误堆栈
python tools/train_generator.py --config ./configs/comparison/exp_diffusion_vs_fm.py --model vae --num-gpus 1 -debug

# 3. 验证依赖
pip list | grep -E "torch|pytorch|diffusers"

# 4. 检查硬件
nvidia-smi
df -h  # 磁盘空间
free -h  # 内存
```

---

## 附录：关键文件清单

### 新增脚本

| 文件 | 用途 | 执行权限 |
|------|------|--------|
| `install_offline_deps.sh` | 从 wheels/ 离线安装依赖 | 可执行 |
| `setup_paths.sh` | 修改所有路径为相对路径 | 可执行 |
| `run_full_experiment.sh` | 一键运行完整实验流程 | 可执行 |
| `view_results.sh` | 查看和对比结果 | 可执行 |

### 修改的配置文件

| 文件 | 修改内容 | 备份 |
|------|--------|------|
| `configs/comparison/exp_diffusion_vs_fm.py` | `root_data_dir` 改为相对路径 | `.bak` |
| `fix_ckpt.py` | 硬编码路径改为相对路径 | `.bak` |
| `vae_train_progress.py` | 硬编码路径改为相对路径 | `.bak` |

### 重要训练脚本

| 文件 | 功能 | 使用方法 |
|------|------|--------|
| `tools/train_generator.py` | 模型训练入口 | `python tools/train_generator.py --config ./configs/comparison/exp_diffusion_vs_fm.py --model vae/ddm --num-gpus 1` |
| `tools/generate_grasps.py` | 推理和生成抓取 | `python tools/generate_grasps.py --exp_path ./output/.../vae --mode VAE` |
| `grasp_ldm/trainers/experiment.py` | 实验管理 | 内部使用 |

### 数据目录

| 目录 | 内容 | 大小 |
|------|------|------|
| `./data/ACRONYM/grasps/` | 8837 个 .h5 抓取数据 | ~100 GB |
| `./data/ACRONYM/acronym/` | ACRONYM 工具和脚本 | ~1 GB |
| `./data/ACRONYM/splits/` | 训练/测试分割 | ~10 MB |

### 输出目录

| 目录 | 内容 | 大小估计 |
|------|------|--------|
| `./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/` | VAE 权重和中间检查点 | ~50-100 GB（多个检查点） |
| `./output/comparison/exp_diffusion_vs_fm/vae/logs/` | TensorBoard 日志 | ~1-5 GB |
| `./output/comparison/exp_diffusion_vs_fm/ddm/checkpoints/` | Diffusion 权重 | ~50-100 GB |
| `./output/comparison/exp_diffusion_vs_fm/ddm/logs/` | TensorBoard 日志 | ~1-5 GB |

---

## 总结

### 一键命令汇总

```bash
# 完整部署流程
chmod +x setup_paths.sh install_offline_deps.sh run_full_experiment.sh view_results.sh
./setup_paths.sh
./install_offline_deps.sh
./run_full_experiment.sh

# 查看结果
./view_results.sh --tensorboard

# 高级选项
./run_full_experiment.sh --skip-vae --debug
./view_results.sh --all
```

### 预期结果

训练完成后，将在 `./output/comparison/exp_diffusion_vs_fm/` 中获得：

- ✓ VAE 预训练权重 (`vae/checkpoints/`)
- ✓ Diffusion 模型权重 (`ddm/checkpoints/`)
- ✓ TensorBoard 训练曲线和指标 (`*/logs/`)
- ✓ 配置文件副本 (`*/exp_diffusion_vs_fm.py`)
- ✓ 对比报告 (`REPORT.md`)

---

**版本**: 1.0  
**最后更新**: 2024 年  
**支持环境**: Linux（Ubuntu 18.04+）、Python 3.8+、CUDA 11.1+
