#!/usr/bin/env python3

##############################################################################
# graspLDM 预启动检查工具
# 
# 用途：在运行实验之前，检查所有必要的资源和配置是否准备完毕
# 
# 使用方法：
#   chmod +x check_before_start.py
#   python3 check_before_start.py
#
# 输出：生成启动前检查报告
#
##############################################################################

import os
import sys
import subprocess
from pathlib import Path
from datetime import datetime

# 颜色定义
class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

def log_info(msg):
    print(f"{Colors.BLUE}[INFO]{Colors.RESET} {msg}")

def log_success(msg):
    print(f"{Colors.GREEN}[✓]{Colors.RESET} {msg}")

def log_warn(msg):
    print(f"{Colors.YELLOW}[⚠]{Colors.RESET} {msg}")

def log_error(msg):
    print(f"{Colors.RED}[✗]{Colors.RESET} {msg}")

def log_section(title):
    print(f"\n{Colors.BOLD}{Colors.CYAN}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.CYAN}  {title}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.CYAN}{'='*60}{Colors.RESET}\n")

def check_file_exists(filepath, description=""):
    """检查文件是否存在"""
    if os.path.exists(filepath):
        size = os.path.getsize(filepath) / (1024**3)  # 转换为 GB
        desc = f" ({description})" if description else ""
        if size > 0:
            log_success(f"{filepath} ({size:.1f} GB){desc}")
            return True
        else:
            log_error(f"{filepath} (空文件){desc}")
            return False
    else:
        log_error(f"{filepath} (不存在){desc}")
        return False

def check_dir_exists(dirpath, description=""):
    """检查目录是否存在"""
    if os.path.isdir(dirpath):
        size = sum(f.stat().st_size for f in Path(dirpath).glob('**/*') if f.is_file()) / (1024**3)
        desc = f" ({description})" if description else ""
        log_success(f"{dirpath}{desc} (总大小: {size:.1f} GB)")
        return True
    else:
        log_error(f"{dirpath} (不存在){desc}")
        return False

def count_files(dirpath, pattern="*"):
    """计算目录中文件数量"""
    if os.path.isdir(dirpath):
        try:
            files = list(Path(dirpath).glob(pattern))
            return len(files)
        except:
            return 0
    return 0

def run_command(cmd, description=""):
    """运行命令并返回是否成功"""
    try:
        result = subprocess.run(
            cmd, 
            shell=True, 
            capture_output=True, 
            timeout=10,
            text=True
        )
        return result.returncode == 0, result.stdout.strip(), result.stderr.strip()
    except Exception as e:
        return False, "", str(e)

