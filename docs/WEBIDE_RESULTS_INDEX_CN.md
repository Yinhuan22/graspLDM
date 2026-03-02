# WebIDE 结果查看方案 - 快速索引

**版本**：1.0 | **日期**：2026-03-02 | **状态**：✅ 完成交付

---

## 🎯 我想要... 快速导航

### 我想... 启动 TensorBoard 查看训练曲线

**推荐**：直接执行一行命令

```bash
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006
```

**详细说明**：[WEBIDE_RESULTS_VIEWER_CN.md#二、启动本地-tensorboard](WEBIDE_RESULTS_VIEWER_CN.md)  
**快速参考**：[WEBIDE_QUICK_REFERENCE_CN.md#tensorboard](WEBIDE_QUICK_REFERENCE_CN.md)

---

### 我想... 用菜单工具做所有操作

**推荐**：启动交互式菜单

```bash
./view_all_results.sh
```

**详细说明**：[WEBIDE_RESULTS_VIEWER_CN.md#十一、集成脚本](WEBIDE_RESULTS_VIEWER_CN.md)  
**快速参考**：[WEBIDE_QUICK_REFERENCE_CN.md#一键工具菜单](WEBIDE_QUICK_REFERENCE_CN.md)

---

### 我想... 查看 CSV 对比表格

**推荐方式 1**（最美观）：

```bash
python3 view_csv_results.py
```

**推荐方式 2**（在 VS Code 中）：

直接在文件浏览器中打开：
```
output/comparison/exp_diffusion_vs_fm/comparison_results/comparison_table.csv
```

**详细说明**：[WEBIDE_RESULTS_VIEWER_CN.md#四、查看对比实验结果表格](WEBIDE_RESULTS_VIEWER_CN.md)  
**快速参考**：[WEBIDE_QUICK_REFERENCE_CN.md#查看-csv-表格](WEBIDE_QUICK_REFERENCE_CN.md)

---

### 我想... 查看 PNG 可视化图片

**推荐方式 1**（最快）：

在 VS Code 文件浏览器中打开：
```
output/comparison/exp_diffusion_vs_fm/comparison_results/visualization/
```

**推荐方式 2**（最漂亮）：

```bash
python3 generate_visualization_html.py
# 然后浏览器打开：./output/comparison/visualization_viewer.html
```

**详细说明**：[WEBIDE_RESULTS_VIEWER_CN.md#五、查看对比可视化图片](WEBIDE_RESULTS_VIEWER_CN.md)  
**快速参考**：[WEBIDE_QUICK_REFERENCE_CN.md#查看-png-图片](WEBIDE_QUICK_REFERENCE_CN.md)

---

### 我想... 打包结果下载到本地

**推荐**：一键打包脚本

```bash
./package_results.sh
```

**详细说明**：[WEBIDE_RESULTS_VIEWER_CN.md#七、将结果打包下载到本地](WEBIDE_RESULTS_VIEWER_CN.md)  
**快速参考**：[WEBIDE_QUICK_REFERENCE_CN.md#打包下载结果](WEBIDE_QUICK_REFERENCE_CN.md)

---

### 我想... 设置 VS Code 端口转发

**详细说明**：[WEBIDE_RESULTS_VIEWER_CN.md#三、WebIDE-端口转发详细步骤](WEBIDE_RESULTS_VIEWER_CN.md)  
**快速参考**：[WEBIDE_QUICK_REFERENCE_CN.md#webide-端口转发](WEBIDE_QUICK_REFERENCE_CN.md)

---

### 我想... 监控实时训练进度

**推荐**：多终端配置

```bash
# 终端 1：查看日志
tail -f ./output/logs/full_experiment_*.log

# 终端 2：启动 TensorBoard
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006

# 浏览器：打开 http://localhost:6006
```

**详细说明**：[WEBIDE_RESULTS_VIEWER_CN.md#六、完整查看工作流](WEBIDE_RESULTS_VIEWER_CN.md)  
**快速参考**：[WEBIDE_QUICK_REFERENCE_CN.md#场景-5](WEBIDE_QUICK_REFERENCE_CN.md)

---

### 我想... 解决问题/故障排除

**常见问题**：[WEBIDE_RESULTS_VIEWER_CN.md#八、常见问题与故障排除](WEBIDE_RESULTS_VIEWER_CN.md)  
**快速查找**：[WEBIDE_QUICK_REFERENCE_CN.md#故障排除速查](WEBIDE_QUICK_REFERENCE_CN.md)

---

## 📚 文档地图

### 1️⃣ 初学者 - 从这里开始（5 分钟）

- 📄 [WEBIDE_QUICK_REFERENCE_CN.md](WEBIDE_QUICK_REFERENCE_CN.md)
  - 5 秒快速开始
  - 完整命令清单
  - 常见场景速查

### 2️⃣ 进阶用户 - 深入学习（20 分钟）

- 📄 [WEBIDE_RESULTS_VIEWER_CN.md](WEBIDE_RESULTS_VIEWER_CN.md)
  - 详细的 TensorBoard 启动方法
  - WebIDE 端口转发完整步骤
  - CSV 和 PNG 查看方法
  - 完整的工作流
  - 故障排除指南

### 3️⃣ 项目经理/团队 - 全面了解（10 分钟）

- 📄 [WEBIDE_RESULTS_VIEWER_DELIVERY_CN.md](WEBIDE_RESULTS_VIEWER_DELIVERY_CN.md)
  - 功能清单
  - 使用场景
  - 技术要求
  - 最佳实践

---

## 🔧 脚本地图

### 1️⃣ view_all_results.sh（推荐！）

**一键工具菜单 - 16 个选项**

```bash
./view_all_results.sh
```

**包含的操作**：
- 启动 TensorBoard（多模式）
- 查看 CSV 表格
- 生成 HTML 查看器
- 打包结果
- 查看日志
- 显示目录结构

**适合**：所有用户（新手友好）

---

### 2️⃣ view_csv_results.py

**美化查看 CSV 对比表格**

```bash
python3 view_csv_results.py
```

**特点**：
- 美化的表格显示
- 统计摘要
- 数据类型检查
- 按模型分组展示

**适合**：所有用户

---

### 3️⃣ generate_visualization_html.py

**生成响应式 HTML PNG 查看器**

```bash
python3 generate_visualization_html.py
```

**特点**：
- 自动生成 HTML
- 支持图片放大
- 响应式设计
- 多浏览器兼容

**适合**：所有用户

---

### 4️⃣ package_results.sh

**打包结果为压缩文件**

```bash
./package_results.sh
```

**特点**：
- 3 种打包方式
- 文件大小计算
- 详细日志记录
- 下载提示

**适合**：进阶用户

---

## 🎯 常见工作流

### 工作流 1：我只有 30 秒

```bash
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006
# 浏览器打开 http://localhost:6006
```

**文档**：[WEBIDE_QUICK_REFERENCE_CN.md#场景-1](WEBIDE_QUICK_REFERENCE_CN.md)

---

### 工作流 2：我有 5 分钟

```bash
./view_all_results.sh
# 从菜单中选择选项
```

**文档**：[WEBIDE_QUICK_REFERENCE_CN.md#新手推荐](WEBIDE_QUICK_REFERENCE_CN.md)

---

### 工作流 3：我想完整查看所有结果（10 分钟）

```bash
# 终端 1
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006

# 终端 2
python3 -m http.server 8000

# 终端 3
python3 view_csv_results.py
```

**文档**：[WEBIDE_QUICK_REFERENCE_CN.md#进阶推荐](WEBIDE_QUICK_REFERENCE_CN.md)

---

### 工作流 4：我想监控实时训练（持续）

```bash
# 终端 1：日志
tail -f ./output/logs/full_experiment_*.log

# 终端 2：TensorBoard
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006

# 浏览器：定期刷新 http://localhost:6006
```

**文档**：[WEBIDE_QUICK_REFERENCE_CN.md#场景-5](WEBIDE_QUICK_REFERENCE_CN.md)

---

### 工作流 5：我想下载结果到本地（15 分钟）

```bash
# WebIDE 中
./package_results.sh

# 本地计算机
scp user@webide_host:~/graspldm/graspLDM/output/packages/*.tar.gz ~/downloads/
```

**文档**：[WEBIDE_QUICK_REFERENCE_CN.md#场景-4](WEBIDE_QUICK_REFERENCE_CN.md)

---

## ❓ 快速问题解答

### Q：我不知道从哪开始

**A**：
1. 阅读 [WEBIDE_QUICK_REFERENCE_CN.md](WEBIDE_QUICK_REFERENCE_CN.md)（5 分钟）
2. 执行 `./view_all_results.sh`（5 分钟）

---

### Q：TensorBoard 无法连接

**A**：查看 [WEBIDE_RESULTS_VIEWER_CN.md#常见问题与故障排除](WEBIDE_RESULTS_VIEWER_CN.md)

---

### Q：我需要帮助

**A**：
1. 快速参考：[WEBIDE_QUICK_REFERENCE_CN.md#故障排除速查](WEBIDE_QUICK_REFERENCE_CN.md)
2. 详细指南：[WEBIDE_RESULTS_VIEWER_CN.md#八、常见问题与故障排除](WEBIDE_RESULTS_VIEWER_CN.md)

---

### Q：有没有交互式菜单？

**A**：有！执行 `./view_all_results.sh`

---

## 📊 文件速查表

| 文件 | 大小 | 类型 | 用途 | 适合 |
|------|------|------|------|------|
| WEBIDE_QUICK_REFERENCE_CN.md | 10 KB | 文档 | 快速参考 | 所有人 |
| WEBIDE_RESULTS_VIEWER_CN.md | 25 KB | 文档 | 详细指南 | 所有人 |
| WEBIDE_RESULTS_VIEWER_DELIVERY_CN.md | 13 KB | 文档 | 项目总结 | 项目经理 |
| view_all_results.sh | 14 KB | 脚本 | 一键菜单 | 所有人 |
| view_csv_results.py | 3.3 KB | 脚本 | CSV 查看 | 所有人 |
| generate_visualization_html.py | 14 KB | 脚本 | HTML 生成 | 所有人 |
| package_results.sh | 6.9 KB | 脚本 | 结果打包 | 进阶用户 |

**总计**：84 KB

---

## 🚀 推荐使用路径

### 路径 A：完全新手（推荐！）

```
这个索引文件 → WEBIDE_QUICK_REFERENCE_CN.md 
→ 执行 ./view_all_results.sh → 完成！
```
**总耗时**：10 分钟

---

### 路径 B：有经验的开发者

```
这个索引文件 → WEBIDE_RESULTS_VIEWER_CN.md 
→ 选择合适的命令执行 → 完成！
```
**总耗时**：15 分钟

---

### 路径 C：项目经理/团队

```
这个索引文件 → WEBIDE_RESULTS_VIEWER_DELIVERY_CN.md 
→ 了解功能和最佳实践 → 指导团队
```
**总耗时**：20 分钟

---

## ✨ 核心命令速记

```bash
# 启动 TensorBoard
tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006

# 查看 CSV
python3 view_csv_results.py

# 生成 HTML 查看器
python3 generate_visualization_html.py

# 打包结果
./package_results.sh

# 一键菜单（推荐）
./view_all_results.sh
```

---

## 📞 文档快速链接

| 需求 | 最相关的文档 | 位置 |
|------|----------|------|
| 快速开始 | WEBIDE_QUICK_REFERENCE_CN.md | 本目录 |
| 详细教程 | WEBIDE_RESULTS_VIEWER_CN.md | 本目录 |
| 项目信息 | WEBIDE_RESULTS_VIEWER_DELIVERY_CN.md | 本目录 |
| 快速导航 | 当前文件（INDEX） | 本目录 |

---

**🎉 您已准备好开始查看实验结果！**

**建议下一步**：打开 [WEBIDE_QUICK_REFERENCE_CN.md](WEBIDE_QUICK_REFERENCE_CN.md) 或执行 `./view_all_results.sh`
