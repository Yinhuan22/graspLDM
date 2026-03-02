#!/bin/bash

##############################################################################
# graspLDM 结果查看综合工具
#
# 功能：一个交互式菜单，提供所有查看结果的选项
#
# 用法：
#   chmod +x view_all_results.sh
#   ./view_all_results.sh
#
##############################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 获取项目根目录
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 打印标题
print_header() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                                                            ║${NC}"
    echo -e "${BLUE}║       📊 graspLDM 对比实验结果查看工具                     ║${NC}"
    echo -e "${BLUE}║                                                            ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 打印菜单
print_menu() {
    echo -e "${YELLOW}请选择要执行的操作：${NC}"
    echo ""
    echo -e "${CYAN}  📊 TensorBoard 可视化${NC}"
    echo "  1️⃣  启动 TensorBoard（所有模型的训练曲线）"
    echo "  2️⃣  启动 VAE TensorBoard（端口 6006）"
    echo "  3️⃣  启动 Diffusion TensorBoard（端口 6007）"
    echo "  4️⃣  启动 FM TensorBoard（端口 6008）"
    echo ""
    echo -e "${CYAN}  📋 查看对比结果${NC}"
    echo "  5️⃣  查看 CSV 对比表格（Python）"
    echo "  6️⃣  查看 CSV 对比表格（命令行）"
    echo ""
    echo -e "${CYAN}  🎨 可视化与下载${NC}"
    echo "  7️⃣  生成 PNG 可视化 HTML 查看器"
    echo "  8️⃣  启动 HTTP 服务器浏览结果（端口 8000）"
    echo "  9️⃣  打包所有结果为压缩文件"
    echo ""
    echo -e "${CYAN}  📁 目录和日志${NC}"
    echo "  🔟 显示结果目录结构"
    echo "  1️⃣1️⃣ 查看最新的完整训练日志"
    echo "  1️⃣2️⃣ 查看最新的 VAE 训练日志"
    echo "  1️⃣3️⃣ 查看最新的 Diffusion 训练日志"
    echo "  1️⃣4️⃣ 查看最新的 FM 训练日志"
    echo "  1️⃣5️⃣ 查看最新的评估日志"
    echo ""
    echo -e "${CYAN}  ⚙️  工具${NC}"
    echo "  1️⃣6️⃣ 显示此菜单说明"
    echo "  0️⃣  退出"
    echo ""
}

# 选择菜单项
read_choice() {
    read -p "输入选项 (0-16): " choice
}

