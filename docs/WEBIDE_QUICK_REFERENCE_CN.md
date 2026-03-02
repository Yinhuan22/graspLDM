# WebIDE 查看实验结果 - 快速参考卡

## 🚀 5 秒钟快速开始

```bash
# 方法 1：启动 TensorBoard（最推荐）
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006

# 在浏览器打开：http://localhost:6006
```

## 📊 完整命令清单

### TensorBoard（训练曲线、损失函数）

| 目标 | 命令 | 浏览器地址 |
|------|------|----------|
| 查看所有模型 | `tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006` | http://localhost:6006 |
| 仅 VAE | `tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/vae/logs --port=6006` | http://localhost:6006 |
| 仅 Diffusion | `tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/ddm/logs --port=6007` | http://localhost:6007 |
| 仅 FM | `tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/fm/logs --port=6008` | http://localhost:6008 |

### 查看 CSV 表格（对比数据）

```bash
# 方法 1：Python 脚本（推荐，格式美观）
python3 view_csv_results.py

# 方法 2：命令行（快速查看）
cat ./output/comparison/exp_diffusion_vs_fm/comparison_results/comparison_table.csv | column -t -s,

# 方法 3：VS Code 打开（直接打开文件）
# 在 VS Code 中打开: output/comparison/exp_diffusion_vs_fm/comparison_results/comparison_table.csv
```

### 查看 PNG 图片（可视化结果）

```bash
# 方法 1：VS Code 预览（最方便）
# 在 VS Code 文件浏览器中导航到:
# output/comparison/exp_diffusion_vs_fm/comparison_results/visualization/
# 双击任何 .png 文件

# 方法 2：生成 HTML 查看器（推荐）
python3 generate_visualization_html.py
# 然后在浏览器打开: ./output/comparison/visualization_viewer.html

# 方法 3：HTTP 服务器（支持多用户访问）
python3 -m http.server 8000
# 浏览器打开: http://localhost:8000/output/comparison/visualization_viewer.html
```

### 打包下载结果

```bash
# 方法 1：一键打包（推荐）
chmod +x package_results.sh
./package_results.sh

# 方法 2：手动 tar 打包
tar -czf graspldm_results_$(date +%Y%m%d_%H%M%S).tar.gz \
  ./output/comparison/exp_diffusion_vs_fm/comparison_results \
  ./output/logs

# 从本地下载
scp user@webide_host:*/graspldm_results_*.tar.gz ~/downloads/
```

### 一键工具菜单

```bash
# 启动综合查看工具（推荐新手）
chmod +x view_all_results.sh
./view_all_results.sh
```

---

## 🎯 常见场景

### 场景 1：我想看训练过程中的损失函数曲线

```bash
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006
# 浏览器打开：http://localhost:6006
# 在 Scalars 标签页中查看 loss 曲线
```

### 场景 2：我想对比 VAE vs Diffusion vs FM 的性能数据

```bash
# 打开 CSV 表格
python3 view_csv_results.py

# 或者在 VS Code 中打开：
# output/comparison/exp_diffusion_vs_fm/comparison_results/comparison_table.csv
```

### 场景 3：我想看成功率对比、准确率对比等图表

```bash
# 方法 A：在 VS Code 中查看（最快）
# 导航到: output/comparison/exp_diffusion_vs_fm/comparison_results/visualization/
# 双击 PNG 文件即可预览

# 方法 B：生成 HTML 查看器（支持放大、浏览器支持）
python3 generate_visualization_html.py
# 浏览器打开：./output/comparison/visualization_viewer.html
```

### 场景 4：我想把所有结果下载到本地

```bash
# WebIDE 中执行
./package_results.sh

# 本地计算机中执行
scp user@webide_host:~/graspldm/graspLDM/output/packages/*.tar.gz ~/downloads/

# 提取
tar -xzf graspldm_results_*.tar.gz
```

### 场景 5：我想实时监控训练进度

```bash
# 终端 1：启动 TensorBoard
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006

# 终端 2：实时查看日志
tail -f ./output/logs/full_experiment_*.log

# 浏览器：打开 http://localhost:6006 查看训练曲线
```

### 场景 6：我想看特定模型（如仅 VAE）的详细指标

```bash
# 方法 A：查看 TensorBoard（推荐）
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/vae/logs --port=6006

# 方法 B：查看日志
cat ./output/logs/01_vae_training_*.log

# 方法 C：查看检查点信息
ls -lh ./output/comparison/exp_diffusion_vs_fm/vae/checkpoints/
```

---

## 🛠️ WebIDE 端口转发（VS Code WebIDE）

### 自动转发（推荐）

1. 启动 TensorBoard：`tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006`
2. VS Code 中按 `Ctrl + Shift + P`
3. 输入 `Remote: Forward a Port`
4. 输入 `6006`
5. 浏览器打开返回的地址

### 手动转发

1. 打开 VS Code 的 Remote Explorer（左侧边栏）
2. 在 **Ports** 选项卡中点击 **Forward a Port**
3. 输入 `6006`
4. 等待转发完成

### SSH 本地转发（如果上面不工作）

在本地计算机执行：

```bash
ssh -L 6006:localhost:6006 user@webide_host
# 然后在本地浏览器打开 http://localhost:6006
```

