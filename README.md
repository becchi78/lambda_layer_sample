# AWS Lambda Python Common Layer

汎用的な Python ライブラリを含む AWS Lambda Layer 用のリポジトリです。

## 含まれるライブラリ

- pandas==2.0.0
- numpy==1.24.3
- requests==2.31.0
- pyyaml==6.0.1

## ディレクトリ構成

```text
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

## 必要な権限設定

### CodeBuild のサービスロール権限

CodeBuild が Layer を作成するために必要な権限を設定する必要があります。以下のインラインポリシーを CodeBuild のサービスロールに追加してください：

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:PublishLayerVersion",
        "lambda:DeleteLayerVersion",
        "lambda:GetLayerVersion",
        "lambda:ListLayerVersions"
      ],
      "Resource": [
        "arn:aws:lambda:${AWS::Region}:${AWS::AccountId}:layer:python-common",
        "arn:aws:lambda:${AWS::Region}:${AWS::AccountId}:layer:python-common:*"
      ]
    }
  ]
}
```

### ポリシーの追加方法

```bash
aws iam put-role-policy \
  --role-name codebuild-sam_lambda_layer_sample_codebuild-service-role \
  --policy-name lambda-layer-publish-policy \
  --policy-document file://lambda-layer-policy.json
```

### 権限の確認方法

```bash
# ロールの確認
aws iam get-role --role-name codebuild-sam_lambda_layer_sample_codebuild-service-role

# アタッチされたポリシーの確認
aws iam list-attached-role-policies --role-name codebuild-sam_lambda_layer_sample_codebuild-service-role

# インラインポリシーの確認
aws iam list-role-policies --role-name codebuild-sam_lambda_layer_sample_codebuild-service-role
```

## バージョン管理

### 新しいバージョンの作成

1. `requirements.txt`を更新
2. パイプラインを実行（または手動でビルド）
3. 新しいバージョンが自動的に作成されます

### バージョンの確認

```bash
aws lambda list-layer-versions --layer-name python-common
```

### サイズ制限

- Lambda Layer の最大サイズは解凍時に 250MB
- 依存関係を追加する際は、合計サイズに注意
