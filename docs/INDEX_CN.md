# 📑 GraspLDM WebIDE 离线部署 - 完整资源索引

> 快速导航：根据你的需求，找到合适的文档和脚本

---

## 🚀 快速开始（按阅读顺序）

### 1️⃣ 如果你有 5 分钟
**阅读**: [QUICK_START_CN.md](QUICK_START_CN.md)
- 快速参考卡，一页纸速览
- 分步检查清单
- 常见问题速查表

**结果**: 快速了解部署流程和关键命令

### 2️⃣ 如果你有 30 分钟
**阅读**: [DEPLOYMENT_GUIDE_CN.md](DEPLOYMENT_GUIDE_CN.md) 前 5 章
- 第 0 步：资源准备
- 第 1 步：路径配置（3 分钟）
- 第 2 步：离线安装（30-60 分钟）
- 第 3 步：验证环境（5 分钟）
- 第 4 步：一键运行实验（跳过执行，阅读说明）

**结果**: 充分理解每一步的目的和验证方法

### 3️⃣ 如果你有 2 小时
**阅读**: [DEPLOYMENT_GUIDE_CN.md](DEPLOYMENT_GUIDE_CN.md) 全文
- 完整的分步部署指南（从零开始）
- 详细的故障排除（6+ 常见问题）
- 监控训练进度的方法
- 结果查看和对比的方法

**结果**: 能够独立部署和排查问题

### 4️⃣ 如果你需要修改配置
**阅读**: [CONFIG_MODIFICATIONS_CN.md](CONFIG_MODIFICATIONS_CN.md)
- 每个配置文件的详细修改说明
- 所有参数的解释和调整建议
- 5 种常见修改场景和解决方案
- 验证修改的方法

**结果**: 能够自信地修改任何参数

### 5️⃣ 如果你需要了解项目结构
**阅读**: [FILE_MANIFEST_CN.md](FILE_MANIFEST_CN.md)
- 新增文件的详细说明
- 修改的文件清单
- 完整的文件关联关系图
- 文件使用顺序指南

**结果**: 清晰了解项目的文件结构和依赖关系

---

## 🔧 按需求查找

### 我需要快速部署
```
1. 快速参考: QUICK_START_CN.md
2. 执行命令: chmod +x *.sh && ./setup_paths.sh && ./install_offline_deps.sh && ./run_full_experiment.sh
3. 查看结果: ./view_results.sh --tensorboard
```

### 我需要详细了解部署过程
```
1. 完整指南: DEPLOYMENT_GUIDE_CN.md
2. 逐章阅读，理解每个步骤
3. 遇到问题查看对应章节的故障排除部分
```

### 我需要修改配置参数
```
1. 配置指南: CONFIG_MODIFICATIONS_CN.md
2. 找到对应的"常见修改场景"
3. 按照建议修改配置文件
4. 使用提供的验证方法确认修改成功
```

### 我遇到了问题
```
1. 快速查表: QUICK_START_CN.md 的常见问题速查表
2. 详细解答: DEPLOYMENT_GUIDE_CN.md 的故障排除部分
3. 日志检查: tail -f ./output/comparison/exp_diffusion_vs_fm/*/logs/*.txt
```

### 我想了解整个方案
```
1. 方案总结: SOLUTION_SUMMARY_CN.md
2. 工作流图: 查看本文件中的流程图
3. 文件清单: FILE_MANIFEST_CN.md
```

---

## 📚 文档对照表

### 核心文档（5 个）

| 文档 | 用途 | 大小 | 推荐度 | 阅读时间 |
|------|------|------|--------|--------|
| **QUICK_START_CN.md** | 快速参考卡（一页纸） | 15 KB | ⭐⭐⭐⭐⭐ | 5 分钟 |
| **DEPLOYMENT_GUIDE_CN.md** | 完整部署指南（分步骤） | 50 KB | ⭐⭐⭐⭐⭐ | 1 小时 |
| **CONFIG_MODIFICATIONS_CN.md** | 配置修改详细说明 | 30 KB | ⭐⭐⭐⭐ | 30 分钟 |
| **FILE_MANIFEST_CN.md** | 文件清单和使用指南 | 25 KB | ⭐⭐⭐⭐ | 20 分钟 |
| **SOLUTION_SUMMARY_CN.md** | 方案总体总结 | 20 KB | ⭐⭐⭐⭐ | 15 分钟 |

