#!/usr/bin/env bash

# MinerU PDF→Markdown変換スクリプト（Mac/Linux用）

set -e  # エラー時に即座に終了

# カラー出力の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# スクリプトのディレクトリから親ディレクトリ（プロジェクトルート）に移動
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo -e "${BLUE}=== MinerU PDF→Markdown変換ツール ===${NC}\n"

# inputディレクトリ内のPDFファイル数をカウント
PDF_COUNT=$(find ./input -maxdepth 1 -type f -iname "*.pdf" 2>/dev/null | wc -l | tr -d ' ')

if [ "$PDF_COUNT" -eq 0 ]; then
    echo -e "${RED}エラー: inputフォルダにPDFファイルが見つかりません${NC}"
    echo -e "${YELLOW}PDFファイルを ./input/ フォルダに配置してから再実行してください${NC}\n"
    read -p "Enterキーを押して終了..."
    exit 1
fi

echo -e "${GREEN}✓ ${PDF_COUNT}個のPDFファイルが見つかりました${NC}\n"

# Docker Desktopの起動確認
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}エラー: Docker Desktopが起動していません${NC}"
    echo -e "${YELLOW}Docker Desktopを起動してから再実行してください${NC}\n"
    read -p "Enterキーを押して終了..."
    exit 1
fi

# docker-credential-desktopへのPATHを追加
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"

echo -e "${BLUE}変換を開始します...${NC}\n"

# MinerUで変換実行
# -p: 入力PDFディレクトリ
# -o: 出力ディレクトリ
# -b pipeline: CPU版バックエンドを使用
# -m auto: モデル自動選択
if docker run --rm \
    -v "$PROJECT_ROOT/input:/app/input:ro" \
    -v "$PROJECT_ROOT/output:/app/output" \
    -v "$PROJECT_ROOT/logs:/app/logs" \
    -e MINERU_DEVICE_MODE=cpu \
    -e MINERU_LOG_LEVEL=INFO \
    pdf_md-mineru-converter:latest \
    mineru -p /app/input -o /app/output -b pipeline -m auto; then

    echo -e "\n${GREEN}✓ 変換が完了しました！${NC}"
    echo -e "${GREEN}  結果は ./output/ フォルダを確認してください${NC}\n"
else
    echo -e "\n${RED}✗ 変換中にエラーが発生しました${NC}"
    echo -e "${YELLOW}  詳細は ./logs/ フォルダのログファイルを確認してください${NC}\n"
fi

# ユーザーがEnterキーを押すまで待機
read -p "Enterキーを押して終了..."
