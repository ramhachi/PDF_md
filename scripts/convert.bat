@echo off
REM MinerU PDF→Markdown変換スクリプト（Windows用）
setlocal enabledelayedexpansion

chcp 65001 >nul
echo.
echo === MinerU PDF→Markdown変換ツール ===
echo.

REM スクリプトのディレクトリから親ディレクトリ（プロジェクトルート）に移動
cd /d "%~dp0.."

REM inputディレクトリ内のPDFファイル数をカウント
set PDF_COUNT=0
for %%f in (input\*.pdf input\*.PDF) do (
    set /a PDF_COUNT+=1
)

if %PDF_COUNT% equ 0 (
    echo [エラー] inputフォルダにPDFファイルが見つかりません
    echo PDFファイルを .\input\ フォルダに配置してから再実行してください
    echo.
    pause
    exit /b 1
)

echo [✓] %PDF_COUNT%個のPDFファイルが見つかりました
echo.

REM Docker Desktopの起動確認
docker info >nul 2>&1
if errorlevel 1 (
    echo [エラー] Docker Desktopが起動していません
    echo Docker Desktopを起動してから再実行してください
    echo.
    pause
    exit /b 1
)

echo 変換を開始します...
echo.

REM MinerUで変換実行
REM -p: 入力PDFディレクトリ
REM -o: 出力ディレクトリ
REM -b pipeline: CPU版バックエンドを使用
REM -m auto: モデル自動選択
docker run --rm ^
    -v "%cd%\input:/app/input:ro" ^
    -v "%cd%\output:/app/output" ^
    -v "%cd%\logs:/app/logs" ^
    -e MINERU_DEVICE_MODE=cpu ^
    -e MINERU_LOG_LEVEL=INFO ^
    pdf_md-mineru-converter:latest ^
    mineru -p /app/input -o /app/output -b pipeline -m auto

if errorlevel 1 (
    echo.
    echo [✗] 変換中にエラーが発生しました
    echo     詳細は .\logs\ フォルダのログファイルを確認してください
    echo.
) else (
    echo.
    echo [✓] 変換が完了しました！
    echo     結果は .\output\ フォルダを確認してください
    echo.
)

pause
