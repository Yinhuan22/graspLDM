# 配置文件修改详细指南

本文档提供所有需要修改的配置文件和代码变更的详细说明。

---

## 文件修改清单

### 1. 主配置文件：`configs/comparison/exp_diffusion_vs_fm.py`

**修改内容**：将所有硬编码路径改为相对路径

**修改位置**：第 18-21 行

**修改前**：
```python
root_data_dir = "data/ACRONYM"
```

**修改后**（已是相对路径，无需修改）：
```python
root_data_dir = "./data/ACRONYM"
```

---

### 2. Checkpoint 修复脚本：`fix_ckpt.py`

**目的**：修复被错误标记为"已完成"的 checkpoint，恢复训练能力

**修改位置**：第 4 行

**修改前**：
```python
ckpt_path = "/home/mi/siat/graspldm/graspLDM/output/comparison/exp_diffusion_vs_fm/vae/checkpoints/last.ckpt"
```

**修改后**：
```python
ckpt_path = "./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/last.ckpt"
```

**使用方法**：
```bash
python fix_ckpt.py  # 自动修复最新的 checkpoint
```

---

### 3. 训练进度查看脚本：`vae_train_progress.py`

**目的**：监控 VAE 训练进度和损失函数曲线

**修改位置**：第 8 行

**修改前**：
```python
ckpt_dir = "/home/mi/siat/graspldm/graspLDM/output/comparison/exp_diffusion_vs_fm/vae/checkpoints/"
```

**修改后**：
```python
ckpt_dir = "./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/"
```

**使用方法**：
```bash
python vae_train_progress.py  # 显示训练进度图表
```

---

## 配置参数详解

### VAE 训练参数

在 `configs/comparison/exp_diffusion_vs_fm.py` 中的 VAE 相关参数：

```python
# ========== 基础训练参数 ==========
max_steps = 180000              # 最大训练步数
batch_size = 32                 # 每个 GPU 的 batch size
num_gpus = 1                    # 使用的 GPU 数量
num_workers_per_gpu = 0         # 数据加载线程数（重要：必须为 0）
resume_training_from_last = False  # 是否从上次中断处恢复

# ========== 点云处理参数 ==========
pc_num_points = 1024            # 采样点数
pc_latent_dims = 64             # 点云编码维度
pc_latent_channels = 3          # 点云特征通道数

# ========== 抓取表示参数 ==========
grasp_pose_dims = 6             # 抓取位姿维度（3 平移 + 3 旋转）
num_output_qualities = 0        # 输出的质量维度
grasp_latent_dims = 4           # 抓取隐向量维度
```

### Diffusion 模型参数

```python
denoiser_model = dict(
    type="TimeConditionedResNet1D",
    args=dict(
        dim=grasp_latent_dims,                    # 输入隐向量维度
        channels=1,                               # 时间条件通道数
        block_channels=(32, 64, 128, 256),       # ResNet 块通道数
        input_conditioning_dims=pc_latent_dims,  # 条件输入维度
        resnet_block_groups=4,                   # ResNet 组归一化组数
        dropout=dropout,                         # Dropout 概率
        is_time_conditioned=True,                # 是否时间条件
        learned_variance=False,                  # 是否学习方差
        random_fourier_features=True,            # 使用随机傅里叶特征
    ),
)

model = dict(
    ddm=dict(
        model=dict(
            type="GraspLatentDDM",
            args=dict(
                latent_in_features=grasp_latent_dims,
                diffusion_timesteps=1000,           # 扩散步数
                noise_scheduler_type="ddpm",        # 噪声调度类型
                diffusion_loss="l2",                # 扩散损失（L2 或 L1）
                beta_schedule="linear",             # beta 调度类型
                is_conditioned=True,                # 是否条件化
                joint_training=False,               # 是否联合训练
                denoising_loss_weight=1,            # 去噪损失权重
                variance_type="fixed_large",       # 方差类型
                beta_start=0.00005,                 # 初始 beta
                beta_end=0.001,                     # 最终 beta
            ),
        ),
        ckpt_path=ddm_ckpt_path,
        use_vae_ema_model=True,                 # 使用 VAE EMA 模型
    ),
)
```

### 数据集配置

```python
# 数据路径（重要：使用相对路径）
root_data_dir = "./data/ACRONYM"

# 训练数据配置
train_data = dict(
    type="AcronymShapenetPointclouds",
    args=dict(
        data_root_dir=root_data_dir,
        batch_num_points_per_pc=pc_num_points,       # 每个点云的点数
        batch_num_grasps_per_pc=100,                 # 每个物体的抓取数
        rotation_repr="mrp",                         # 旋转表示（MRP）
        split="train",                               # 数据分割（训练/验证/测试）
        batch_failed_grasps_ratio=0,                 # 失败抓取比例
        use_dataset_statistics_for_norm=False,       # 是否使用数据集统计归一化
        filter_categories=None,                      # 物体类别过滤（None=使用全部）
        load_fixed_subset_grasps_per_obj=None,      # 每个物体固定加载的抓取数
        num_repeat_dataset=10,                       # 数据集重复次数（增加训练样本）
    ),
)
```

### 数据增强配置

```python
augs_config = [
    # 随机旋转：50% 概率，最大 180 度
    dict(type="RandomRotation", args=dict(p=0.5, max_angle=180, is_degree=True)),
    
    # 点云抖动：100% 概率，标准差 0.005，裁剪 0.005
    dict(type="PointcloudJitter", args=dict(p=1, sigma=0.005, clip=0.005)),
    
    # 随机点云丢弃：50% 概率，最多丢弃 40% 的点
    dict(type="RandomPointcloudDropout", args=dict(p=0.5, max_dropout_ratio=0.4)),
]
```

### 损失函数配置

