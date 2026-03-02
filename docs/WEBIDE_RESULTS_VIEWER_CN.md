# 无外网 WebIDE 中查看 graspLDM 对比实验结果完整指南

## 📋 概述

本指南提供在**无外网 WebIDE 环境中**查看 graspLDM 对比实验结果的完整方法，包括：
- 🔵 TensorBoard 日志可视化（训练曲线、损失函数、指标）
- 📊 对比实验结果表格（CSV 格式）
- 📈 对比可视化图片（PNG 格式）
- 💾 结果打包下载

---

## 一、项目结果目录结构

```
graspLDM/
└── output/
    ├── logs/                                    # 训练日志
    │   ├── full_experiment_2026-03-02_10-30-00.log
    │   ├── 01_vae_training_2026-03-02_10-30-00.log
    │   ├── 02_diffusion_training_2026-03-02_14-30-00.log
    │   ├── 03_flow_matching_training_2026-03-02_18-30-00.log
    │   └── 04_evaluation_2026-03-02_22-30-00.log
    │
    ├── comparison/
    │   └── exp_diffusion_vs_fm/
    │       ├── vae/
    │       │   ├── checkpoints/                 # VAE 权重文件
    │       │   ├── logs/                        # VAE TensorBoard 日志
    │       │   ├── tensorboard_events/
    │       │   └── events.out.tfevents.*
    │       ├── ddm/                             # Diffusion 模型目录
    │       │   ├── checkpoints/
    │       │   ├── logs/
    │       │   └── tensorboard_events/
    │       ├── fm/                              # Flow Matching 模型目录
    │       │   ├── checkpoints/
    │       │   ├── logs/
    │       │   └── tensorboard_events/
    │       └── comparison_results/
    │           ├── comparison_table.csv         # 对比结果表
    │           ├── metrics_comparison.csv
    │           └── visualization/
    │               ├── success_rate_comparison.png
    │               ├── precision_recall_curve.png
    │               └── loss_curves_overlay.png
    │
    └── results/
        ├── comparison_table.csv
        ├── evaluation_report.json
        └── final_summary.txt
```

---

## 二、启动本地 TensorBoard（核心方法）

### 方法 1：启动所有模型的 TensorBoard

**最简单的方式** - 一次查看所有模型的训练曲线：

```bash
# 进入项目根目录
cd /home/mi/siat/graspldm/graspLDM

# 启动 TensorBoard，监听所有模型的日志
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006

# 或使用离线模式（不需要网络连接）
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006 --reload_interval=30
```

**输出示例**：
```
TensorBoard 2.14.0 at http://localhost:6006/ (Press CTRL+C to quit)
```

### 方法 2：分别查看各模型的日志

#### 2.1 查看 VAE 训练日志

```bash
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/vae/logs --port=6006
```

**可视化内容**：
- 训练损失曲线
- 验证损失曲线
- 重构误差
- KL 散度
- 学习率变化

#### 2.2 查看 Diffusion 模型日志

```bash
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/ddm/logs --port=6007
```

**可视化内容**：
- 去噪损失
- 条件概率
- 生成质量指标
- 采样速度

#### 2.3 查看 Flow Matching 模型日志

```bash
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/fm/logs --port=6008
```

**可视化内容**：
- 流匹配损失
- 轨迹距离
- 生成效率
- 样本质量

### 方法 3：对比查看多个模型

同时启动多个 TensorBoard 实例，在多个浏览器标签页中对比：

```bash
# 终端 1：启动 VAE TensorBoard
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/vae/logs --port=6006 &

# 终端 2：启动 Diffusion TensorBoard
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/ddm/logs --port=6007 &

# 终端 3：启动 Flow Matching TensorBoard
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/fm/logs --port=6008 &

# 查看后台进程
jobs

# 若要停止，使用
kill %1  # 停止第一个任务
kill %2  # 停止第二个任务
kill %3  # 停止第三个任务
```

---

## 三、WebIDE 端口转发详细步骤

### 适用场景：VS Code WebIDE 或其他支持端口转发的 IDE

#### 步骤 1：在 WebIDE 中启动 TensorBoard

```bash
# WebIDE 的终端中执行
cd /home/mi/siat/graspldm/graspLDM
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006
```

#### 步骤 2：VS Code 端口转发（推荐方法）

**方案 A：通过命令面板自动转发**

