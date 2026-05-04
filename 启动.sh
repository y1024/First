#!/bin/bash
cd "$(dirname "$0")"

# ── 配置文件路径 ──
CHOICE_FILE=".launch_choice"

# ══════════════════════════════════════════
#  对话框工具（macOS 用 osascript，Linux 降级为 read）
# ══════════════════════════════════════════
dialog_choice() {
    # $1=标题  $2=提示文字  $3=按钮1  $4=按钮2
    # 返回 0 = 按钮1，1 = 按钮2
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local btn
        btn=$(osascript -e "button returned of (display dialog \"$2\" with title \"$1\" buttons {\"$4\", \"$3\"} default button \"$3\")" 2>/dev/null)
        [[ "$btn" == "$3" ]] && return 0 || return 1
    else
        echo ""
        echo "  $1"
        echo "  $2"
        echo "  [1] $3   [2] $4"
        read -rp "  请输入选择 (1/2): " sel
        [[ "$sel" == "1" ]] && return 0 || return 1
    fi
}

dialog_info() {
    # $1=标题  $2=内容
    if [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e "display dialog \"$2\" with title \"$1\" buttons {\"确定\"} default button \"确定\"" >/dev/null 2>&1
    else
        echo ""
        echo "  [$1] $2"
        echo ""
    fi
}

# ══════════════════════════════════════════
#  读取上次选择
# ══════════════════════════════════════════
if [[ -f "$CHOICE_FILE" ]]; then
    SAVED=$(cat "$CHOICE_FILE")
    # 直接按上次结果启动
    if [[ "$SAVED" == "uv" ]]; then
        echo "  [启动] 使用 uv 虚拟环境..."
        uv sync -i https://pypi.tuna.tsinghua.edu.cn/simple
        if [[ $? -ne 0 ]]; then
            dialog_info "启动失败" "uv sync 失败，请检查网络或 uv 配置。"
            exit 1
        fi
        .venv/bin/python gui.py &
        exit 0
    elif [[ "$SAVED" == "system" ]]; then
        echo "  [启动] 使用系统 Python..."
        python3 gui.py &
        exit 0
    fi
fi

# ══════════════════════════════════════════
#  首次运行：让用户选择环境
# ══════════════════════════════════════════
dialog_choice "First — 启动配置" \
    "请选择运行方式：\n\n  ✦ uv 虚拟环境（推荐）\n    自动隔离依赖，不影响系统 Python\n\n  ✦ 系统 Python\n    使用系统已安装的 Python 直接运行" \
    "uv 虚拟环境" "系统 Python"
USE_UV=$?

# ══════════════════════════════════════════
#  分支：uv 虚拟环境
# ══════════════════════════════════════════
if [[ $USE_UV -eq 0 ]]; then

    # 检查 uv 是否已安装
    if ! command -v uv >/dev/null 2>&1; then
        dialog_choice "未找到 uv" \
            "系统中未检测到 uv 工具。\n是否现在安装 uv？\n\n（将执行：pip install uv）" \
            "安装 uv" "取消"
        if [[ $? -eq 0 ]]; then
            echo "  正在安装 uv..."
            pip install uv
            if [[ $? -ne 0 ]]; then
                dialog_info "安装失败" "uv 安装失败，请手动执行：pip install uv"
                exit 1
            fi
        else
            echo "  已取消。"
            exit 0
        fi
    fi

    echo "  正在同步 uv 虚拟环境..."
    uv sync -i https://pypi.tuna.tsinghua.edu.cn/simple
    if [[ $? -ne 0 ]]; then
        dialog_info "同步失败" "uv sync 失败，请检查网络连接或 pyproject.toml 配置。"
        exit 1
    fi

    echo "uv" > "$CHOICE_FILE"
    .venv/bin/python gui.py &
    exit 0

# ══════════════════════════════════════════
#  分支：系统 Python
# ══════════════════════════════════════════
else

    # 检查 python3
    if ! command -v python3 >/dev/null 2>&1; then
        dialog_info "未找到 Python" "系统中未检测到 python3，请先安装 Python 3.9+。"
        exit 1
    fi

    # 检查是否缺少依赖
    MISSING=0
    python3 -c "import frida, websockets, google.protobuf, PySide6, Crypto" 2>/dev/null || MISSING=1

    if [[ $MISSING -eq 1 ]]; then
        dialog_choice "缺少依赖库" \
            "检测到部分依赖库未安装。\n是否现在安装？\n\n（将执行：pip install -r requirements.txt）" \
            "立即安装" "取消"
        if [[ $? -eq 0 ]]; then
            echo "  正在安装依赖..."
            pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
            if [[ $? -ne 0 ]]; then
                dialog_info "安装失败" "依赖安装失败，请检查网络或手动执行：\npip install -r requirements.txt"
                exit 1
            fi
        else
            echo "  已取消。"
            exit 0
        fi
    fi

    echo "system" > "$CHOICE_FILE"
    python3 gui.py &
    exit 0
fi