# 执行选项
case_selection() {
    choice=$1
    
    case $choice in
        1)
            echo ""
            echo -e "${GREEN}启动 TensorBoard（所有模型）...${NC}"
            echo "地址: http://localhost:6006"
            echo ""
            echo -e "${YELLOW}提示：按 Ctrl+C 停止 TensorBoard${NC}"
            echo ""
            cd "$PROJECT_ROOT"
            tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm --port=6006 --reload_interval=10
            ;;
            
        2)
            echo ""
            echo -e "${GREEN}启动 VAE TensorBoard（端口 6006）...${NC}"
            echo "地址: http://localhost:6006"
            echo ""
            echo -e "${YELLOW}提示：按 Ctrl+C 停止 TensorBoard${NC}"
            echo ""
            cd "$PROJECT_ROOT"
            tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/vae/logs --port=6006
            ;;
            
        3)
            echo ""
            echo -e "${GREEN}启动 Diffusion TensorBoard（端口 6007）...${NC}"
            echo "地址: http://localhost:6007"
            echo ""
            echo -e "${YELLOW}提示：按 Ctrl+C 停止 TensorBoard${NC}"
            echo ""
            cd "$PROJECT_ROOT"
            tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/ddm/logs --port=6007
            ;;
            
        4)
            echo ""
            echo -e "${GREEN}启动 FM TensorBoard（端口 6008）...${NC}"
            echo "地址: http://localhost:6008"
            echo ""
            echo -e "${YELLOW}提示：按 Ctrl+C 停止 TensorBoard${NC}"
            echo ""
            cd "$PROJECT_ROOT"
            tensorboard --logdir=./output/comparison/exp_diffusion_vs_fm/fm/logs --port=6008
            ;;
            
        5)
            echo ""
            echo -e "${GREEN}查看 CSV 对比表格（Python）...${NC}"
            echo ""
            cd "$PROJECT_ROOT"
            python3 view_csv_results.py
            echo ""
            read -p "按 Enter 继续..."
            ;;
            
        6)
            echo ""
            echo -e "${GREEN}查看 CSV 对比表格（命令行）...${NC}"
            echo ""
            CSV_FILE="$PROJECT_ROOT/output/comparison/exp_diffusion_vs_fm/comparison_results/comparison_table.csv"
            
            if [ -f "$CSV_FILE" ]; then
                echo "📄 CSV 文件: $CSV_FILE"
                echo ""
                head -20 "$CSV_FILE" | column -t -s,
                echo ""
                echo "..."
                echo ""
                echo "💡 查看完整文件，请使用: less $CSV_FILE"
            else
                echo -e "${RED}❌ CSV 文件不存在: $CSV_FILE${NC}"
            fi
            echo ""
            read -p "按 Enter 继续..."
            ;;
            
        7)
            echo ""
            echo -e "${GREEN}生成 PNG 可视化 HTML 查看器...${NC}"
            echo ""
            cd "$PROJECT_ROOT"
            python3 generate_visualization_html.py
            echo ""
            echo -e "${GREEN}✅ HTML 查看器已生成${NC}"
            echo "📂 位置: ./output/comparison/visualization_viewer.html"
            echo ""
            read -p "按 Enter 继续..."
            ;;
            
        8)
            echo ""
            echo -e "${GREEN}启动 HTTP 服务器（端口 8000）...${NC}"
            echo "地址: http://localhost:8000"
            echo ""
            echo "可访问的资源："
            echo "  • 完整项目: http://localhost:8000"
            echo "  • 可视化查看器: http://localhost:8000/output/comparison/visualization_viewer.html"
            echo "  • 结果目录: http://localhost:8000/output/comparison/exp_diffusion_vs_fm/comparison_results"
            echo ""
            echo -e "${YELLOW}提示：按 Ctrl+C 停止服务器${NC}"
            echo ""
            cd "$PROJECT_ROOT"
            python3 -m http.server 8000
            ;;
            
        9)
            echo ""
            echo -e "${GREEN}打包所有结果为压缩文件...${NC}"
            echo ""
            cd "$PROJECT_ROOT"
            chmod +x ./package_results.sh
            ./package_results.sh
            echo ""
            read -p "按 Enter 继续..."
            ;;
            
        10)
            echo ""
            echo -e "${GREEN}显示结果目录结构${NC}"
            echo ""
            
            RESULTS_DIR="$PROJECT_ROOT/output/comparison/exp_diffusion_vs_fm/comparison_results"
            
            if [ -d "$RESULTS_DIR" ]; then
                echo "📁 $RESULTS_DIR"
                echo ""
                if command -v tree &> /dev/null; then
                    tree "$RESULTS_DIR"
                else
                    find "$RESULTS_DIR" -type f | sed 's|[^/]*/| |g;s|^ ||' | sort
                fi
            else
                echo -e "${RED}❌ 结果目录不存在${NC}"
            fi
            echo ""
            read -p "按 Enter 继续..."
            ;;
            
        11)
            echo ""
            echo -e "${GREEN}查看最新的完整训练日志${NC}"
            echo ""
            
            LATEST_LOG=$(find "$PROJECT_ROOT/output/logs" -name "full_experiment_*.log" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
            
            if [ -n "$LATEST_LOG" ]; then
                echo "📄 日志文件: $LATEST_LOG"
                echo ""
                echo "（显示最后 100 行）"
                echo ""
                tail -100 "$LATEST_LOG"
            else
                echo -e "${RED}❌ 未找到日志文件${NC}"
            fi
            echo ""
            read -p "按 Enter 继续..."
            ;;
            
        12)
            echo ""
            echo -e "${GREEN}查看最新的 VAE 训练日志${NC}"
            echo ""
            
            LATEST_LOG=$(find "$PROJECT_ROOT/output/logs" -name "01_vae_training_*.log" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
            
            if [ -n "$LATEST_LOG" ]; then
                echo "📄 日志文件: $LATEST_LOG"
                echo ""
                tail -100 "$LATEST_LOG"
            else
                echo -e "${RED}❌ 未找到 VAE 日志${NC}"
            fi
            echo ""
            read -p "按 Enter 继续..."
            ;;
            
        13)
            echo ""
            echo -e "${GREEN}查看最新的 Diffusion 训练日志${NC}"
            echo ""
            
            LATEST_LOG=$(find "$PROJECT_ROOT/output/logs" -name "02_diffusion_training_*.log" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
            
            if [ -n "$LATEST_LOG" ]; then
                echo "📄 日志文件: $LATEST_LOG"
                echo ""
                tail -100 "$LATEST_LOG"
            else
                echo -e "${RED}❌ 未找到 Diffusion 日志${NC}"
            fi
            echo ""
            read -p "按 Enter 继续..."
            ;;
            
        14)
            echo ""
            echo -e "${GREEN}查看最新的 FM 训练日志${NC}"
            echo ""
            
            LATEST_LOG=$(find "$PROJECT_ROOT/output/logs" -name "03_flow_matching_training_*.log" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
            
            if [ -n "$LATEST_LOG" ]; then
                echo "📄 日志文件: $LATEST_LOG"
                echo ""
                tail -100 "$LATEST_LOG"
            else
                echo -e "${RED}❌ 未找到 FM 日志${NC}"
            fi
            echo ""
            read -p "按 Enter 继续..."
            ;;
            
        15)
            echo ""
            echo -e "${GREEN}查看最新的评估日志${NC}"
            echo ""
            
            LATEST_LOG=$(find "$PROJECT_ROOT/output/logs" -name "04_evaluation_*.log" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
            
            if [ -n "$LATEST_LOG" ]; then
                echo "📄 日志文件: $LATEST_LOG"
                echo ""
                tail -100 "$LATEST_LOG"
            else
                echo -e "${RED}❌ 未找到评估日志${NC}"
            fi
            echo ""
            read -p "按 Enter 继续..."
            ;;
            
        16)
            echo ""
            print_help
            echo ""
            read -p "按 Enter 继续..."
            ;;
            
        0)
            echo ""
            echo -e "${GREEN}👋 再见！${NC}"
            echo ""
            exit 0
            ;;
            
        *)
            echo ""
            echo -e "${RED}❌ 无效的选项${NC}"
            echo ""
            read -p "按 Enter 继续..."
            ;;
    esac
}

