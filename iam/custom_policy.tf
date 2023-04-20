# NOTE: カスタムポリシーを作成して、IAMユーザにアタッチを行う。

resource "aws_iam_user" "policy_user" {
  name = "PolicyUser"
}

resource "aws_iam_policy" "read_only_iam_console_policy" {
  name = "UsersReadOnlyAccessToIAMConsole"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:GenerateCredentialReport",
          "iam:Get*",
          "iam:List*"
        ],
        Resource = "*"
      },
    ]
  })
}

# IP権限をグループポリシーへアタッチ
resource "aws_iam_user_policy_attachment" "policy_user_attachment_ip_limit" {
  user       = aws_iam_user.policy_user.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/IPLimit"
}

resource "aws_iam_user_policy_attachment" "policy_user_attachment_read_only_iam_console_policy" {
  user       = aws_iam_user.policy_user.name
  policy_arn = aws_iam_policy.read_only_iam_console_policy.arn
}
