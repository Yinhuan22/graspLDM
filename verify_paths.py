#!/usr/bin/env python3
# ============================================================================
# 路径验证和测试脚本
# 验证所有配置文件和代码中的相对路径是否正确
# ============================================================================

import os
import sys
from pathlib import Path

# 颜色定义
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'  # No Color

def log_info(msg):
    print(f"{BLUE}ℹ {msg}{NC}")

def log_success(msg):
    print(f"{GREEN}✓ {msg}{NC}")

def log_warning(msg):
    print(f"{YELLOW}⚠ {msg}{NC}")

def log_error(msg):
    print(f"{RED}✗ {msg}{NC}")

class PathValidator:
    def __init__(self):
        """初始化验证器，动态获取项目根目录"""
        self.project_root = Path(__file__).parent.absolute()
        self.results = {
            "passed": 0,
            "failed": 0,
            "warnings": 0
        }
        
    def check_directory_exists(self, rel_path, description):
        """检查目录是否存在"""
        abs_path = self.project_root / rel_path
        if abs_path.exists() and abs_path.is_dir():
            log_success(f"{description}: {abs_path}")
            self.results["passed"] += 1
            return True
        else:
            log_error(f"{description} 不存在: {abs_path}")
            self.results["failed"] += 1
            return False
    
    def check_file_exists(self, rel_path, description):
        """检查文件是否存在"""
        abs_path = self.project_root / rel_path
        if abs_path.exists() and abs_path.is_file():
            log_success(f"{description}: {abs_path}")
            self.results["passed"] += 1
            return True
        else:
            log_error(f"{description} 不存在: {abs_path}")
            self.results["failed"] += 1
            return False
    
    def check_config_file_imports(self):
        """检查配置文件是否能正确导入和获取项目根目录"""
        print(f"\n{BLUE}{'='*70}{NC}")
        print(f"{BLUE}检查配置文件的 PROJECT_ROOT 获取{NC}")
        print(f"{BLUE}{'='*70}{NC}\n")
        
        config_files = [
            "configs/comparison/exp_diffusion_vs_fm.py",
            "configs/generation/fpc/fpc_1a_latentc3_z4_pc64_180k.py",
            "configs/generation/partial_pc/ppc_1a_partial_63cat8k_filtered_latentc3_z16_pc256_180k.py",
        ]
        
        for config_file in config_files:
            abs_path = self.project_root / config_file
            if not abs_path.exists():
                log_error(f"配置文件不存在: {abs_path}")
                self.results["failed"] += 1
                continue
            
            try:
                with open(abs_path, 'r') as f:
                    content = f.read()
                
                # 检查是否包含 PROJECT_ROOT 定义
                if "PROJECT_ROOT" in content and "Path(__file__)" in content:
                    log_success(f"配置文件正确包含 PROJECT_ROOT: {config_file}")
                    self.results["passed"] += 1
                    
                    # 提取并验证 root_data_dir 的定义
                    if 'root_data_dir = str(PROJECT_ROOT / "data/ACRONYM")' in content:
                        log_success(f"  ✓ root_data_dir 使用相对路径: {config_file}")
                        self.results["passed"] += 1
                    else:
                        log_warning(f"  ⚠ root_data_dir 定义可能需要检查: {config_file}")
                        self.results["warnings"] += 1
                else:
                    log_error(f"配置文件缺少 PROJECT_ROOT 定义: {config_file}")
                    self.results["failed"] += 1
                    
            except Exception as e:
                log_error(f"读取配置文件失败: {config_file} - {e}")
                self.results["failed"] += 1
    
    def check_tool_files(self):
        """检查工具脚本中的路径定义"""
        print(f"\n{BLUE}{'='*70}{NC}")
        print(f"{BLUE}检查工具脚本中的 PROJECT_ROOT 获取{NC}")
        print(f"{BLUE}{'='*70}{NC}\n")
        
        tool_files = [
            ("tools/train_generator.py", ["PROJECT_ROOT", "Path(__file__)"]),
            ("vae_train_progress.py", ["PROJECT_ROOT", "Path(__file__)"]),
            ("fix_ckpt.py", ["PROJECT_ROOT", "Path(__file__)"]),
        ]
        
        for file_path, required_items in tool_files:
            abs_path = self.project_root / file_path
            if not abs_path.exists():
                log_error(f"文件不存在: {abs_path}")
                self.results["failed"] += 1
                continue
            
            try:
                with open(abs_path, 'r') as f:
                    content = f.read()
                
                all_present = all(item in content for item in required_items)
                if all_present:
                    log_success(f"工具脚本正确包含 PROJECT_ROOT: {file_path}")
                    self.results["passed"] += 1
                else:
                    missing = [item for item in required_items if item not in content]
                    log_error(f"工具脚本缺少必要的导入/定义: {file_path} - 缺少: {missing}")
                    self.results["failed"] += 1
                    
            except Exception as e:
                log_error(f"读取文件失败: {file_path} - {e}")
                self.results["failed"] += 1
    
    def run_all_checks(self):
        """运行所有检查"""
        print(f"\n{BLUE}{'='*70}{NC}")
        print(f"{BLUE}开始验证 graspLDM 项目路径配置{NC}")
        print(f"{BLUE}{'='*70}{NC}\n")
        
        log_info(f"项目根目录: {self.project_root}")
        
        # 检查关键目录
        print(f"\n{BLUE}检查关键目录结构{NC}\n")
        self.check_directory_exists("data", "数据目录")
        self.check_directory_exists("data/ACRONYM", "ACRONYM 数据集")
        self.check_directory_exists("output", "输出目录")
        self.check_directory_exists("configs", "配置目录")
        self.check_directory_exists("tools", "工具目录")
        self.check_directory_exists("grasp_ldm", "主包目录")
        
        # 检查关键文件
        print(f"\n{BLUE}检查关键文件{NC}\n")
        self.check_file_exists("setup.py", "setup.py")
        self.check_file_exists("requirements.txt", "requirements.txt")
        self.check_file_exists("environment.yml", "environment.yml")
        
        # 检查配置文件
        self.check_config_file_imports()
        
        # 检查工具脚本
        self.check_tool_files()
        
        # 生成报告
        self.print_report()
    
    def print_report(self):
        """打印验证报告"""
        print(f"\n{BLUE}{'='*70}{NC}")
        print(f"{BLUE}验证报告{NC}")
        print(f"{BLUE}{'='*70}{NC}\n")
        
        total = self.results["passed"] + self.results["failed"] + self.results["warnings"]
        
        print(f"总检查数: {total}")
        print(f"{GREEN}✓ 通过: {self.results['passed']}{NC}")
        print(f"{RED}✗ 失败: {self.results['failed']}{NC}")
        print(f"{YELLOW}⚠ 警告: {self.results['warnings']}{NC}")
        
        if self.results["failed"] == 0:
            print(f"\n{GREEN}✅ 所有路径配置验证通过！{NC}")
            return True
        else:
            print(f"\n{RED}❌ 存在 {self.results['failed']} 个问题需要修复{NC}")
            return False


