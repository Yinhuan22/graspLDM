# WebIDE 离线部署 graspLDM - 完整文件清单

本文档汇总了为实现离线部署而创建和修改的所有文件。

---

## 📝 新增文件清单

### 脚本文件

#### 1. `install_offline_deps.sh` - 离线依赖安装脚本

**用途**：从 `wheels/` 目录离线安装所有 Python 依赖

**大小**：~5 KB

**使用方法**：
```bash
chmod +x install_offline_deps.sh
./install_offline_deps.sh
```

**功能**：
- ✓ 检查 Python 和 pip
- ✓ 验证 wheels 目录完整性
- ✓ 离线安装所有 .whl 文件
- ✓ 验证关键包安装成功
- ✓ 检查 GPU/CUDA 可用性

---

#### 2. `setup_paths.sh` - 路径配置修改脚本

**用途**：将所有硬编码的绝对路径修改为相对路径

**大小**：~3 KB

**使用方法**：
```bash
chmod +x setup_paths.sh
./setup_paths.sh
```

**修改的文件**：
- `configs/comparison/exp_diffusion_vs_fm.py`
- `fix_ckpt.py`（如果存在）
- `vae_train_progress.py`（如果存在）

**输出**：
- 修改后的配置文件（生效）
- `.bak` 备份文件（可恢复）
- 创建输出目录结构

---

#### 3. `run_full_experiment.sh` - 一键实验运行脚本

**用途**：自动执行完整的 VAE → Diffusion → Flow Matching 训练流程

**大小**：~15 KB

**使用方法**：
```bash
chmod +x run_full_experiment.sh

# 基础运行（执行所有阶段）
./run_full_experiment.sh

# 跳过已完成的阶段
./run_full_experiment.sh --skip-vae
./run_full_experiment.sh --skip-ddm
./run_full_experiment.sh --skip-fm

# 调试模式（详细日志）
./run_full_experiment.sh --debug
```

**实现的功能**：
1. ✓ 环境检查和验证（Python、依赖、GPU、数据集）
2. ✓ 第一阶段：VAE 预训练（180k 步）
3. ✓ 第二阶段：Diffusion 模型训练（180k 步）
4. ✓ 第三阶段：Flow Matching（占位符）
5. ✓ 结果评估和总结

---

#### 4. `view_results.sh` - 结果查看脚本

**用途**：查看、对比和分析实验结果

**大小**：~10 KB

**使用方法**：
```bash
chmod +x view_results.sh

# 显示结果概览
./view_results.sh

# 启动 TensorBoard（查看训练曲线）
./view_results.sh --tensorboard

# 对比模型信息
./view_results.sh --compare

# 生成对比报告
./view_results.sh --report

# 所有操作
./view_results.sh --all
```

**输出内容**：
- 各阶段训练进度和检查点信息
- 模型大小对比表
- TensorBoard 启动和查看指引
- 自动生成的 REPORT.md

---

#### 5. `download_wheels.sh` - wheels 下载脚本（可选）

**用途**：在有网络的环境下下载所有离线依赖

**大小**：~6 KB

**使用场景**：
- 需要在外网环境下提前准备离线包
- 用于初次资源收集

**使用方法**：
```bash
# 在有网络的 Linux 机器上运行
chmod +x download_wheels.sh
./download_wheels.sh

# 输出：
# - graspldm_wheels/          (目录，包含所有 .whl)
# - graspldm_wheels_YYYYMMDD.tar.gz  (tar 压缩包)
# - graspldm_wheels_YYYYMMDD.zip     (zip 压缩包)
```

---

### 文档文件

#### 1. `DEPLOYMENT_GUIDE_CN.md` - 完整部署指南

**大小**：~50 KB

**内容**：
- 快速开始（3 步）
- 详细部署步骤（5 步）
- 离线依赖安装详解
- 配置文件修改说明
- 一键运行实验指南
- 查看实验结果方法
- 详细故障排除（6+ 常见问题）
- 附录：文件清单和命令参考

**推荐阅读**：是理解完整部署流程的必读文档

---

#### 2. `CONFIG_MODIFICATIONS_CN.md` - 配置修改详细指南

**大小**：~30 KB

**内容**：
- 需要修改的文件列表（3 个文件）
- 每个文件的具体修改位置和内容
- 所有配置参数的详细解释
- 5 种常见修改场景和解决方案
- 验证修改的方法
- 回滚修改的方法

**推荐阅读**：需要理解或修改配置时参考

---

#### 3. `QUICK_START_CN.md` - 快速参考卡

**大小**：~15 KB

**内容**：
- 分步部署检查清单
- 一键命令集合
- 时间表和进度预期
- 常见问题速查表（一行式）
- 关键路径速查
- 配置修改要点
- 训练监控方法
- 完成检查清单

**推荐阅读**：第一次部署时参考，问题快速查找

---

## 📝 修改的文件清单

### 配置文件修改

#### 1. `configs/comparison/exp_diffusion_vs_fm.py`

**修改内容**：
```python
# 修改前（硬编码路径）
root_data_dir = "data/ACRONYM"
# 或
root_data_dir = "/path/to/ACRONYM"

# 修改后（相对路径）
root_data_dir = "./data/ACRONYM"
```

