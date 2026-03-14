FROM python:3.11-slim-bookworm

# システム依存関係（フォント、画像処理ライブラリ）のインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    fonts-noto-core \
    fonts-noto-cjk \
    fontconfig \
    libgl1 \
    libglib2.0-0 \
    libgomp1 \
    && fc-cache -fv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# PyTorch CPU版のインストール（GPU版より軽量）
RUN pip install --no-cache-dir \
    torch torchvision --index-url https://download.pytorch.org/whl/cpu

# MinerU本体とpipelineバックエンドの全依存関係をインストール
RUN pip install --no-cache-dir 'mineru[pipeline]>=2.7.0'

# 作業ディレクトリの設定
WORKDIR /app

# ボリュームマウントポイントの宣言
VOLUME ["/app/input", "/app/output", "/app/logs"]

# デフォルトコマンド（実行時に上書きされる）
CMD ["mineru", "--help"]