1. 按 `Ctrl + Shift + P` 打开命令面板
2. 输入 `Remote: Forward a Port`
3. 输入端口号：`6006`
4. 选择 `Public` 或 `Private`（私有更安全）
5. VS Code 会自动分配访问地址

**方案 B：通过 VS Code 界面手动转发**

1. 打开 VS Code 的 **Remote Explorer**（左侧边栏）
2. 在 **Ports** 选项卡中
3. 点击 **Forward a Port** 按钮
4. 输入 `6006`
5. 选择转发策略

#### 步骤 3：访问 TensorBoard

在本地浏览器中打开转发地址：

```
http://localhost:6006
```

或者，如果 VS Code 提供了外网地址，使用外网地址访问。

**注意**：如果是本地 SSH 连接，通常不需要端口转发，直接访问：
```
http://localhost:6006
```

---

## 四、查看对比实验结果表格（CSV）

### 方法 1：使用 VS Code 内置 CSV 查看器

1. 在 VS Code 的文件浏览器中，导航到：
   ```
   output/comparison/exp_diffusion_vs_fm/comparison_results/comparison_table.csv
   ```

2. 双击文件，VS Code 会自动用表格形式显示

3. 或者使用 **Edit CSV** 扩展获得更好的表格体验

### 方法 2：使用命令行查看 CSV

```bash
# 查看 CSV 文件内容（表格格式）
head -20 ./output/comparison/exp_diffusion_vs_fm/comparison_results/comparison_table.csv | column -t -s,

# 或使用 cat 简单查看
cat ./output/comparison/exp_diffusion_vs_fm/comparison_results/comparison_table.csv

# 或使用 less 分页查看
less ./output/comparison/exp_diffusion_vs_fm/comparison_results/comparison_table.csv
```

### 方法 3：使用 Python 脚本查看 CSV

创建文件 `view_csv_results.py`：

```python
#!/usr/bin/env python3
import pandas as pd
import os

# CSV 文件路径
csv_path = "./output/comparison/exp_diffusion_vs_fm/comparison_results/comparison_table.csv"

if os.path.exists(csv_path):
    # 读取 CSV
    df = pd.read_csv(csv_path)
    
    # 美化输出
    print("\n" + "="*80)
    print("graspLDM 对比实验结果")
    print("="*80 + "\n")
    
    # 显示完整表格
    pd.set_option('display.max_columns', None)
    pd.set_option('display.width', None)
    print(df.to_string())
    
    # 显示统计信息
    print("\n" + "="*80)
    print("统计摘要")
    print("="*80 + "\n")
    print(df.describe())
    
    # 显示 VAE vs Diffusion vs FM 的对比
    print("\n" + "="*80)
    print("模型性能对比")
    print("="*80 + "\n")
    
    if 'Model' in df.columns:
        for model in df['Model'].unique():
            model_data = df[df['Model'] == model]
            print(f"\n{model}:")
            print(model_data.to_string(index=False))
    else:
        print("CSV 文件中未找到 Model 列")
else:
    print(f"❌ CSV 文件不存在：{csv_path}")
    print("请先运行对比实验: ./run_full_comparison_experiment.sh")
```

执行脚本：

```bash
python3 view_csv_results.py
```

### 方法 4：使用在线工具（如果 WebIDE 支持外网）

- 下载 CSV 文件到本地
- 使用 Google Sheets、Excel 等打开
- 或使用在线 CSV 查看器

---

## 五、查看对比可视化图片（PNG）

### 方法 1：VS Code 内置图片查看器

1. 在 VS Code 的文件浏览器中，导航到：
   ```
   output/comparison/exp_diffusion_vs_fm/comparison_results/visualization/
   ```

2. 双击 `.png` 文件即可预览

3. 右键选择 **Open Preview** 获得更大的预览窗口

### 方法 2：使用命令行查看器

```bash
# 列出所有可视化图片
ls -lh ./output/comparison/exp_diffusion_vs_fm/comparison_results/visualization/

# 使用 feh 查看（如果已安装）
feh ./output/comparison/exp_diffusion_vs_fm/comparison_results/visualization/

# 使用 eog（GNOME 图片查看器）
eog ./output/comparison/exp_diffusion_vs_fm/comparison_results/visualization/success_rate_comparison.png

# 使用 display（ImageMagick）
display ./output/comparison/exp_diffusion_vs_fm/comparison_results/visualization/success_rate_comparison.png
```

### 方法 3：使用 Python 脚本生成图片预览网页

