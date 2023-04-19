# 概要

AWS IAM の[チュートリアル](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/tutorials.html)を実施した時の Terraform コードです。

# 個別設定

- IAM ポリシーに IPLimit 名称の IP 制限を設定したポリシーを作成していること。
- 実行環境のの`~/.aws/credentials`に`tutorial`プロファイルを作成しており、IAM の操作権限が付与されていること。
- Terraform バージョン 1.1.3 で設定されていること