---

## 📁 结果目录结构速查

```
graspLDM/
├── output/
│   ├── logs/                                        # 训练日志
│   │   ├── full_experiment_2026-03-02_10-30-00.log
│   │   ├── 01_vae_training_*.log
│   │   ├── 02_diffusion_training_*.log
│   │   ├── 03_flow_matching_training_*.log
│   │   └── 04_evaluation_*.log
│   │
│   ├── comparison/
│   │   ├── exp_diffusion_vs_fm/
│   │   │   ├── vae/
│   │   │   │   ├── logs/                          # TensorBoard 日志
│   │   │   │   ├── checkpoints/                    # 权重文件
│   │   │   │   └── events.out.tfevents.*
│   │   │   ├── ddm/
│   │   │   │   ├── logs/
│   │   │   │   ├── checkpoints/
│   │   │   │   └── events.out.tfevents.*
│   │   │   ├── fm/
│   │   │   │   ├── logs/
│   │   │   │   ├── checkpoints/
│   │   │   │   └── events.out.tfevents.*
│   │   │   └── comparison_results/
│   │   │       ├── comparison_table.csv            # ✨ CSV 表格
│   │   │       ├── metrics_comparison.csv
│   │   │       └── visualization/
│   │   │           ├── success_rate_comparison.png # ✨ PNG 图片
│   │   │           ├── precision_recall_curve.png
│   │   │           └── loss_curves_overlay.png
│   │   └── visualization_viewer.html               # ✨ HTML 查看器
│   │
│   ├── packages/                                   # 打包的压缩文件
│   │   ├── graspldm_results_full_*.tar.gz
│   │   ├── graspldm_results_table_viz_*.tar.gz
│   │   └── graspldm_tensorboard_logs_*.tar.gz
│   │
│   └── results/
│       ├── comparison_table.csv
│       └── evaluation_report.json
```

**✨ 重点位置**：
- **TensorBoard 日志**：`output/comparison/exp_diffusion_vs_fm/*/logs/`
- **CSV 表格**：`output/comparison/exp_diffusion_vs_fm/comparison_results/comparison_table.csv`
- **PNG 图片**：`output/comparison/exp_diffusion_vs_fm/comparison_results/visualization/`
- **HTML 查看器**：`output/comparison/visualization_viewer.html`

---

## ⚡ 快速命令速记

| 需求 | 快速命令 |
|------|---------|
| 查看训练曲线 | `tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006` |
| 查看 CSV 表格 | `python3 view_csv_results.py` |
| 查看 PNG 图片 | `python3 generate_visualization_html.py` |
| 打包下载 | `./package_results.sh` |
| 一键菜单 | `./view_all_results.sh` |
| 启动 HTTP 服务器 | `python3 -m http.server 8000` |
| 查看最新日志 | `tail -f ./output/logs/full_experiment_*.log` |
| 列出所有结果 | `find ./output -type f \( -name "*.csv" -o -name "*.png" -o -name "*.log" \)` |

---

## 🎓 推荐工作流

### 新手推荐（最简单）

```bash
# 1. 启动综合工具
./view_all_results.sh

# 2. 从菜单中选择选项
#    - 选项 1：查看训练曲线
#    - 选项 5：查看 CSV 表格
#    - 选项 6：生成 HTML 图片查看器
```

### 进阶推荐（更灵活）

```bash
# 终端 1：启动 TensorBoard
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006

# 终端 2：启动 HTTP 服务器
python3 -m http.server 8000

# 浏览器：
#   - TensorBoard：http://localhost:6006
#   - HTTP 服务器：http://localhost:8000
#   - HTML 查看器：http://localhost:8000/output/comparison/visualization_viewer.html

# 终端 3：查看 CSV
python3 view_csv_results.py
```

### 专业推荐（最完整）

```bash
# 1. 实时监控训练
tail -f ./output/logs/full_experiment_*.log

# 2. 启动 TensorBoard（另一个终端）
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006

# 3. 启动 HTTP 服务器（第三个终端）
python3 -m http.server 8000

# 4. 训练完成后，打包下载
./package_results.sh

# 5. 查看对比数据
python3 view_csv_results.py
```

---

## 🆘 故障排除

| 问题 | 解决方案 |
|------|--------|
| TensorBoard 无法连接 | `ps aux \| grep tensorboard` 检查进程；尝试其他端口 `--port=6009` |
| VS Code 端口转发失败 | 使用 SSH 本地转发：`ssh -L 6006:localhost:6006 user@host` |
| CSV 太大无法打开 | 使用命令行查看：`head -50 file.csv` |
| PNG 无法显示 | 生成 HTML 查看器：`python3 generate_visualization_html.py` |
| 找不到结果文件 | 检查是否运行了实验：`ls ./output/comparison/exp_diffusion_vs_fm/` |

---

## 📞 帮助与文档

- **详细指南**：见 `WEBIDE_RESULTS_VIEWER_CN.md`
- **一键实验脚本**：`./run_full_comparison_experiment.sh`
- **交互式菜单**：`./view_all_results.sh`
- **Python 工具**：`view_csv_results.py` 和 `generate_visualization_html.py`

---

**最后更新**：2026 年 3 月 2 日

祝您查看实验结果顺利！🎉