创建文件 `generate_visualization_html.py`：

```python
#!/usr/bin/env python3
import os
from pathlib import Path

# 可视化目录
vis_dir = Path("./output/comparison/exp_diffusion_vs_fm/comparison_results/visualization")

# 生成 HTML 文件
html_content = """
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>graspLDM 对比实验结果可视化</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .image-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(600px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        .image-box {
            background-color: white;
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .image-box img {
            width: 100%;
            height: auto;
            border-radius: 4px;
        }
        .image-box h3 {
            margin-top: 10px;
            color: #2c3e50;
        }
        .image-box p {
            color: #666;
            font-size: 14px;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <h1>🎯 graspLDM 对比实验结果可视化</h1>
    <div class="image-container">
"""

if vis_dir.exists():
    for img_file in sorted(vis_dir.glob("*.png")):
        rel_path = img_file.relative_to(Path("."))
        filename = img_file.stem
        
        html_content += f"""
        <div class="image-box">
            <img src="{rel_path}" alt="{filename}">
            <h3>{filename.replace('_', ' ').title()}</h3>
            <p>点击图片可放大查看</p>
        </div>
"""

html_content += """
    </div>
</body>
</html>
"""

# 保存 HTML 文件
output_file = Path("./output/comparison/visualization_viewer.html")
output_file.parent.mkdir(parents=True, exist_ok=True)

with open(output_file, "w", encoding="utf-8") as f:
    f.write(html_content)

print(f"✅ 已生成可视化查看网页: {output_file}")
print(f"📂 可视化图片位置: {vis_dir}")
print(f"💡 用法: 在浏览器中打开 {output_file}")
```

执行脚本：

```bash
python3 generate_visualization_html.py
```

然后在浏览器中打开生成的 `./output/comparison/visualization_viewer.html` 文件。

### 方法 4：使用 HTTP 服务器浏览图片

```bash
# 启动简单 HTTP 服务器
cd ./output/comparison/exp_diffusion_vs_fm/comparison_results/visualization
python3 -m http.server 8000

# 在浏览器中访问
# http://localhost:8000
```

---

## 六、完整查看工作流

### 推荐工作流：5 步完整查看所有结果

#### 步骤 1：启动 TensorBoard

```bash
cd /home/mi/siat/graspldm/graspLDM
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006
```

#### 步骤 2：转发 TensorBoard 端口（WebIDE）

在 VS Code 中：
- `Ctrl + Shift + P` → `Remote: Forward a Port` → 输入 `6006`

#### 步骤 3：在浏览器中打开 TensorBoard

```
http://localhost:6006
```

**TensorBoard 中查看**：
- Scalars：损失函数、准确率等曲线
- Graphs：模型网络结构
- Distributions：权重分布
- Histograms：梯度流

#### 步骤 4：查看 CSV 对比表格

在 VS Code 中打开：
```
output/comparison/exp_diffusion_vs_fm/comparison_results/comparison_table.csv
```

或使用命令行：
```bash
python3 view_csv_results.py
```

#### 步骤 5：查看可视化图片

在 VS Code 中打开：
```
output/comparison/exp_diffusion_vs_fm/comparison_results/visualization/
```

或生成 HTML 查看器：
```bash
python3 generate_visualization_html.py
# 然后在浏览器中打开 output/comparison/visualization_viewer.html
```

---

## 七、将结果打包下载到本地

### 方法 1：使用 tar 压缩打包

```bash
# 进入项目目录
cd /home/mi/siat/graspldm/graspLDM

# 打包所有结果（包含日志、检查点、对比表格、图片）
tar -czf graspldm_results_$(date +%Y%m%d_%H%M%S).tar.gz \
  ./output/comparison/exp_diffusion_vs_fm/comparison_results \
  ./output/logs \
  ./output/results

# 或仅打包必要的结果（不包含大的检查点文件）
tar -czf graspldm_results_light_$(date +%Y%m%d_%H%M%S).tar.gz \
  ./output/comparison/exp_diffusion_vs_fm/comparison_results \
  ./output/comparison/exp_diffusion_vs_fm/vae/logs \
  ./output/comparison/exp_diffusion_vs_fm/ddm/logs \
  ./output/comparison/exp_diffusion_vs_fm/fm/logs \
  ./output/logs
```

**输出**：
```
graspldm_results_20260302_143000.tar.gz
```

### 方法 2：选择性打包

