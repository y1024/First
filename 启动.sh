#!/bin/bash
cd "$(dirname "$0")"

if ! command -v uv >/dev/null 2>&1; then
    echo
    echo "  [ERROR] uv not found. Install uv first:"
    echo "  pip install uv"
    echo
    exit 1
fi

echo
echo "  Syncing project environment with uv..."
echo
uv sync -i https://pypi.tuna.tsinghua.edu.cn/simple
if [ $? -ne 0 ]; then
    echo
    echo "  [ERROR] uv sync failed! Check your network or uv config."
    echo
    exit 1
fi

.venv/bin/python gui.py &
exit 0
