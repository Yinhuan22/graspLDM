#!/usr/bin/env python3
"""
查看 graspLDM 对比实验结果 CSV 表格

用法:
    python3 view_csv_results.py
"""

import os
import sys
from pathlib import Path
import pandas as pd

def print_header(title):
    """打印标题"""
    print("\n" + "="*100)
    print(f"  {title}")
    print("="*100 + "\n")

def view_csv_results():
    """查看对比实验结果"""
    
    # CSV 文件路径
    project_root = Path(__file__).parent
    csv_paths = [
        project_root / "output" / "comparison" / "exp_diffusion_vs_fm" / "comparison_results" / "comparison_table.csv",
        project_root / "output" / "comparison" / "exp_diffusion_vs_fm" / "comparison_results" / "metrics_comparison.csv",
        project_root / "output" / "results" / "comparison_table.csv",
    ]
    
    # 查找存在的 CSV 文件
    found_csv = None
    for csv_path in csv_paths:
        if csv_path.exists():
            found_csv = csv_path
            break
    
    if found_csv is None:
        print("❌ 错误：未找到对比结果 CSV 文件")
        print(f"   期望位置:")
        for p in csv_paths:
            print(f"   - {p}")
        print("\n💡 请先运行对比实验:")
        print("   ./run_full_comparison_experiment.sh")
        sys.exit(1)
    
    # 读取 CSV
    try:
        df = pd.read_csv(found_csv)
    except Exception as e:
        print(f"❌ 错误：无法读取 CSV 文件: {e}")
        sys.exit(1)
    
    print_header("📊 graspLDM 对比实验结果")
    
    # 显示完整表格
    pd.set_option('display.max_columns', None)
    pd.set_option('display.max_rows', None)
    pd.set_option('display.width', None)
    pd.set_option('display.max_colwidth', None)
    
    print(df.to_string())
    
    # 显示统计信息
    print_header("📈 统计摘要")
    try:
        stats = df.describe()
        print(stats.to_string())
    except:
        print("  (无法计算数值统计)")
    
    # 显示行列信息
    print_header("📋 表格信息")
    print(f"  行数: {len(df)}")
    print(f"  列数: {len(df.columns)}")
    print(f"  列名: {', '.join(df.columns.tolist())}")
    
    # 显示 VAE vs Diffusion vs FM 的对比（如果有 Model 列）
    if 'Model' in df.columns:
        print_header("🔍 按模型分组的性能对比")
        for model in df['Model'].unique():
            model_data = df[df['Model'] == model]
            print(f"\n▶ {model}:")
            print(model_data.to_string(index=False))
    
    # 显示数据类型
    print_header("🔧 数据类型")
    print(df.dtypes.to_string())
    
    # 显示缺失值
    print_header("🔔 缺失值检查")
    missing = df.isnull().sum()
    if missing.sum() == 0:
        print("  ✅ 无缺失值")
    else:
        print(missing[missing > 0].to_string())
    
    # 显示文件位置
    print_header("📁 文件位置")
    print(f"  CSV 文件: {found_csv}")
    print(f"  文件大小: {found_csv.stat().st_size / 1024:.2f} KB")
    
    print("\n✅ 完成\n")

if __name__ == "__main__":
    try:
        view_csv_results()
    except KeyboardInterrupt:
        print("\n\n⚠️  用户中断")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ 错误: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