```bash
# 仅打包对比表格和可视化结果
tar -czf graspldm_results_table_viz_$(date +%Y%m%d_%H%M%S).tar.gz \
  ./output/comparison/exp_diffusion_vs_fm/comparison_results/comparison_table.csv \
  ./output/comparison/exp_diffusion_vs_fm/comparison_results/visualization/

# 仅打包 TensorBoard 日志
tar -czf graspldm_tensorboard_logs_$(date +%Y%m%d_%H%M%S).tar.gz \
  ./output/comparison/exp_diffusion_vs_fm/vae/logs \
  ./output/comparison/exp_diffusion_vs_fm/ddm/logs \
  ./output/comparison/exp_diffusion_vs_fm/fm/logs
```

### 方法 3：使用 zip 压缩（如果不支持 tar）

```bash
# 安装 zip（如果未安装）
# sudo apt-get install zip

# 压缩所有结果
zip -r graspldm_results_$(date +%Y%m%d_%H%M%S).zip \
  ./output/comparison/exp_diffusion_vs_fm/comparison_results \
  ./output/logs
```

### 方法 4：创建下载脚本

创建文件 `package_results.sh`：

```bash
#!/bin/bash

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo -e "${BLUE}=== graspLDM 结果打包脚本 ===${NC}"
echo ""

# 检查结果目录是否存在
if [ ! -d "$PROJECT_ROOT/output/comparison/exp_diffusion_vs_fm/comparison_results" ]; then
    echo "❌ 错误：找不到对比结果目录"
    echo "请先运行: ./run_full_comparison_experiment.sh"
    exit 1
fi

# 创建临时打包目录
PACKAGE_DIR="$PROJECT_ROOT/output/packages"
mkdir -p "$PACKAGE_DIR"

# 1. 打包完整结果（包含日志）
echo -e "${BLUE}📦 打包 1: 完整结果（含日志）${NC}"
FULL_PACKAGE="$PACKAGE_DIR/graspldm_results_full_$TIMESTAMP.tar.gz"
tar -czf "$FULL_PACKAGE" \
  -C "$PROJECT_ROOT" \
  output/comparison/exp_diffusion_vs_fm/comparison_results \
  output/logs
echo -e "${GREEN}✅ 完成: $FULL_PACKAGE${NC}"
echo "   大小: $(du -h "$FULL_PACKAGE" | cut -f1)"
echo ""

# 2. 打包轻量级结果（仅表格和图片）
echo -e "${BLUE}📦 打包 2: 轻量级结果（表格+图片）${NC}"
LIGHT_PACKAGE="$PACKAGE_DIR/graspldm_results_table_viz_$TIMESTAMP.tar.gz"
tar -czf "$LIGHT_PACKAGE" \
  -C "$PROJECT_ROOT/output/comparison/exp_diffusion_vs_fm/comparison_results" \
  .
echo -e "${GREEN}✅ 完成: $LIGHT_PACKAGE${NC}"
echo "   大小: $(du -h "$LIGHT_PACKAGE" | cut -f1)"
echo ""

# 3. 打包 TensorBoard 日志
echo -e "${BLUE}📦 打包 3: TensorBoard 日志${NC}"
TB_PACKAGE="$PACKAGE_DIR/graspldm_tensorboard_logs_$TIMESTAMP.tar.gz"
tar -czf "$TB_PACKAGE" \
  -C "$PROJECT_ROOT/output/comparison/exp_diffusion_vs_fm" \
  vae/logs ddm/logs fm/logs
echo -e "${GREEN}✅ 完成: $TB_PACKAGE${NC}"
echo "   大小: $(du -h "$TB_PACKAGE" | cut -f1)"
echo ""

# 显示总结
echo -e "${GREEN}=== 打包完成 ===${NC}"
echo "📁 所有打包文件位置: $PACKAGE_DIR"
echo ""
echo "📝 清单:"
echo "  1. 完整结果：$(basename $FULL_PACKAGE)"
echo "  2. 轻量级结果：$(basename $LIGHT_PACKAGE)"
echo "  3. TensorBoard 日志：$(basename $TB_PACKAGE)"
echo ""
echo "💡 下载提示:"
echo "  使用 SCP 下载到本地："
echo "  scp -r user@remote:$PACKAGE_DIR ~/downloads/"
```

执行脚本：

```bash
chmod +x package_results.sh
./package_results.sh
```

### 方法 5：使用 SCP 从本地下载

在本地计算机上执行：

