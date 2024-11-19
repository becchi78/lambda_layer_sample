# AWS Lambda Layer Sample

汎用的な Python ライブラリを含む AWS Lambda Layer 用のリポジトリです。

## 含まれるライブラリ

- pandas==2.0.0
- numpy==1.24.3
- requests==2.31.0

## ディレクトリ構成

```bash
lambda-layers/
├── README.md
├── python-common/          # レイヤー名のディレクトリ
│   ├── requirements.txt    # 依存ライブラリの定義
│   └── build.sh           # ビルドスクリプト
└── buildspec.yml          # CodeBuildの設定
```

## ビルド方法

### ローカルでのビルド

```bash
cd python-common
chmod +x build.sh
./build.sh
```

### CodeBuild でのビルド

このリポジトリは AWS CodeBuild と統合されています。
`buildspec.yml`に定義されたステップに従って、自動的に Layer がビルドされデプロイされます。

## Layer の使用方法

### AWS Console 経由

1. Lambda 関数の設定画面を開く
2. [Layers]セクションを選択
3. [Add a layer]をクリック
4. `python-common`レイヤーを選択
5. 使用したいバージョンを選択

### AWS SAM での使用例

```yaml
AWSTemplateFormatVersion: "2010-09-09"
Transform: AWS::Serverless-2016-10-31

Resources:
  MyFunction:
    Type: AWS::Serverless::Function
    Properties:
      Handler: lambda_function.lambda_handler
      Runtime: python3.9
      CodeUri: ./
      Layers:
        - arn:aws:lambda:${AWS::Region}:${AWS::AccountId}:layer:python-common:1 # バージョンは適宜変更
```

### サンプルコード

```python
import json
import pandas as pd
import numpy as np
import requests

def lambda_handler(event, context):
    # Pandasを使用したデータ操作
    df = pd.DataFrame({
        'id': range(1, 4),
        'value': np.random.rand(3)
    })

    # Requestsを使用したAPI呼び出し
    response = requests.get('https://api.example.com/data')
    api_data = response.json()

    # データフレームをJSON形式に変換
    result = {
        'processed_data': df.to_dict('records'),
        'api_response': api_data
    }

    return {
        'statusCode': 200,
        'body': json.dumps(result)
    }
```

## 開発者向け情報

### 新しいライブラリの追加方法

1. `python-common/requirements.txt`に新しいライブラリを追加
2. バージョンは明示的に指定することを推奨

```text
# requirements.txtの例
pandas==2.0.0
new-library==1.0.0  # 新しいライブラリを追加
```

### レイヤーサイズの制限

- AWS Lambda Layer のサイズ制限は解凍時で 250MB
- 新しいライブラリを追加する際は、この制限を考慮

## トラブルシューティング

### よくある問題と解決方法

1. ライブラリのインポートエラー

   - Layer が正しく追加されているか確認
   - Lambda 関数のランタイムと Layer の互換性を確認

2. Layer 作成の失敗
   - ビルドログを確認
   - Python version の互換性を確認
   - 依存関係の矛盾がないか確認

## 注意事項

- この Layer は Python 3.9 用に最適化されています
- 本番環境での使用前に、テスト環境での動作確認を推奨
- Layer のバージョンを変更する際は、依存するすべての関数での動作確認が必要

## 貢献について

1. 新しいライブラリの追加や更新の提案は Issue で議論
2. 変更は Pull Request として提出
3. CI/CD パイプラインでのテスト成功を確認

## ライセンス

[使用するライセンスを記載]
