#!/bin/bash
set -e

# クリーンアップ
rm -rf python
mkdir -p python/lib/python3.12/site-packages/

# Pythonパッケージをインストール
pip install -r requirements.txt -t python/lib/python3.12/site-packages/

# 不要なファイルを削除してサイズを削減
find python -type d -name "__pycache__" -exec rm -rf {} +
find python -type d -name "*.dist-info" -exec rm -rf {} +

# ZIPファイル作成
zip -r layer.zip python