```python
loss_config = dict(
    # 重构损失：L2 损失，平衡平移和旋转
    reconstruction_loss=dict(
        type="GraspReconstructionLoss",
        name="reconstruction_loss",
        args=dict(translation_weight=1, rotation_weight=1),
    ),
    
    # VAE 隐空间损失：KL 散度 + 周期退火
    latent_loss=dict(
        type="VAELatentLoss",
        args=dict(
            name="grasp_latent",
            cyclical_annealing=True,           # 使用周期退火
            num_steps=max_steps,               # 退火周期=总步数
            num_cycles=1,                      # 1 个完整周期
            ratio=0.5,                         # 前 50% 为升温期
            start=1e-7,                        # 初始权重
            stop=0.1,                          # 最终权重
        ),
    ),
    
    # 分类损失（可选）
    classification_loss=dict(type="ClassificationLoss", args=dict(weight=0.1)),
)
```

### Logger 配置

```python
# TensorBoard Logger（本地训练推荐）
logger = dict(type="TensorBoardLogger")

# 或使用 WandB（需要网络）
# logger = dict(type="WandBLogger", args=dict(project="graspldm"))
```

---

## 常见配置修改场景

### 场景 1：显存不足

**症状**：`CUDA out of memory`

**解决方案**：
```python
# 减小 batch size
batch_size = 16  # 从 32 改为 16

# 或减小点云点数
pc_num_points = 512  # 从 1024 改为 512

# 或都减小
batch_size = 16
pc_num_points = 512
```

**预期效果**：
- batch_size 16: 显存使用减半
- pc_num_points 512: 显存使用减半
- 两者都改: 显存使用减少 75%

### 场景 2：训练速度过慢

**症状**：每个 step 耗时超过 5 秒

**解决方案 A**：使用多线程加载数据（需要足够 RAM）
```python
num_workers_per_gpu = 4  # 从 0 改为 4
```

**解决方案 B**：减小验证频率
```python
# 在 trainer 配置中添加
check_val_every_n_epoch = 20  # 从 10 改为 20
```

**解决方案 C**：增加梯度累积
```python
# 在 trainer 配置中添加
accumulate_grad_batches = 2  # 每 2 个 step 更新一次权重
```

### 场景 3：训练过程中数据加载卡死

**症状**：停在 `Sanity Checking: 0%`，不进展

**解决方案**（唯一）：
```python
num_workers_per_gpu = 0  # 必须为 0，使用主线程加载
```

**原因**：多线程 I/O 可能导致死锁

### 场景 4：需要恢复中断的训练

**修改方案**：
```python
# 修改前
resume_training_from_last = False

# 修改后
resume_training_from_last = True  # 从上次 checkpoint 恢复
```

**使用方法**：
```bash
python tools/train_generator.py \
    --config ./configs/comparison/exp_diffusion_vs_fm.py \
    --model vae \
    --num-gpus 1 \
    --batch-size 32
# 会自动加载 ./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/last.ckpt
```

### 场景 5：使用预训练的 VAE 权重

**修改方案**：
```python
# 方案 A：使用本地权重（推荐）
shared_vae_ckpt_path = "./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/last.ckpt"

# 方案 B：使用自定义路径
vae_ckpt_path = "./path/to/custom/vae.ckpt"
```

**使用方法**：
```bash
# 训练 Diffusion 时会自动加载指定的 VAE 权重
python tools/train_generator.py \
    --config ./configs/comparison/exp_diffusion_vs_fm.py \
    --model ddm \
    --num-gpus 1 \
    --batch-size 32
```

---

## 验证配置修改

### 检查点 1：路径验证

```bash
# 验证数据集存在
test -d ./data/ACRONYM && echo "✓ 数据集路径正确" || echo "✗ 数据集路径错误"

# 验证配置文件正确
grep "root_data_dir" configs/comparison/exp_diffusion_vs_fm.py
# 应该输出: root_data_dir = "./data/ACRONYM"
```

### 检查点 2：导入配置

```bash
# 测试配置是否能正确加载
python -c "
import sys
sys.path.insert(0, '.')
from grasp_ldm.utils.config import Config
cfg = Config.fromfile('./configs/comparison/exp_diffusion_vs_fm.py')
print(f'Data root: {cfg.root_data_dir}')
print(f'Batch size: {cfg.batch_size}')
print(f'Max steps: {cfg.max_steps}')
"
```

### 检查点 3：参数数量

```bash
# 验证模型参数
python tools/train_generator.py \
    --config ./configs/comparison/exp_diffusion_vs_fm.py \
    --model vae \
    --num-gpus 1 \
    --batch-size 32 \
    2>&1 | grep -i "total.*param\|trainable"
```

---

## 回滚修改

如果需要恢复原始配置：

```bash
# 查看备份文件
ls -la configs/comparison/exp_diffusion_vs_fm.py.bak

# 恢复
cp configs/comparison/exp_diffusion_vs_fm.py.bak configs/comparison/exp_diffusion_vs_fm.py
```

---

## 总结表格

| 文件 | 修改内容 | 修改点 | 验证方法 |
|------|--------|--------|--------|
| `configs/comparison/exp_diffusion_vs_fm.py` | `root_data_dir` 路径 | `root_data_dir = "./data/ACRONYM"` | `grep root_data_dir` |
| `fix_ckpt.py` | checkpoint 路径 | `ckpt_path = "./output/..."` | `python fix_ckpt.py` |
| `vae_train_progress.py` | checkpoint 目录 | `ckpt_dir = "./output/..."` | `python vae_train_progress.py` |
| 训练命令 | 配置文件路径 | `--config ./configs/...` | `python tools/train_generator.py` |

---

**注意**：所有修改完成后，立即运行 `./run_full_experiment.sh` 进行验证。