```bash
# 下载单个文件
scp user@webide_host:/path/to/graspldm_results_*.tar.gz ~/downloads/

# 下载整个 results 目录
scp -r user@webide_host:/home/mi/siat/graspldm/graspLDM/output ~/downloads/graspldm_output

# 列出可下载的文件
ssh user@webide_host "ls -lh /home/mi/siat/graspldm/graspLDM/output/packages/"
```

---

## 八、常见问题与故障排除

### Q1：TensorBoard 无法连接

**问题**：访问 `http://localhost:6006` 时出现连接错误

**解决方案**：
```bash
# 1. 检查 TensorBoard 是否运行
ps aux | grep tensorboard

# 2. 重新启动 TensorBoard，使用不同端口
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6009 --reload_interval=10

# 3. 检查防火墙
sudo ufw allow 6006/tcp

# 4. 使用本地绑定地址
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --host=127.0.0.1 --port=6006
```

### Q2：CSV 文件过大，无法在 VS Code 中打开

**问题**：VS Code 超时或崩溃

**解决方案**：
```bash
# 使用命令行工具查看
head -50 ./output/comparison/exp_diffusion_vs_fm/comparison_results/comparison_table.csv

# 或分页查看
less ./output/comparison/exp_diffusion_vs_fm/comparison_results/comparison_table.csv

# 或转换为其他格式
python3 -c "import pandas as pd; df = pd.read_csv('./output/comparison/exp_diffusion_vs_fm/comparison_results/comparison_table.csv'); print(df.head(10))"
```

### Q3：图片无法预览

**问题**：PNG 文件在 VS Code 中无法显示

**解决方案**：
```bash
# 检查图片是否存在
find ./output -name "*.png" -type f

# 检查图片完整性
file ./output/comparison/exp_diffusion_vs_fm/comparison_results/visualization/*.png

# 使用命令行工具查看
display ./output/comparison/exp_diffusion_vs_fm/comparison_results/visualization/success_rate_comparison.png
```

### Q4：端口转发不工作

**问题**：VS Code 端口转发设置失败

**解决方案**：
```bash
# 方案 A：使用 SSH 本地端口转发
# 在本地计算机上执行
ssh -L 6006:localhost:6006 user@webide_host

# 方案 B：检查端口是否被占用
lsof -i :6006

# 方案 C：使用不同端口
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=7777
# 然后转发 7777 端口
```

### Q5：结果目录为空

**问题**：`comparison_results` 目录不存在或为空

**解决方案**：
```bash
# 1. 检查实验是否已完成
ls -la ./output/comparison/exp_diffusion_vs_fm/

# 2. 查看训练日志
tail -100 ./output/logs/full_experiment_*.log

# 3. 检查错误信息
cat ./output/logs/*_error.log 2>/dev/null

# 4. 重新运行对比实验（仅评估部分）
./run_full_comparison_experiment.sh --skip-vae --skip-diffusion --skip-fm
```

---

## 九、性能提示

### TensorBoard 性能优化

```bash
# 1. 限制日志刷新频率（降低 CPU 使用）
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm \
  --port=6006 \
  --reload_interval=60 \
  --samples_per_plugin="images=10,scalars=100"

# 2. 只加载特定的事件文件
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/vae/logs \
  --port=6006 \
  --reload_interval=30

# 3. 禁用不需要的插件
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm \
  --port=6006 \
  --reload_interval=10 \
  --plugins=scalars,images
```

### 浏览器优化

- 使用 Chrome/Firefox 而不是 Safari（性能更好）
- 关闭不需要的 TensorBoard 标签页
- 定期清理浏览器缓存
- 如果有多个可视化，分多个标签页打开不同模型的日志

---

## 十、完整命令参考表

| 目标 | 命令 |
|------|------|
| 启动 TensorBoard | `tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006` |
| 查看 VAE 日志 | `tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/vae/logs --port=6006` |
| 查看 Diffusion 日志 | `tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/ddm/logs --port=6007` |
| 查看 FM 日志 | `tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/fm/logs --port=6008` |
| 查看 CSV 表格 | `python3 view_csv_results.py` |
| 生成 PNG 查看器 | `python3 generate_visualization_html.py` |
| 打包所有结果 | `./package_results.sh` |
| 打包为 tar | `tar -czf results.tar.gz ./output/comparison` |
| 下载结果 | `scp user@host:*/graspldm_results_*.tar.gz ~/` |
| 列出所有日志 | `find ./output -name "*.log" -type f` |
| 查看最新日志 | `tail -f ./output/logs/full_experiment_*.log` |
| 检查 GPU 日志 | `grep -i gpu ./output/logs/*` |