def test_dynamic_path_resolution():
    """测试动态路径解析"""
    print(f"\n{BLUE}{'='*70}{NC}")
    print(f"{BLUE}测试动态路径解析示例{NC}")
    print(f"{BLUE}{'='*70}{NC}\n")
    
    # 示例 1: 从配置文件获取项目根目录
    print(f"{YELLOW}示例 1: 从配置文件获取项目根目录{NC}")
    config_path = Path(__file__).parent / "configs/comparison/exp_diffusion_vs_fm.py"
    project_root = config_path.parent.parent.parent
    print(f"  配置文件路径: {config_path}")
    print(f"  推导的项目根目录: {project_root}")
    print(f"  数据目录: {project_root / 'data/ACRONYM'}")
    print()
    
    # 示例 2: 从训练脚本获取项目根目录
    print(f"{YELLOW}示例 2: 从训练脚本获取项目根目录{NC}")
    tool_path = Path(__file__).parent / "tools/train_generator.py"
    project_root = tool_path.parent.parent
    print(f"  工具脚本路径: {tool_path}")
    print(f"  推导的项目根目录: {project_root}")
    print(f"  配置目录: {project_root / 'configs'}")
    print()
    
    # 示例 3: 从主脚本获取项目根目录
    print(f"{YELLOW}示例 3: 从任意脚本获取项目根目录{NC}")
    script_path = Path(__file__)
    project_root = script_path.parent
    print(f"  脚本路径: {script_path}")
    print(f"  项目根目录: {project_root}")
    print(f"  输出目录: {project_root / 'output'}")


def main():
    """主函数"""
    validator = PathValidator()
    success = validator.run_all_checks()
    
    # 测试动态路径解析
    test_dynamic_path_resolution()
    
    # 返回状态码
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