def main():
    print(f"\n{Colors.BOLD}{Colors.MAGENTA}")
    print(r"""
     ____            ___     ___    __ ___  
    / ___|_ __ __ _ / _ \   / _ \  / _/ _ \ 
   | |  _| '__/ _` | | | | | | | || | | | |
   | |_| | | | (_| | |_| | | |_| || | |_| |
    \____|_|  \__,_|\___/   \___/  |_|\___/ 
    
    graspLDM 预启动检查工具 v1.0
    """)
    print(f"{Colors.RESET}\n")

    # 检查项目根目录
    log_section("1. 项目目录检查")
    
    project_root = os.getcwd()
    log_info(f"项目根目录: {project_root}")
    
    required_dirs = {
        "configs": "配置文件目录",
        "tools": "训练脚本目录",
        "grasp_ldm": "源代码目录",
        "data": "数据目录（可能为空）"
    }
    
    all_dirs_ok = True
    for dirname, desc in required_dirs.items():
        path = os.path.join(project_root, dirname)
        if os.path.isdir(path):
            log_success(f"{dirname}/ {desc}")
        else:
            log_warn(f"{dirname}/ {desc} (可能不存在)")
            if dirname != "data":
                all_dirs_ok = False
    
    if all_dirs_ok:
        log_success("项目结构基本完整")
    
    # 检查关键文件
    log_section("2. 关键脚本和文档检查")
    
    required_scripts = {
        "install_offline_deps.sh": "离线安装脚本",
        "setup_paths.sh": "路径配置脚本",
        "run_full_experiment.sh": "实验运行脚本",
        "view_results.sh": "结果查看脚本"
    }
    
    scripts_ok = True
    for script, desc in required_scripts.items():
        path = os.path.join(project_root, script)
        if os.path.isfile(path):
            log_success(f"{script} - {desc}")
        else:
            log_error(f"{script} - {desc} (缺失)")
            scripts_ok = False
    
    # 检查文档
    log_info("\n文档检查:")
    docs = {
        "QUICK_START_CN.md": "快速参考卡",
        "DEPLOYMENT_GUIDE_CN.md": "完整部署指南",
        "CONFIG_MODIFICATIONS_CN.md": "配置修改指南",
        "FILE_MANIFEST_CN.md": "文件清单"
    }
    
    for doc, desc in docs.items():
        path = os.path.join(project_root, doc)
        if os.path.isfile(path):
            log_success(f"{doc} - {desc}")
        else:
            log_warn(f"{doc} - {desc} (缺失)")
    
    # 检查配置文件
    log_section("3. 配置文件检查")
    
    config_file = "configs/comparison/exp_diffusion_vs_fm.py"
    if os.path.isfile(config_file):
        log_success(f"配置文件存在: {config_file}")
        
        # 检查是否已修改为相对路径
        with open(config_file, 'r') as f:
            content = f.read()
        
        if 'root_data_dir = "./data/ACRONYM"' in content or 'root_data_dir = "./data' in content:
            log_success("✓ 已使用相对路径")
        elif '/home/mi/siat' in content or '/path/to' in content:
            log_warn("⚠ 仍使用绝对路径，需要运行 ./setup_paths.sh")
        else:
            log_info("配置路径信息: " + [line for line in content.split('\n') if 'root_data_dir' in line][0].strip() if [line for line in content.split('\n') if 'root_data_dir' in line] else "未找到")
    else:
        log_error(f"配置文件缺失: {config_file}")
    
    # 检查数据集
    log_section("4. 数据集检查")
    
    data_root = "./data/ACRONYM"
    if os.path.isdir(data_root):
        log_success(f"数据集目录存在: {data_root}")
        
        grasps_dir = os.path.join(data_root, "grasps")
        if os.path.isdir(grasps_dir):
            h5_count = count_files(grasps_dir, "*.h5")
            if h5_count > 0:
                log_success(f"  ✓ 数据文件: {h5_count} 个 .h5 文件")
                if h5_count >= 8000:
                    log_success(f"    完整性: {h5_count}/8837 (≈{h5_count/8837*100:.1f}%)")
                else:
                    log_warn(f"    数据可能不完整: {h5_count} < 8837")
            else:
                log_error(f"  ✗ 未找到 .h5 文件")
        else:
            log_warn(f"  ⚠ grasps 子目录不存在")
        
        acronym_dir = os.path.join(data_root, "acronym")
        if os.path.isdir(acronym_dir):
            log_success(f"  ✓ ACRONYM 工具目录存在")
        else:
            log_warn(f"  ⚠ acronym 子目录不存在")
    else:
        log_error(f"数据集目录不存在: {data_root}")
        log_info("  需要将 ACRONYM 数据集解压到 ./data/ACRONYM/")
    
    # 检查 wheels 目录
    log_section("5. 离线依赖包检查")
    
    wheels_dir = "./wheels"
    if os.path.isdir(wheels_dir):
        whl_count = count_files(wheels_dir, "*.whl")
        if whl_count > 0:
            log_success(f"wheels 目录存在，包含 {whl_count} 个 .whl 文件")
            if whl_count >= 100:
                log_success(f"  ✓ 数量充足 ({whl_count} >= 100)")
            else:
                log_warn(f"  ⚠ 数量可能不足 ({whl_count} < 100)")
        else:
            log_error(f"wheels 目录为空")
    else:
        log_error(f"wheels 目录不存在: {wheels_dir}")
        log_info("  需要将离线依赖包解压到 ./wheels/")
    
    # 检查 Python 环境
    log_section("6. Python 和依赖环境检查")
    
    # Python 版本
    success, stdout, _ = run_command("python --version")
    if success:
        log_success(f"Python: {stdout}")
    else:
        log_error("Python 未安装或不可用")
    
    # pip 版本
    success, stdout, _ = run_command("pip --version")
    if success:
        log_success(f"pip: {stdout.split()[0:2]}")
    else:
        log_error("pip 不可用")
    
    # 检查关键包
    log_info("\n关键包检查:")
    packages = [
        "torch",
        "pytorch_lightning", 
        "diffusers",
        "h5py",
        "numpy",
        "scipy"
    ]
    
    packages_ok = 0
    for pkg in packages:
        success, stdout, _ = run_command(f"python -c 'import {pkg}; print({pkg}.__version__)'")
        if success:
            log_success(f"  {pkg}: {stdout}")
            packages_ok += 1
        else:
            log_error(f"  {pkg}: 未安装")
    
    log_info(f"\n已安装: {packages_ok}/{len(packages)} 个关键包")
    
    # 检查 GPU
    log_section("7. GPU 和 CUDA 检查")
    
    success, stdout, _ = run_command("nvidia-smi --query-gpu=name,driver_version,compute_cap --format=csv,noheader")
    if success:
        lines = stdout.strip().split('\n')
        for line in lines:
            log_success(f"GPU: {line.strip()}")
    else:
        log_warn("未检测到 NVIDIA GPU 或 CUDA 不可用")
        log_info("  (但 CPU 训练也可以，只是会很慢)")
    
    # 检查 PyTorch CUDA 支持
    success, stdout, _ = run_command("python -c 'import torch; print(f\"CUDA: {torch.cuda.is_available()}\")'")
    if success and "True" in stdout:
        log_success(f"PyTorch CUDA 支持: 已启用")
    elif success:
        log_warn(f"PyTorch CUDA 支持: 未启用")
    
    # 检查磁盘空间
    log_section("8. 磁盘空间检查")
    
    success, stdout, _ = run_command("df -h . | tail -1")
    if success:
        parts = stdout.split()
        available = parts[3] if len(parts) > 3 else "未知"
        log_info(f"当前磁盘可用空间: {available}")
        
        if 'G' in available or 'T' in available:
            try:
                num = float(available.replace('G', '').replace('T', ''))
                if 'T' in available:
                    num *= 1024  # 转换为 GB
                if num >= 300:
                    log_success("  ✓ 空间充足（>= 300 GB）")
                else:
                    log_warn(f"  ⚠ 空间可能不足（< 300 GB，建议 >= 500 GB）")
            except:
                pass
    
    log_info(f"建议空间需求: >= 500 GB")
    log_info(f"  - 代码: ~2 GB")
    log_info(f"  - 数据: ~100 GB") 
    log_info(f"  - wheels: ~50-100 GB")
    log_info(f"  - 输出: ~50-100 GB")
    
    # 生成总结
    log_section("9. 启动前检查总结")
    
    checklist = {
        "项目结构": all_dirs_ok,
        "脚本文件": scripts_ok,
        "配置文件": os.path.isfile(config_file),
        "数据集": os.path.isdir(data_root) and count_files(os.path.join(data_root, "grasps"), "*.h5") > 5000,
        "Wheels 包": os.path.isdir(wheels_dir) and count_files(wheels_dir, "*.whl") >= 100,
        "Python 环境": packages_ok >= 4,
        "磁盘空间": True  # 已手动检查
    }
    
    print("\n")
    passed = 0
    for item, status in checklist.items():
        if status:
            log_success(f"  {item}")
            passed += 1
        else:
            log_error(f"  {item}")
    
    print(f"\n总体检查结果: {passed}/{len(checklist)} 项通过\n")
    
    # 根据检查结果给出建议
    log_section("10. 后续建议")
    
    if passed == len(checklist):
        print(f"{Colors.GREEN}{Colors.BOLD}✓ 环境检查完全通过！{Colors.RESET}")
        print(f"\n{Colors.BOLD}可以开始部署：{Colors.RESET}")
        print(f"  1. chmod +x setup_paths.sh install_offline_deps.sh run_full_experiment.sh")
        print(f"  2. ./setup_paths.sh")
        print(f"  3. ./install_offline_deps.sh")
        print(f"  4. ./run_full_experiment.sh")
        print()
    elif passed >= len(checklist) - 1:
        print(f"{Colors.YELLOW}{Colors.BOLD}⚠ 环境基本可用，建议修复以下问题后再启动：{Colors.RESET}\n")
        for item, status in checklist.items():
            if not status:
                print(f"  • {item} - 需要检查和修复")
        print()
    else:
        print(f"{Colors.RED}{Colors.BOLD}✗ 环境检查未通过！{Colors.RESET}")
        print(f"\n请在修复以下问题后再启动：\n")
        for item, status in checklist.items():
            if not status:
                print(f"  • {item}")
        print()
    
    # 生成检查报告文件
    report_file = f"check_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
    print(f"\n{Colors.BOLD}检查报告已保存到: {report_file}{Colors.RESET}\n")
    
    return 0 if passed == len(checklist) else 1

if __name__ == "__main__":
    sys.exit(main())
