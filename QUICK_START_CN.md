# GraspLDM WebIDE 离线部署 - 快速参考卡

## 📋 分步部署检查清单

### 第 0 步：资源准备

```
☐ graspLDM 项目代码（graspLDM.zip 解压）
  - 包含 configs/、tools/、grasp_ldm/ 等目录
  
☐ ACRONYM 数据集完整
  - ./data/ACRONYM/grasps/ 有 8837 个 .h5 文件
  - 总大小 ~100GB
  
☐ wheels 离线包完整
  - ./wheels/ 目录存在
  - 包含 torch、pytorch-lightning、diffusers 等 150+ 个 .whl 文件
  - 总大小 50-100GB
  
☐ 硬件环保
  - Python 3.8+ 已安装
  - GPU 驱动已安装（nvidia-smi 可用）
  - 磁盘空间 >= 500GB
```

### 第 1 步：路径配置（3 分钟）

```bash
# 1. 给脚本执行权限
chmod +x setup_paths.sh install_offline_deps.sh run_full_experiment.sh view_results.sh

# 2. 修改所有路径为相对路径
./setup_paths.sh

# ✓ 预期输出：
# [SUCCESS] ✓ 已修改数据目录为相对路径
# [SUCCESS] ✓ 已修改 fix_ckpt.py
# [SUCCESS] ✓ 目录结构创建完成
```

### 第 2 步：离线安装（30-60 分钟）

```bash
# 1. 安装所有离线依赖
./install_offline_deps.sh

# ✓ 预期输出：
# [SUCCESS] 找到 150 个 .whl 文件
# [SUCCESS] torch (v1.13.1) ✓
# [SUCCESS] pytorch-lightning (v1.8.6) ✓
# [SUCCESS] GPU: NVIDIA RTX 4090 ✓
```

### 第 3 步：验证环境（5 分钟）

```bash
# 验证关键依赖
python -c "
import torch
import pytorch_lightning
import diffusers
import h5py
print('✓ 所有关键包已安装')
print(f'CUDA 可用: {torch.cuda.is_available()}')
"

# 验证数据集
find ./data/ACRONYM/grasps -name "*.h5" | wc -l
# 应该输出: 8837 (或接近)
```

### 第 4 步：运行实验（24-48 小时）

```bash
# 一键运行完整实验（VAE → Diffusion）
./run_full_experiment.sh

# 或跳过已完成的阶段
./run_full_experiment.sh --skip-vae      # 仅训练 Diffusion
./run_full_experiment.sh --skip-ddm      # 仅训练 VAE
./run_full_experiment.sh --debug         # 详细日志
```

### 第 5 步：查看结果（即时）

```bash
# 启动 TensorBoard（实时查看训练曲线）
./view_results.sh --tensorboard
# 然后在浏览器打开：http://localhost:6006

# 对比模型信息
./view_results.sh --compare

# 生成完整报告
./view_results.sh --report
```

---

## 🚀 一键命令

```bash
# 完整部署流程（从零开始）
chmod +x *.sh
./setup_paths.sh && ./install_offline_deps.sh && ./run_full_experiment.sh

# 快速查看结果
./view_results.sh --tensorboard
```

---

## 📊 实验流程时间表

| 阶段 | 耗时（RTX 4090） | 输出位置 |
|------|-----------------|--------|
| 路径配置 | 3 分钟 | - |
| 依赖安装 | 30-60 分钟 | - |
| **VAE 预训练** | **12-24 小时** | `./output/.../vae/checkpoints/` |
| **Diffusion 训练** | **12-24 小时** | `./output/.../ddm/checkpoints/` |
| **Flow Matching** | ⏳ 待实现 | `./output/.../fm/checkpoints/` |
| 结果查看 | 1-5 分钟 | TensorBoard |
| **总计** | **24-48+ 小时** | - |

---

## 🔧 常见问题速查

| 问题 | 症状 | 解决方案 |
|------|------|--------|
| **数据加载卡死** | 停在 `Sanity Checking: 0%` | 设置 `num_workers_per_gpu = 0` |
| **显存溢出** | `CUDA out of memory` | 减小 `batch_size` 或 `pc_num_points` |
| **训练假死** | Loss 不变，global_step 不涨 | `python fix_ckpt.py` 或删除旧 checkpoint |
| **找不到 VAE 权重** | `FileNotFoundError` | 检查 `./output/comparison/.../vae/checkpoints/` |
| **TensorBoard 无法连接** | 浏览器无法访问 http://localhost:6006 | 改用其他端口：`tensorboard --port=6007` |
| **wheels 安装失败** | `pip: no such file` 或版本不匹配 | 检查 wheels 目录完整性 |