**修改位置**：第 18 行

**备份位置**：`configs/comparison/exp_diffusion_vs_fm.py.bak`

**影响范围**：
- VAE 数据加载
- Diffusion 数据加载
- 所有后续的数据相关配置

---

#### 2. `fix_ckpt.py`（可选）

**修改内容**：
```python
# 修改前
ckpt_path = "/home/mi/siat/graspldm/graspLDM/output/comparison/exp_diffusion_vs_fm/vae/checkpoints/last.ckpt"

# 修改后
ckpt_path = "./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/last.ckpt"
```

**修改位置**：第 4 行

**备份位置**：`fix_ckpt.py.bak`

**作用**：修复被错误标记为"已完成"的 checkpoint，恢复训练能力

**使用方法**：
```bash
python fix_ckpt.py  # 自动修复最新的 checkpoint
```

---

#### 3. `vae_train_progress.py`（可选）

**修改内容**：
```python
# 修改前
ckpt_dir = "/home/mi/siat/graspldm/graspLDM/output/comparison/exp_diffusion_vs_fm/vae/checkpoints/"

# 修改后
ckpt_dir = "./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/"
```

**修改位置**：第 8 行

**备份位置**：`vae_train_progress.py.bak`

**作用**：监控 VAE 训练进度和损失函数曲线

**使用方法**：
```bash
python vae_train_progress.py  # 显示训练进度图表
```

---

## 🗂️ 完整文件结构

部署完成后的目录结构：

```
graspLDM/
├── 【新增脚本】
├── install_offline_deps.sh          ✓ 新增（可执行）
├── setup_paths.sh                   ✓ 新增（可执行）
├── run_full_experiment.sh           ✓ 新增（可执行）
├── view_results.sh                  ✓ 新增（可执行）
├── download_wheels.sh               ✓ 新增（可选）
│
├── 【新增文档】
├── DEPLOYMENT_GUIDE_CN.md           ✓ 新增（详细指南）
├── CONFIG_MODIFICATIONS_CN.md       ✓ 新增（配置说明）
├── QUICK_START_CN.md                ✓ 新增（快速参考）
├── 【本文件】                         ✓ 新增（清单）
│
├── 【修改的文件】
├── configs/
│   └── comparison/
│       ├── exp_diffusion_vs_fm.py          ✓ 修改（路径相对）
│       └── exp_diffusion_vs_fm.py.bak      ✓ 备份（原始版本）
├── fix_ckpt.py                              ✓ 修改（路径相对）
├── fix_ckpt.py.bak                          ✓ 备份（原始版本）
├── vae_train_progress.py                    ✓ 修改（路径相对）
├── vae_train_progress.py.bak                ✓ 备份（原始版本）
│
├── 【原始项目文件，无修改】
├── requirements.txt
├── environment.yml
├── setup.py
├── README.md
├── tools/
│   ├── train_generator.py
│   ├── generate_grasps.py
│   └── ...
├── grasp_ldm/
│   ├── models/
│   ├── trainers/
│   ├── dataset/
│   └── ...
├── configs/
│   └── comparison/
│       └── ...
│
├── 【数据和输出目录】
├── data/
│   └── ACRONYM/
│       ├── grasps/                  ✓ 必需（8837 个 .h5 文件）
│       ├── acronym/
│       └── splits/
├── wheels/                          ✓ 必需（离线 .whl 包）
│   ├── torch*.whl
│   ├── torchvision*.whl
│   ├── pytorch-lightning*.whl
│   └── ... (150+ 个 .whl)
│
└── output/                          ✓ 自动创建
    └── comparison/
        └── exp_diffusion_vs_fm/
            ├── vae/
            │   ├── checkpoints/      ✓ VAE 权重输出
            │   ├── logs/             ✓ VAE 日志输出
            │   └── exp_diffusion_vs_fm.py
            ├── ddm/
            │   ├── checkpoints/      ✓ Diffusion 权重输出
            │   ├── logs/             ✓ Diffusion 日志输出
            │   └── exp_diffusion_vs_fm.py
            ├── fm/
            │   ├── checkpoints/      ✓ FM 权重输出（占位）
            │   ├── logs/             ✓ FM 日志输出（占位）
            │   └── exp_diffusion_vs_fm.py
            └── REPORT.md             ✓ 自动生成的报告
```

---

## 📊 文件统计

### 新增文件统计

| 类型 | 数量 | 总大小 |
|------|------|--------|
| Shell 脚本 | 5 | ~40 KB |
| Markdown 文档 | 4 | ~110 KB |
| **总计** | **9** | **~150 KB** |

### 修改文件统计

| 文件 | 修改行数 | 修改内容 | 备份 |
|------|--------|--------|------|
| `exp_diffusion_vs_fm.py` | 1 | 路径相对化 | `.bak` |
| `fix_ckpt.py` | 1 | 路径相对化 | `.bak` |
| `vae_train_progress.py` | 1 | 路径相对化 | `.bak` |
| **总计** | **3** | - | **3** |

---

## 🔄 文件使用顺序

