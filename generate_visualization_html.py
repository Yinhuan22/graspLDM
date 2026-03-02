#!/usr/bin/env python3
"""
生成对比实验结果可视化 HTML 查看器

用法:
    python3 generate_visualization_html.py

生成的 HTML 文件位置:
    ./output/comparison/visualization_viewer.html
"""

import os
import sys
from pathlib import Path

def generate_html():
    """生成 HTML 查看器"""
    
    project_root = Path(__file__).parent
    vis_dir = project_root / "output" / "comparison" / "exp_diffusion_vs_fm" / "comparison_results" / "visualization"
    
    if not vis_dir.exists():
        print(f"⚠️  警告：可视化目录不存在: {vis_dir}")
        print("   图片可能还未生成，请等待对比实验完成")
        return False
    
    # 查找所有 PNG 文件
    png_files = sorted(list(vis_dir.glob("*.png")))
    
    if not png_files:
        print(f"⚠️  警告：在目录中未找到 PNG 文件: {vis_dir}")
        print("   图片可能还未生成")
        return False
    
    # 生成 HTML 内容
    html_content = """<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>graspLDM 对比实验结果可视化</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 40px 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        header {
            text-align: center;
            color: white;
            margin-bottom: 40px;
        }
        
        header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        
        header p {
            font-size: 1.1em;
            opacity: 0.9;
        }
        
        .stats {
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        
        .stat-item {
            text-align: center;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 6px;
            border-left: 4px solid #667eea;
        }
        
        .stat-item .number {
            font-size: 2em;
            font-weight: bold;
            color: #667eea;
        }
        
        .stat-item .label {
            color: #666;
            margin-top: 5px;
            font-size: 0.9em;
        }
        
        .image-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 30px;
            margin-bottom: 40px;
        }
        
        .image-box {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            cursor: pointer;
        }
        
        .image-box:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.3);
        }
        
        .image-box img {
            width: 100%;
            height: auto;
            display: block;
            background: #f0f0f0;
        }
        
        .image-info {
            padding: 20px;
        }
        
        .image-info h3 {
            color: #333;
            font-size: 1.2em;
            margin-bottom: 8px;
            word-break: break-word;
        }
        
        .image-info p {
            color: #666;
            font-size: 0.95em;
            line-height: 1.6;
        }
        
        .image-size {
            color: #999;
            font-size: 0.85em;
            margin-top: 10px;
        }
        
        /* 模态框 */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.8);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        
        .modal.active {
            display: flex;
        }
        
        .modal-content {
            position: relative;
            max-width: 90vw;
            max-height: 90vh;
            background: white;
            border-radius: 8px;
            padding: 20px;
        }
        
        .modal img {
            width: 100%;
            height: auto;
        }
        
        .modal-close {
            position: absolute;
            top: 15px;
            right: 15px;
            width: 40px;
            height: 40px;
            background: rgba(0,0,0,0.7);
            color: white;
            border: none;
            border-radius: 50%;
            font-size: 24px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.3s;
        }
        
        .modal-close:hover {
            background: rgba(0,0,0,0.9);
        }
        
        footer {
            text-align: center;
            color: white;
            margin-top: 40px;
            opacity: 0.9;
            font-size: 0.9em;
        }
        
        .legend {
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        
        .legend h2 {
            color: #333;
            margin-bottom: 15px;
            font-size: 1.3em;
        }
        
        .legend-item {
            display: inline-block;
            margin-right: 30px;
            margin-bottom: 10px;
        }
        
        .legend-color {
            display: inline-block;
            width: 16px;
            height: 16px;
            border-radius: 3px;
            margin-right: 8px;
            vertical-align: middle;
        }
        
        @media (max-width: 768px) {
            .image-container {
                grid-template-columns: 1fr;
            }
            
            header h1 {
                font-size: 1.8em;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🎯 graspLDM 对比实验结果可视化</h1>
            <p>VAE vs Diffusion vs Flow Matching 性能对比</p>
        </header>
        
        <div class="stats">
            <div class="stat-item">
                <div class="number">3</div>
                <div class="label">对比模型</div>
            </div>
            <div class="stat-item">
                <div class="number">""" + str(len(png_files)) + """</div>
                <div class="label">可视化图表</div>
            </div>
            <div class="stat-item">
                <div class="number">180K</div>
                <div class="label">训练步数</div>
            </div>
            <div class="stat-item">
                <div class="number">6-DoF</div>
                <div class="label">抓取自由度</div>
            </div>
        </div>
        
        <div class="legend">
            <h2>📖 图表说明</h2>
            <div class="legend-item">
                <span class="legend-color" style="background: #1f77b4;"></span>
                <span>VAE（Variational Autoencoder）- 基础模型</span>
            </div>
            <div class="legend-item">
                <span class="legend-color" style="background: #ff7f0e;"></span>
                <span>DDM（Diffusion）- 扩散模型</span>
            </div>
            <div class="legend-item">
                <span class="legend-color" style="background: #2ca02c;"></span>
                <span>FM（Flow Matching）- 流匹配模型</span>
            </div>
        </div>
        
        <div class="image-container">
"""
    
    # 添加每个 PNG 文件
    for png_file in png_files:
        filename = png_file.name
        display_name = filename.replace('_', ' ').replace('.png', '').title()
        file_size = png_file.stat().st_size / 1024  # KB
        
        rel_path = png_file.relative_to(project_root)
        
        descriptions = {
            'success_rate_comparison': '各模型的成功率对比（柱状图）',
            'precision_recall_curve': '精度-召回率曲线',
            'loss_curves_overlay': '训练损失函数对比（叠加图）',
            'training_time_comparison': '模型训练时间对比',
            'inference_speed': '推理速度对比',
            'accuracy_distribution': '准确率分布直方图',
            'metrics_heatmap': '综合指标热力图',
            'convergence_speed': '模型收敛速度对比',
        }
        
        description = descriptions.get(png_file.stem, '对比实验结果可视化')
        
        html_content += f"""            <div class="image-box" onclick="openModal('{rel_path}')">
                <img src="{rel_path}" alt="{display_name}" loading="lazy">
                <div class="image-info">
                    <h3>📊 {display_name}</h3>
                    <p>{description}</p>
                    <div class="image-size">大小: {file_size:.1f} KB</div>
                </div>
            </div>
"""
    
    html_content += """        </div>
    </div>
    
    <!-- 图片放大模态框 -->
    <div class="modal" id="modal">
        <div class="modal-content">
            <button class="modal-close" onclick="closeModal()">×</button>
            <img id="modal-image" src="" alt="">
        </div>
    </div>
    
    <footer>
        <p>💡 点击任何图片可放大查看 | graspLDM © 2024</p>
        <p>生成时间: """ + pd.Timestamp.now().strftime("%Y-%m-%d %H:%M:%S") + """</p>
    </footer>
    
    <script>
        function openModal(imagePath) {
            const modal = document.getElementById('modal');
            const img = document.getElementById('modal-image');
            img.src = imagePath;
            modal.classList.add('active');
        }
        
        function closeModal() {
            const modal = document.getElementById('modal');
            modal.classList.remove('active');
        }
        
        // 点击模态框背景关闭
        document.getElementById('modal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeModal();
            }
        });
        
        // 键盘 ESC 关闭
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeModal();
            }
        });
    </script>
</body>
</html>
"""
    
    # 保存 HTML 文件
    output_dir = project_root / "output" / "comparison"
    output_dir.mkdir(parents=True, exist_ok=True)
    
    output_file = output_dir / "visualization_viewer.html"
    
    try:
        with open(output_file, "w", encoding="utf-8") as f:
            f.write(html_content)
        
        print("\n" + "="*80)
        print("✅ 已生成可视化查看网页")
        print("="*80)
        print(f"\n📁 HTML 文件位置: {output_file}")
        print(f"🎨 包含的图片数量: {len(png_files)}")
        print(f"📊 可视化目录: {vis_dir}")
        
        # 显示包含的图片列表
        print("\n📋 包含的图片:")
        for i, png_file in enumerate(png_files, 1):
            print(f"   {i}. {png_file.name}")
        
        print("\n" + "="*80)
        print("🌐 使用方法:")
        print("="*80)
        print("\n方案 A：本地浏览器打开")
        print(f"  1. 打开文件管理器，导航到: {output_file}")
        print("  2. 双击文件，用浏览器打开")
        print("  或者直接在浏览器中打开: file://" + str(output_file))
        
        print("\n方案 B：启动 HTTP 服务器（推荐）")
        print(f"  1. 在终端中执行: cd {project_root} && python3 -m http.server 8000")
        print(f"  2. 在浏览器中打开: http://localhost:8000/output/comparison/visualization_viewer.html")
        
        print("\n方案 C：VS Code 打开")
        print(f"  1. VS Code 中右键点击 {output_file}")
        print("  2. 选择 'Reveal in File Explorer'")
        print("  3. 用浏览器打开该文件")
        
        print("\n✨ 功能:")
        print("  • 点击任何图片可放大查看")
        print("  • 响应式设计，适配各种屏幕尺寸")
        print("  • 图片加载性能优化（延迟加载）")
        
        print("\n")
        return True
        
    except Exception as e:
        print(f"❌ 错误：无法生成 HTML 文件: {e}")
        return False

if __name__ == "__main__":
    # 导入 pandas 用于时间戳
    try:
        import pandas as pd
    except ImportError:
        # 如果没有 pandas，使用简单的日期字符串
        from datetime import datetime
        class pd:
            class Timestamp:
                @staticmethod
                def now():
                    return datetime.now()
    
    try:
        success = generate_html()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n\n⚠️  用户中断")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ 错误: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