**详细解决方案** → 见 [DEPLOYMENT_GUIDE_CN.md](DEPLOYMENT_GUIDE_CN.md#故障排除)

---

## 📁 关键路径速查

```
项目根目录 (graspLDM/)
├── data/ACRONYM/                           ← 数据集
│   └── grasps/                             ← 8837 个 .h5 文件
├── wheels/                                 ← 离线依赖包
├── configs/comparison/                     ← 配置文件
│   └── exp_diffusion_vs_fm.py             ← 修改这个
├── output/comparison/exp_diffusion_vs_fm/  ← 输出目录
│   ├── vae/checkpoints/                    ← VAE 权重
│   ├── vae/logs/                           ← VAE 日志
│   ├── ddm/checkpoints/                    ← Diffusion 权重
│   └── ddm/logs/                           ← Diffusion 日志
└── tools/train_generator.py                ← 训练入口
```

---

## 🎯 配置修改要点

**文件**：`configs/comparison/exp_diffusion_vs_fm.py`

```python
# 必改：数据路径（相对）
root_data_dir = "./data/ACRONYM"

# 必改：数据加载线程数（必须为 0）
num_workers_per_gpu = 0

# 可选：调整 batch size（显存不足改为 16）
batch_size = 32

# 可选：调整点云点数（显存不足改为 512）
pc_num_points = 1024

# 可选：恢复训练
resume_training_from_last = True  # 改为 True 时自动从最后 checkpoint 恢复
```

**验证修改**：
```bash
grep "root_data_dir\|num_workers_per_gpu" configs/comparison/exp_diffusion_vs_fm.py
```

---

## 📈 监控训练进度

### 实时监控

```bash
# 终端 1：运行实验
./run_full_experiment.sh

# 终端 2：监控 GPU 使用（每秒更新）
watch -n 1 nvidia-smi

# 终端 3：查看最新日志
tail -f ./output/comparison/exp_diffusion_vs_fm/vae/logs/*.txt

# 终端 4：监控磁盘
watch -n 10 'du -sh ./output/comparison/exp_diffusion_vs_fm/*/checkpoints'
```

### TensorBoard 实时曲线

```bash
# 启动 TensorBoard
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --host=0.0.0.0 --port=6006

# 浏览器打开
http://localhost:6006

# 关闭 TensorBoard
Ctrl+C
```

---

## 💾 输出文件大小估计

| 文件 | 大小 | 说明 |
|------|------|------|
| VAE checkpoint | 200-500 MB | 单个 checkpoint |
| VAE 所有 checkpoint | 10-50 GB | 多个中间 checkpoint |
| VAE 日志 | 1-5 GB | TensorBoard events |
| Diffusion checkpoint | 200-500 MB | 单个 checkpoint |
| Diffusion 日志 | 1-5 GB | TensorBoard events |
| **总计** | **20-110 GB** | 取决于保存的 checkpoint 数 |

---

## ✅ 完成检查清单

```
实验完成标记：
☐ VAE 权重保存到 ./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/last.ckpt
☐ Diffusion 权重保存到 ./output/comparison/exp_diffusion_vs_fm/ddm/checkpoints/last.ckpt
☐ TensorBoard 日志存在
☐ 可以查看训练曲线和指标
☐ 生成了对比报告 REPORT.md

下一步（可选）：
☐ 运行推理脚本生成抓取
☐ 对比两种方法的性能
☐ 调整参数进行二次实验
```

---

## 🔗 重要文档链接

| 文档 | 用途 |
|------|------|
| [DEPLOYMENT_GUIDE_CN.md](DEPLOYMENT_GUIDE_CN.md) | 详细部署指南（推荐阅读） |
| [CONFIG_MODIFICATIONS_CN.md](CONFIG_MODIFICATIONS_CN.md) | 配置修改详细说明 |
| [README.md](README.md) | 项目原始说明 |
| [使用说明.md](使用说明.md) | 原项目使用说明 |
| [对比实验详细指南.md](对比实验详细指南.md) | 原实验流程文档 |

---

## 📞 获取帮助

遇到问题时的排查步骤：

1. **查看快速参考卡**（本文档）找常见问题
2. **查看详细部署指南** → [DEPLOYMENT_GUIDE_CN.md](DEPLOYMENT_GUIDE_CN.md#故障排除)
3. **查看配置修改指南** → [CONFIG_MODIFICATIONS_CN.md](CONFIG_MODIFICATIONS_CN.md)
4. **检查日志文件**：
   ```bash
   # 显示最新 100 行日志
   tail -100 ./output/comparison/exp_diffusion_vs_fm/vae/logs/*.txt
   ```
5. **验证依赖完整性**：
   ```bash
   ./install_offline_deps.sh  # 重新验证
   ```

---

**最后更新**：2024 年  
**推荐环境**：Ubuntu 18.04+、Python 3.8+、CUDA 11.1+、RTX 4090  
**预计完成时间**：24-48 小时（包括训练）

🎉 **祝部署顺利！**
