data "aws_caller_identity" "current" {}

# 会計マネージャユーザの作成
resource "aws_iam_user" "finance_manager" {
  name = "FinanceManager"
}

# 会計一般ユーザの作成
resource "aws_iam_user" "finance_user" {
  name = "FinanceUser"
}


# Billingフルアクセスグループ
resource "aws_iam_group" "billing_full_access_group" {
  name = "BillingFullAccessGroup"
}

# Billing閲覧グループ
resource "aws_iam_group" "billing_view_access_group" {
  name = "BillingViewAccessGroup"
}

# IP権限をグループポリシーへアタッチ
resource "aws_iam_group_policy_attachment" "billing_full_access_group_attachment_ip_limit" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/IPLimit"
  group      = aws_iam_group.billing_full_access_group.name
}
resource "aws_iam_group_policy_attachment" "billing_view_access_group_attachment_ip_limit" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/IPLimit"
  group      = aws_iam_group.billing_view_access_group.name
}


# Billingフルアクセス権限をBillingフルアクセスグループへアタッチ
resource "aws_iam_group_policy_attachment" "billing_full_access_group_attachment_billing" {
  policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
  group      = aws_iam_group.billing_full_access_group.name
}

# Billing閲覧権限をBilling閲覧グループへアタッチ
resource "aws_iam_group_policy_attachment" "billing_view_access_group_attachment_aws_billing_read_only_access" {
  policy_arn = "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"
  group      = aws_iam_group.billing_view_access_group.name
}

# 会計マネージャユーザをBillingフルアクセス権限グループに所属させる
resource "aws_iam_user_group_membership" "finance_manager_belongs_to_billing_full_access_group" {
  user   = aws_iam_user.finance_manager.name
  groups = [aws_iam_group.billing_full_access_group.name]
}

# 会計一般ユーザをBilling閲覧権限グループに所属させる
resource "aws_iam_user_group_membership" "finance_user_belongs_to_billing_view_access_group" {
  user   = aws_iam_user.finance_user.name
  groups = [aws_iam_group.billing_view_access_group.name]
}
