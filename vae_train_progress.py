import os
import torch
import glob
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path

# ========== 动态获取项目根目录（无需改硬编码路径） ==========
PROJECT_ROOT = Path(__file__).parent.absolute()
ckpt_dir = str(PROJECT_ROOT / "output/comparison/exp_diffusion_vs_fm/vae/checkpoints/")
plt.rcParams["font.sans-serif"] = ["DejaVu Sans"]  # 兼容Linux字体
plt.rcParams["axes.unicode_minus"] = False

# ========== 1. 读取所有 checkpoint 的信息 ==========
def load_ckpt_info(ckpt_path):
    """加载单个checkpoint的步数、Loss、Epoch（适配PyTorch Lightning标准字段）"""
    try:
        # 强制加载到CPU，避免GPU占用
        ckpt = torch.load(ckpt_path, map_location="cpu")
        info = {
            "path": ckpt_path,
            "global_step": ckpt.get("global_step", 0),
            "epoch": ckpt.get("epoch", 0),
            "loss": 0.0
        }
        
        # 优先读取PyTorch Lightning的训练Loss字段（适配你的checkpoint）
        if "callback_metrics" in ckpt:
            # 常见的Loss字段名，按优先级匹配
            loss_keys = ["loss", "train_loss", "val_loss", "recon_loss"]
            for key in loss_keys:
                if key in ckpt["callback_metrics"]:
                    info["loss"] = float(ckpt["callback_metrics"][key])
                    break
        # 备用：读取metrics字段
        elif "metrics" in ckpt:
            for key in ["loss", "train_loss"]:
                if key in ckpt["metrics"]:
                    info["loss"] = float(ckpt["metrics"][key])
                    break

        return info
    except Exception as e:
        print(f"⚠️ 加载 {os.path.basename(ckpt_path)} 失败: {str(e)[:50]}")
        return None

# 遍历所有ckpt文件
ckpt_files = glob.glob(os.path.join(ckpt_dir, "*.ckpt"))
ckpt_infos = []
for ckpt_file in ckpt_files:
    info = load_ckpt_info(ckpt_file)
    if info and info["global_step"] > 0:
        ckpt_infos.append(info)

# 按步数排序（从少到多）
ckpt_infos = sorted(ckpt_infos, key=lambda x: x["global_step"])

# ========== 2. 打印核心进度信息 ==========
print("="*60)
print("📊 VAE 训练进度汇总（自动提取）")
print("="*60)

if not ckpt_infos:
    print("❌ 未找到有效checkpoint！")
else:
    # 最新进度
    latest = ckpt_infos[-1]
    total_target = 180000  # 你的目标步数
    progress = (latest["global_step"] / total_target) * 100

    print(f"✅ 当前总步数: {latest['global_step']:,} 步")
    print(f"✅ 当前Epoch: {latest['epoch']} 轮")
    print(f"✅ 当前Loss: {latest['loss']:.4f}")
    print(f"✅ 完成进度: {progress:.2f}% ({latest['global_step']}/{total_target})")
    print(f"✅ 剩余步数: {total_target - latest['global_step']:,} 步")
    
    # 预估剩余时间（按2.6 it/s计算）
    remaining_time = (total_target - latest["global_step"]) / 2.6 / 3600
    print(f"✅ 预估剩余时间: {remaining_time:.2f} 小时")

    # ========== 3. 生成Loss变化趋势图 ==========
    steps = [info["global_step"] for info in ckpt_infos]
    losses = [info["loss"] for info in ckpt_infos]

    plt.figure(figsize=(10, 6))
    plt.plot(steps, losses, "b-o", linewidth=2, markersize=6, label="Training Loss")
    plt.xlabel("Global Step (步数)", fontsize=12)
    plt.ylabel("Loss (损失值)", fontsize=12)
    plt.title(f"VAE Training Loss Trend (Total Target: {total_target:,} Steps)", fontsize=14)
    plt.grid(True, alpha=0.3)
    plt.legend(fontsize=10)
    plt.tight_layout()

    # 保存图片到checkpoint目录（方便查看）
    img_path = os.path.join(ckpt_dir, "vae_loss_trend.png")
    plt.savefig(img_path, dpi=150)
    print(f"\n📸 Loss趋势图已保存到: {img_path}")

print("\n" + "="*60)