### 可执行脚本（5 个）

| 脚本 | 用途 | 执行时间 | 优先级 |
|------|------|--------|--------|
| **setup_paths.sh** | 路径配置修改 | 3 分钟 | 必须 |
| **install_offline_deps.sh** | 离线依赖安装 | 30-60 分钟 | 必须 |
| **run_full_experiment.sh** | 一键运行实验 | 24-48 小时 | 必须 |
| **view_results.sh** | 结果查看和对比 | 1-5 分钟 | 必须 |
| **download_wheels.sh** | 下载离线包（可选） | 2-4 小时 | 可选 |

---

## 🎯 按场景导航

### 场景 1：首次部署，从零开始

**步骤**：
1. 阅读 [QUICK_START_CN.md](QUICK_START_CN.md) 的"分步部署检查清单"（5 分钟）
2. 阅读 [DEPLOYMENT_GUIDE_CN.md](DEPLOYMENT_GUIDE_CN.md) 的"详细部署步骤"（30 分钟）
3. 按步骤执行脚本：
   ```bash
   chmod +x setup_paths.sh install_offline_deps.sh run_full_experiment.sh view_results.sh
   ./setup_paths.sh
   ./install_offline_deps.sh
   ./run_full_experiment.sh
   ./view_results.sh --tensorboard
   ```

**预期耗时**：总计 24-48+ 小时（主要是模型训练）

---

### 场景 2：在同事的基础上继续

**步骤**：
1. 检查前面的工作进度
2. 根据进度选择：
   - 如果 VAE 已完成：`./run_full_experiment.sh --skip-vae`
   - 如果都完成：`./view_results.sh --tensorboard`