# 打印帮助信息
print_help() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}菜单说明${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}1-4: TensorBoard 可视化${NC}"
    echo "  • 启动 TensorBoard 服务器查看训练曲线、损失函数等"
    echo "  • 选项 1：查看所有模型的所有指标"
    echo "  • 选项 2-4：分别查看各模型的详细指标"
    echo "  • 访问: http://localhost:PORT"
    echo "  • 停止: Ctrl+C"
    echo ""
    echo -e "${CYAN}5-6: 查看对比结果表格${NC}"
    echo "  • 选项 5：使用 Python 脚本，格式美观，支持统计摘要"
    echo "  • 选项 6：使用命令行，快速查看"
    echo ""
    echo -e "${CYAN}7-8: 可视化与浏览${NC}"
    echo "  • 选项 7：生成 HTML 查看器，方便查看所有 PNG 图片"
    echo "  • 选项 8：启动 HTTP 服务器，在浏览器中浏览所有文件"
    echo ""
    echo -e "${CYAN}9: 打包下载${NC}"
    echo "  • 打包结果为 tar.gz 格式，方便下载到本地"
    echo "  • 生成 3 个压缩包：完整版、轻量级、日志版"
    echo ""
    echo -e "${CYAN}10: 目录结构${NC}"
    echo "  • 显示结果文件的完整目录树"
    echo ""
    echo -e "${CYAN}11-15: 查看日志${NC}"
    echo "  • 查看各个训练阶段的最新日志"
    echo "  • 显示最后 100 行内容"
    echo ""
    echo -e "${CYAN}16: 帮助${NC}"
    echo "  • 显示此菜单说明"
    echo ""
}

# 主循环
while true; do
    print_header
    print_menu
    read_choice
    
    if [ -z "$choice" ]; then
        continue
    fi
    
    case_selection "$choice"
done
