# NOTE: MAFを設定した場合にのみEC2のフルアクセスを利用できるユーザ

resource "aws_iam_user" "mfa_user" {
  name = "MFAUser"
}

resource "aws_iam_group" "ec2_mfa" {
  name = "EC2MFA"
}

resource "aws_iam_user_group_membership" "mfa_user_belongs_to_billing_ec2_mfa" {
  user   = aws_iam_user.mfa_user.name
  groups = [aws_iam_group.ec2_mfa.name]
}

resource "aws_iam_policy" "force_mfa" {
  name = "Force_MFA"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowViewAccountInfo",
        Effect = "Allow",
        Action = [
          "iam:GetAccountPasswordPolicy",
          "iam:ListVirtualMFADevices"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowManageOwnPasswords",
        Effect = "Allow",
        Action = [
          "iam:ChangePassword",
          "iam:GetUser"
        ],
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid    = "AllowManageOwnAccessKeys",
        Effect = "Allow",
        Action = [
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:ListAccessKeys",
          "iam:UpdateAccessKey"
        ],
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid    = "AllowManageOwnSigningCertificates",
        Effect = "Allow",
        Action = [
          "iam:DeleteSigningCertificate",
          "iam:ListSigningCertificates",
          "iam:UpdateSigningCertificate",
          "iam:UploadSigningCertificate"
        ],
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid    = "AllowManageOwnSSHPublicKeys",
        Effect = "Allow",
        Action = [
          "iam:DeleteSSHPublicKey",
          "iam:GetSSHPublicKey",
          "iam:ListSSHPublicKeys",
          "iam:UpdateSSHPublicKey",
          "iam:UploadSSHPublicKey"
        ],
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid    = "AllowManageOwnGitCredentials",
        Effect = "Allow",
        Action = [
          "iam:CreateServiceSpecificCredential",
          "iam:DeleteServiceSpecificCredential",
          "iam:ListServiceSpecificCredentials",
          "iam:ResetServiceSpecificCredential",
          "iam:UpdateServiceSpecificCredential"
        ],
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid    = "AllowManageOwnVirtualMFADevice",
        Effect = "Allow",
        Action = [
          "iam:CreateVirtualMFADevice"
        ],
        Resource = "arn:aws:iam::*:mfa/*"
      },
      {
        Sid    = "AllowManageOwnUserMFA",
        Effect = "Allow",
        Action = [
          "iam:DeactivateMFADevice",
          "iam:EnableMFADevice",
          "iam:ListMFADevices",
          "iam:ResyncMFADevice"
        ],
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid    = "DenyAllExceptListedIfNoMFA",
        Effect = "Deny",
        "NotAction" : [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ResyncMFADevice",
          "sts:GetSessionToken"
        ],
        Resource = "*",
        "Condition" : {
          "BoolIfExists" : {
            "aws:MultiFactorAuthPresent" : "false"
          }
        }
      }
    ]
  })
}

# IP権限をグループポリシーへアタッチ
resource "aws_iam_user_policy_attachment" "mfa_user_attachment_ip_limit" {
  user       = aws_iam_user.mfa_user.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/IPLimit"
}

resource "aws_iam_group_policy_attachment" "mfa_user_attachment_force_mfa" {
  group      = aws_iam_group.ec2_mfa.name
  policy_arn = aws_iam_policy.force_mfa.arn
}

resource "aws_iam_group_policy_attachment" "mfa_user_attachment_ec2_full_access" {
  group      = aws_iam_group.ec2_mfa.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