---

## 十一、集成脚本：一步启动所有查看工具

创建文件 `view_all_results.sh`：

```bash
#!/bin/bash

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  graspLDM 对比实验结果查看工具                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# 菜单选项
echo -e "${YELLOW}请选择要执行的操作：${NC}"
echo ""
echo "  1️⃣  启动 TensorBoard（所有模型的训练曲线）"
echo "  2️⃣  启动 VAE TensorBoard（端口 6006）"
echo "  3️⃣  启动 Diffusion TensorBoard（端口 6007）"
echo "  4️⃣  启动 FM TensorBoard（端口 6008）"
echo "  5️⃣  查看 CSV 对比表格"
echo "  6️⃣  生成 PNG 可视化 HTML 查看器"
echo "  7️⃣  打包所有结果"
echo "  8️⃣  显示结果目录结构"
echo "  9️⃣  查看最新的训练日志"
echo "  0️⃣  退出"
echo ""

read -p "输入选项 (0-9): " choice

case $choice in
    1)
        echo -e "${GREEN}启动 TensorBoard（所有模型）...${NC}"
        cd "$PROJECT_ROOT"
        tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006
        ;;
    2)
        echo -e "${GREEN}启动 VAE TensorBoard（端口 6006）...${NC}"
        cd "$PROJECT_ROOT"
        tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/vae/logs --port=6006
        ;;
    3)
        echo -e "${GREEN}启动 Diffusion TensorBoard（端口 6007）...${NC}"
        cd "$PROJECT_ROOT"
        tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/ddm/logs --port=6007
        ;;
    4)
        echo -e "${GREEN}启动 FM TensorBoard（端口 6008）...${NC}"
        cd "$PROJECT_ROOT"
        tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/fm/logs --port=6008
        ;;
    5)
        echo -e "${GREEN}查看 CSV 对比表格...${NC}"
        cd "$PROJECT_ROOT"
        python3 view_csv_results.py
        ;;
    6)
        echo -e "${GREEN}生成 PNG 可视化 HTML 查看器...${NC}"
        cd "$PROJECT_ROOT"
        python3 generate_visualization_html.py
        echo -e "${GREEN}✅ 请在浏览器中打开: ./output/comparison/visualization_viewer.html${NC}"
        ;;
    7)
        echo -e "${GREEN}打包所有结果...${NC}"
        cd "$PROJECT_ROOT"
        ./package_results.sh
        ;;
    8)
        echo -e "${GREEN}显示结果目录结构${NC}"
        cd "$PROJECT_ROOT"
        tree ./output/comparison/exp_diffusion_vs_fm/comparison_results 2>/dev/null || find ./output/comparison/exp_diffusion_vs_fm/comparison_results -type f
        ;;
    9)
        echo -e "${GREEN}查看最新的训练日志${NC}"
        LATEST_LOG=$(find "$PROJECT_ROOT/output/logs" -name "full_experiment_*.log" -type f -printf '%T@ %p\n' | sort -rn | head -1 | cut -d' ' -f2-)
        if [ -n "$LATEST_LOG" ]; then
            tail -100 "$LATEST_LOG"
        else
            echo "❌ 未找到日志文件"
        fi
        ;;
    0)
        echo -e "${GREEN}退出${NC}"
        exit 0
        ;;
    *)
        echo -e "${YELLOW}❌ 无效的选项${NC}"
        exit 1
        ;;
esac
```

执行脚本：

```bash
chmod +x view_all_results.sh
./view_all_results.sh
```

---

## 总结

| 任务 | 推荐方法 | 命令 |
|------|---------|------|
| 查看训练曲线 | TensorBoard | `tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006` |
| 查看对比数据 | CSV 查看器 | 在 VS Code 中打开 CSV 文件或运行 `python3 view_csv_results.py` |
| 查看结果图片 | VS Code 预览或 HTML | 在 VS Code 中打开 PNG 或运行 `python3 generate_visualization_html.py` |
| 下载结果 | tar 压缩 + scp | `./package_results.sh` 然后 `scp` 下载 |
| 一站式工具 | 集成脚本 | `./view_all_results.sh` |

---

**👉 下一步**：选择上述任一方法，开始查看您的对比实验结果！