3. 查看 [DEPLOYMENT_GUIDE_CN.md#中断和恢复](DEPLOYMENT_GUIDE_CN.md#第-4-步一键运行完整实验) 的恢复指南

**预期耗时**：取决于完成情况，通常 12-24 小时

---

### 场景 3：需要调整参数

**步骤**：
1. 阅读 [CONFIG_MODIFICATIONS_CN.md](CONFIG_MODIFICATIONS_CN.md) 的相关部分
2. 编辑 `configs/comparison/exp_diffusion_vs_fm.py`
3. 运行验证命令（脚本中提供）
4. 如有问题，参考 [CONFIG_MODIFICATIONS_CN.md#回滚修改](CONFIG_MODIFICATIONS_CN.md#回滚修改)

**预期耗时**：5-20 分钟

---

### 场景 4：遇到问题

**排查步骤**：
1. 查看 [QUICK_START_CN.md](QUICK_START_CN.md) 的"常见问题速查表"
2. 如果没有找到，查看 [DEPLOYMENT_GUIDE_CN.md](DEPLOYMENT_GUIDE_CN.md) 的"故障排除"部分
3. 按照建议进行排查和修复

**预期耗时**：5-30 分钟

---

### 场景 5：在生产环境中使用

**步骤**：
1. 参考 [DEPLOYMENT_GUIDE_CN.md](DEPLOYMENT_GUIDE_CN.md) 的完整指南进行部署
2. 按 [FILE_MANIFEST_CN.md](FILE_MANIFEST_CN.md) 备份所有关键文件
3. 定期使用 `./view_results.sh --report` 生成报告
4. 保持 TensorBoard 持续运行监控训练

**预期耗时**：首次 1-2 小时配置，后续 24-48 小时训练

---

## 📖 深度学习路径

### 路径 A：快速上手（推荐新手）

```
QUICK_START_CN.md (5 min)
       ↓
执行脚本（48h）
       ↓
view_results.sh (5 min)
       ↓
完成！
```

### 路径 B：系统理解（推荐初学者）

```
QUICK_START_CN.md (5 min)
       ↓
DEPLOYMENT_GUIDE_CN.md (1 hour)
       ↓
执行脚本（48h）
       ↓
CONFIG_MODIFICATIONS_CN.md (如需调参)
       ↓
完成！
```

### 路径 C：完全掌握（推荐进阶）

```
SOLUTION_SUMMARY_CN.md (15 min)
       ↓
DEPLOYMENT_GUIDE_CN.md (1 hour)
       ↓
CONFIG_MODIFICATIONS_CN.md (30 min)
       ↓
FILE_MANIFEST_CN.md (20 min)
       ↓
执行脚本（48h）
       ↓
视情况修改参数、排查问题
       ↓
完全掌握所有方面！
```

---

## 🔍 按关键词快速查找

### 关键词：路径、相对路径
→ [CONFIG_MODIFICATIONS_CN.md#修改内容](CONFIG_MODIFICATIONS_CN.md)  
→ [DEPLOYMENT_GUIDE_CN.md#第-1-步修改配置文件路径](DEPLOYMENT_GUIDE_CN.md#第-1-步修改配置文件路径)

### 关键词：显存、CUDA out of memory
→ [QUICK_START_CN.md#常见问题速查](QUICK_START_CN.md#-常见问题速查)  
→ [DEPLOYMENT_GUIDE_CN.md#详细问题排查](DEPLOYMENT_GUIDE_CN.md#详细问题排查)  
→ [CONFIG_MODIFICATIONS_CN.md#场景-1显存不足](CONFIG_MODIFICATIONS_CN.md#场景-1显存不足)

### 关键词：数据加载、卡死、Sanity Checking
→ [DEPLOYMENT_GUIDE_CN.md#数据加载卡死最常见](DEPLOYMENT_GUIDE_CN.md#1-数据加载卡死最常见)  
→ [QUICK_START_CN.md#常见问题速查](QUICK_START_CN.md#-常见问题速查)

### 关键词：训练假死、global_step、Loss 不变
→ [DEPLOYMENT_GUIDE_CN.md#训练假死global_step-不涨](DEPLOYMENT_GUIDE_CN.md#3-训练假死global_step-不涨)  
→ [使用说明.md#假训练](使用说明.md#21-假训练global_step-不涨loss-飙升)

### 关键词：恢复训练、checkpoint、中断
→ [DEPLOYMENT_GUIDE_CN.md#中断和恢复](DEPLOYMENT_GUIDE_CN.md#43-中断和恢复)  
→ [CONFIG_MODIFICATIONS_CN.md#场景-4需要恢复中断的训练](CONFIG_MODIFICATIONS_CN.md#场景-4需要恢复中断的训练)

### 关键词：VAE 权重、预训练、checkpoint 路径
→ [CONFIG_MODIFICATIONS_CN.md#场景-5使用预训练的-vae-权重](CONFIG_MODIFICATIONS_CN.md#场景-5使用预训练的-vae-权重)

### 关键词：TensorBoard、日志、训练曲线
→ [DEPLOYMENT_GUIDE_CN.md#方法-2-手动启动-tensorboard](DEPLOYMENT_GUIDE_CN.md#方法-2-手动启动-tensorboard)  
→ [QUICK_START_CN.md#tensorboard-实时曲线](QUICK_START_CN.md#tensorboard-实时曲线)

### 关键词：wheels、离线包、依赖
→ [DEPLOYMENT_GUIDE_CN.md#离线依赖安装](DEPLOYMENT_GUIDE_CN.md#离线依赖安装)  
→ [QUICK_START_CN.md#第-2-步离线安装60-分钟](QUICK_START_CN.md#第-2-步离线安装30-60-分钟)

### 关键词：配置修改、参数调整
→ [CONFIG_MODIFICATIONS_CN.md](CONFIG_MODIFICATIONS_CN.md)  
→ [DEPLOYMENT_GUIDE_CN.md#配置文件修改](DEPLOYMENT_GUIDE_CN.md#配置文件修改)

---

## 📋 完整命令速查

### 快速启动

```bash
# 完整自动化（最简单）
chmod +x *.sh && ./setup_paths.sh && ./install_offline_deps.sh && ./run_full_experiment.sh && ./view_results.sh --tensorboard

# 分步启动
chmod +x *.sh
./setup_paths.sh          # 3 分钟
./install_offline_deps.sh # 30-60 分钟
./run_full_experiment.sh  # 24-48 小时
./view_results.sh --tensorboard  # 即时
```

### 高级选项

```bash
# 跳过已完成的阶段
./run_full_experiment.sh --skip-vae
./run_full_experiment.sh --skip-ddm

# 调试模式
./run_full_experiment.sh --debug

# 查看结果的不同方式
./view_results.sh              # 概览
./view_results.sh --tensorboard  # TensorBoard
./view_results.sh --compare       # 模型对比
./view_results.sh --report        # 生成报告
./view_results.sh --all           # 所有操作
```

### 监控和调试

```bash
# 实时监控 GPU
watch -n 1 nvidia-smi

# 查看最新日志
tail -f ./output/comparison/exp_diffusion_vs_fm/vae/logs/*.txt

# 查看磁盘使用
du -sh ./output/comparison/exp_diffusion_vs_fm/*/checkpoints

# 验证环境
python -c "import torch, pytorch_lightning; print('✓ OK')"
```

---

## ✅ 验证清单

### 部署前
- [ ] graspLDM 代码完整（~2 GB）
- [ ] ACRONYM 数据完整（~100 GB）
- [ ] wheels 离线包完整（50-100 GB）
- [ ] Python 3.8+ 已安装
- [ ] GPU 驱动已安装

### 部署中
- [ ] setup_paths.sh 成功执行
- [ ] install_offline_deps.sh 所有依赖验证通过
- [ ] run_full_experiment.sh 开始执行
- [ ] 能看到实时训练进度

### 部署后
- [ ] VAE 权重已保存
- [ ] Diffusion 权重已保存
- [ ] TensorBoard 日志已生成
- [ ] 能查看训练曲线

---

## 🆘 紧急求助

遇到问题时，按这个顺序查找：

1. **快速查表** (5 秒) → [QUICK_START_CN.md 常见问题](QUICK_START_CN.md#-常见问题速查)
2. **详细排查** (5 分钟) → [DEPLOYMENT_GUIDE_CN.md 故障排除](DEPLOYMENT_GUIDE_CN.md#故障排除)
3. **深度理解** (30 分钟) → 相关的详细文档
4. **日志分析** (10 分钟) → `tail -f ./output/.../logs/*.txt`

---

## 📞 获取更多帮助

### 内部文档
- 原项目文档：[README.md](README.md)、[使用说明.md](使用说明.md)、[对比实验详细指南.md](对比实验详细指南.md)

### 外部资源
- **GraspLDM GitHub**：https://github.com/kuldeepbarad/GraspLDM
- **ACRONYM 数据集**：https://github.com/NVlabs/acronym
- **PyTorch Lightning**：https://pytorch-lightning.readthedocs.io/
- **Diffusers 库**：https://huggingface.co/docs/diffusers/

---

## 🎯 成功指标

部署成功的标志：
- ✅ 所有脚本可以正常执行
- ✅ VAE 权重成功保存
- ✅ Diffusion 模型成功训练
- ✅ TensorBoard 可以正常查看
- ✅ 训练曲线显示合理的趋势

---

**最后更新**：2024 年  
**版本**：1.0  
**总文档数**：10 个（5 个脚本 + 5 个文档）  
**总大小**：~200 KB 文档 + 脚本

🎉 **祝你使用愉快！**
