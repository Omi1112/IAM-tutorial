data "aws_caller_identity" "current" {}

# マネージャユーザの作成
resource "aws_iam_user" "finance_manager" {
  name = "FinanceManager"
}

# Billingフルアクセス権限グループ
resource "aws_iam_group" "billing_full_access_group" {
  name = "BillingFullAccessGroup"
}

# IP権限をグループポリシーへアタッチ
resource "aws_iam_group_policy_attachment" "billing_full_access_group_attachment_ip_limit" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/IPLimit"
  group      = aws_iam_group.billing_full_access_group.name
}

# Billingフルアクセス権限をBillingフルアクセス権限グループポリシーへアタッチ
resource "aws_iam_group_policy_attachment" "billing_full_access_group_attachment_aws_billing_read_only_access" {
  policy_arn = "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"
  group      = aws_iam_group.billing_full_access_group.name
}


# マネージャユーザをグループに所属させる
resource "aws_iam_user_group_membership" "finance_manager_belongs_to_billing_full_access_group" {
  user   = aws_iam_user.finance_manager.name
  groups = [aws_iam_group.billing_full_access_group.name]
}
