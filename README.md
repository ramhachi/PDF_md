# MinerU簡易PDF→Markdown変換ツール

PDFファイルをMarkdown形式に変換する、初心者向けの簡単ツールです。

[MinerU](https://github.com/opendatalab/MinerU)という高機能なOSSをDockerでラップし、「PDFをフォルダに入れて実行ファイルをダブルクリックするだけ」という極めてシンプルな操作を実現しました。

## このツールについて

- **簡単操作**: PDFを`input/`フォルダに入れて、スクリプトをダブルクリックするだけ
- **環境構築不要**: Dockerで完結するため、複雑な環境構築が不要
- **クロスプラットフォーム**: Mac、Windows、Linuxで動作
- **CPU版**: GPUなしでも動作（幅広い環境で利用可能）

## 必要環境

### 必須

- **Docker Desktop**: [公式サイト](https://www.docker.com/products/docker-desktop/)からインストール
  - Mac: Docker Desktop for Mac
  - Windows: Docker Desktop for Windows
  - Linux: Docker Engine + Docker Compose

### システム要件

- **メモリ**: 最低4GB、推奨8GB以上
- **ディスク空き容量**: 最低10GB（Dockerイメージ + 変換データ用）
- **OS**:
  - macOS 10.15以降
  - Windows 10/11 (64-bit)
  - Linux (主要ディストリビューション)

## 初回セットアップ

### 1. リポジトリの取得

以下のいずれかの方法でこのリポジトリを取得してください。

**方法A: Gitでクローン（推奨）**
```bash
git clone <このリポジトリのURL>
cd PDF_md
```

**方法B: ZIPダウンロード**
1. GitHubページの「Code」→「Download ZIP」をクリック
2. ダウンロードしたZIPファイルを解凍
3. 解凍したフォルダを任意の場所に配置

### 2. Dockerイメージのビルド

ターミナル（Mac/Linux）またはコマンドプロンプト（Windows）を開き、以下のコマンドを実行します。

```bash
# プロジェクトのディレクトリに移動
cd /path/to/PDF_md

# Mac/Linuxの場合
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
docker build -t pdf_md-mineru-converter:latest -f docker/Dockerfile docker/

# Windowsの場合
docker build -t pdf_md-mineru-converter:latest -f docker/Dockerfile docker/
```

**注意**: 初回ビルドには**10〜20分程度**かかります（PyTorch、MinerU、AIモデルのダウンロードが含まれるため）。気長にお待ちください。

### 3. ビルドの確認

ビルドが成功したか確認します。

```bash
# Mac/Linux
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
docker run --rm pdf_md-mineru-converter:latest mineru --version

# Windows
docker run --rm pdf_md-mineru-converter:latest mineru --version
```

`mineru, version 2.x.x` と表示されればOKです。

## 使い方

### Step 1: PDFファイルを配置

変換したいPDFファイルを `input/` フォルダにコピーします。

```
PDF_md/
├── input/           ← ここにPDFファイルを配置
│   ├── 論文.pdf
│   ├── レポート.pdf
│   └── ...
```

### Step 2: 変換スクリプトを実行

**Mac/Linuxの場合:**
```bash
# ダブルクリック、または
./scripts/convert.sh
```

**Windowsの場合:**
```
scripts\convert.bat をダブルクリック
```

変換が開始され、進行状況がターミナルに表示されます。

### Step 3: 変換結果を確認

変換が完了すると、`output/` フォルダに結果が保存されます。

```
PDF_md/
├── output/          ← 変換結果がここに保存される
│   ├── 論文/
│   │   ├── auto/
│   │   │   └── 論文.md
│   │   └── images/
│   ├── レポート/
│   │   ├── auto/
│   │   │   └── レポート.md
│   │   └── images/
```

各PDFファイルごとにフォルダが作成され、以下が含まれます：
- **`auto/<PDFファイル名>.md`**: 変換されたMarkdownファイル
- **`images/`**: PDF内の画像（抽出された場合）

## 出力形式

MinerUは以下のような構造でMarkdownを出力します：

```markdown
# PDFのタイトル

## セクション1

本文テキスト...

![画像](images/xxx.png)

## セクション2

...
```

- テキスト、見出し、リスト、テーブルが抽出されます
- 画像は`images/`フォルダに保存され、Markdownから参照されます
- 数式は可能な限りLaTeX形式で出力されます

## トラブルシューティング

### エラー: Docker Desktopが起動していません

**症状**: スクリプト実行時に「Docker Desktopが起動していません」と表示される

**解決方法**:
1. Docker Desktopアプリケーションを起動
2. Docker Desktopのアイコンがメニューバー（Mac）またはタスクトレイ（Windows）に表示されることを確認
3. 再度スクリプトを実行

### エラー: inputフォルダにPDFファイルが見つかりません

**症状**: スクリプト実行時に「PDFファイルが見つかりません」と表示される

**解決方法**:
1. `input/` フォルダに`.pdf`拡張子のファイルが配置されているか確認
2. ファイル名に不正な文字が含まれていないか確認
3. ファイルが破損していないか確認（他のPDFビューアで開けるか試す）

### エラー: 変換中にエラーが発生しました

**症状**: 変換は開始されるが、途中でエラーになる

**解決方法**:
1. `logs/` フォルダ内のログファイルを確認（詳細なエラーメッセージが記載されています）
2. メモリ不足の場合:
   - Docker Desktopの設定でメモリ割り当てを増やす（推奨: 8GB以上）
   - Mac: Docker Desktop → Preferences → Resources → Memory
   - Windows: Docker Desktop → Settings → Resources → Memory
3. PDFファイルが破損している、または特殊な形式の場合は変換できないことがあります

### エラー: docker-credential-desktop: executable file not found

**症状**: Dockerコマンド実行時に認証情報エラーが出る（主にMac）

**解決方法**:
スクリプトに以下の行を追加（既に含まれています）:
```bash
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
```

### 変換が遅い

**原因**: CPU版のため、GPU版と比較して処理時間が長くなります

**目安**:
- 10ページのPDF: 1〜3分
- 50ページのPDF: 5〜15分
- 100ページのPDF: 10〜30分

**対策**:
- 複数のPDFを一度に変換する場合は、まとめて実行（並列処理はされませんが、手間は減ります）
- 大量のPDFを処理する場合は夜間実行など時間に余裕をもって実行

### イメージサイズが大きい

**原因**: PyTorchやAIモデルが含まれるため、Dockerイメージが約3GB程度になります

**対策**: 特になし（必要な依存関係のため削減は困難）

## 高度な使い方

### ログの確認

変換処理の詳細ログは `logs/` フォルダに保存されます。エラー時の詳細情報が含まれています。

### カスタマイズ

スクリプト内の以下の箇所を編集することで、MinerUのオプションをカスタマイズできます：

**`scripts/convert.sh` または `scripts/convert.bat`**
```bash
mineru -p /app/input -o /app/output -b pipeline -m auto
```

- `-b pipeline`: バックエンドの指定（CPU版）
- `-m auto`: モデルの自動選択（`layout`、`text`等に変更可能）

詳細は[MinerUの公式ドキュメント](https://github.com/opendatalab/MinerU)を参照してください。

### Dockerイメージの更新

MinerUの新バージョンが公開された場合、以下の手順で更新できます：

1. `docker/Dockerfile` の `mineru>=2.7.0` を新しいバージョンに変更
2. 再度ビルドコマンドを実行
   ```bash
   docker build -t pdf_md-mineru-converter:latest -f docker/Dockerfile docker/
   ```

## ライセンス

- このツール: MIT License（自由に使用・改変可能）
- MinerU: [Apache License 2.0](https://github.com/opendatalab/MinerU/blob/master/LICENSE)

## サポート・問い合わせ

- **MinerUに関する問題**: [MinerU GitHub Issues](https://github.com/opendatalab/MinerU/issues)
- **このツールに関する問題**: [このリポジトリのIssues](<リポジトリのIssues URL>)

## 参考リンク

- [MinerU公式リポジトリ](https://github.com/opendatalab/MinerU)
- [Docker Desktop公式サイト](https://www.docker.com/products/docker-desktop/)
- [Markdown記法ガイド](https://www.markdownguide.org/)