### 初次部署流程

```
1. 确保资源完整
   ├── graspLDM 项目代码 ✓
   ├── ACRONYM 数据集 ✓
   └── wheels 离线包 ✓

2. 运行 setup_paths.sh
   ├── 修改配置文件（相对路径）
   ├── 创建输出目录
   └── 生成 .bak 备份 ✓

3. 运行 install_offline_deps.sh
   ├── 验证 Python 环境
   ├── 检查 wheels 完整性
   ├── 离线安装所有包
   └── 验证关键依赖 ✓

4. 运行 run_full_experiment.sh
   ├── 第一阶段：VAE 预训练（12-24h）
   ├── 第二阶段：Diffusion 训练（12-24h）
   ├── 第三阶段：Flow Matching（占位）
   └── 生成输出和日志 ✓

5. 运行 view_results.sh
   ├── 查看检查点和日志 ✓
   ├── 启动 TensorBoard
   ├── 生成对比报告
   └── 分析实验结果 ✓
```

### 故障排查流程

```
遇到问题时：

1. 查看 QUICK_START_CN.md（快速查找常见问题）
   ↓
2. 参考 DEPLOYMENT_GUIDE_CN.md 的相应章节
   ↓
3. 查看 CONFIG_MODIFICATIONS_CN.md（如涉及配置）
   ↓
4. 检查日志文件和系统状态
   ↓
5. 必要时恢复备份：cp *.bak 原始文件
```

---

## 🚀 快速启动命令

### 一行命令部署

```bash
chmod +x install_offline_deps.sh setup_paths.sh run_full_experiment.sh view_results.sh && \
./setup_paths.sh && \
./install_offline_deps.sh && \
./run_full_experiment.sh
```

### 分步启动

```bash
# 第 1 步：配置（3 分钟）
chmod +x setup_paths.sh && ./setup_paths.sh

# 第 2 步：安装（30-60 分钟）
chmod +x install_offline_deps.sh && ./install_offline_deps.sh

# 第 3 步：训练（24-48 小时）
chmod +x run_full_experiment.sh && ./run_full_experiment.sh

# 第 4 步：查看结果（即时）
chmod +x view_results.sh && ./view_results.sh --tensorboard
```

---

## 📋 验证清单

### 部署前

- [ ] `wheels/` 目录存在，包含 150+ 个 .whl 文件
- [ ] `./data/ACRONYM/grasps/` 包含 8837 个 .h5 文件
- [ ] Python 3.8+ 和 pip 已安装
- [ ] GPU 驱动已安装（nvidia-smi 可用）
- [ ] 磁盘空间 >= 500 GB

### 部署中

- [ ] `./setup_paths.sh` 成功执行
- [ ] `./install_offline_deps.sh` 所有包验证通过
- [ ] `./run_full_experiment.sh` 开始执行
- [ ] 能看到实时训练日志

### 部署后

- [ ] VAE 权重保存到 `./output/.../vae/checkpoints/last.ckpt`
- [ ] Diffusion 权重保存到 `./output/.../ddm/checkpoints/last.ckpt`
- [ ] TensorBoard 日志生成
- [ ] 能查看训练曲线和指标

---

## 🔗 文件关联关系图

```
用户操作
  │
  ├─→ setup_paths.sh ─→ 修改 exp_diffusion_vs_fm.py
  │                  ├─→ 修改 fix_ckpt.py
  │                  └─→ 修改 vae_train_progress.py
  │
  ├─→ install_offline_deps.sh ─→ 从 wheels/ 安装依赖
  │
  ├─→ run_full_experiment.sh ─→ 读取修改后的 exp_diffusion_vs_fm.py
  │                         ├─→ 调用 tools/train_generator.py
  │                         ├─→ 输出到 ./output/.../
  │                         └─→ 生成训练日志
  │
  └─→ view_results.sh ─→ 读取 ./output/ 中的文件
                      ├─→ 启动 TensorBoard
                      └─→ 生成 REPORT.md
```

---

## 📞 获取帮助

遇到问题时按优先级查阅：

1. **本清单**（快速了解文件结构）
2. **QUICK_START_CN.md**（快速查找常见问题）
3. **DEPLOYMENT_GUIDE_CN.md**（详细问题解决方案）
4. **CONFIG_MODIFICATIONS_CN.md**（配置相关问题）
5. **原始文档**：
   - [README.md](README.md)
   - [使用说明.md](使用说明.md)
   - [对比实验详细指南.md](对比实验详细指南.md)

---

**版本**：1.0  
**最后更新**：2024 年  
**支持环境**：Linux (Ubuntu 18.04+)、Python 3.8+、CUDA 11.1+

---

## 附录：文件校验哈希（可选）

如需验证文件完整性，可使用：

```bash
# 计算新增文件的 SHA256 哈希
sha256sum install_offline_deps.sh setup_paths.sh run_full_experiment.sh \
          view_results.sh download_wheels.sh DEPLOYMENT_GUIDE_CN.md \
          CONFIG_MODIFICATIONS_CN.md QUICK_START_CN.md > checksums.txt

# 验证文件完整性
sha256sum -c checksums.txt
```

