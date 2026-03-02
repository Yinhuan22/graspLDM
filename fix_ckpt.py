import torch
import os
from pathlib import Path

# ============================================================================
# 动态获取项目根目录（支持从任意位置启动）
# ============================================================================
PROJECT_ROOT = Path(__file__).parent.absolute()

# checkpoint 路径（相对路径 -> 绝对路径）
ckpt_path = str(PROJECT_ROOT / "output/comparison/exp_diffusion_vs_fm/vae/checkpoints/last.ckpt")

# 加载 checkpoint
ckpt = torch.load(ckpt_path, map_location="cpu")

# 修复关键参数（强制标记为“未完成 180000 步”）
ckpt["global_step"] = 1000  # 保留已跑的 1000 步
ckpt["epoch"] = 0  # 重置 Epoch 计数，避免训练器误判
ckpt["callbacks"] = None  # 清空异常的回调状态
if "optimizer_states" in ckpt and len(ckpt["optimizer_states"]) > 0:
    ckpt["optimizer_states"][0]["step"] = 1000  # 同步优化器步数

# 保存修复后的 checkpoint
torch.save(ckpt, ckpt_path)
print(f"✅ Checkpoint 修复完成！已保留 1000 步进度，可继续累加至 180000 步。")
