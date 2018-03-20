data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_agent" {
  statement {
    sid =  "CloudWatchAgentServerPolicy"
    effect =  "Allow"
    actions = [
      "logs:CreateLogStream",
      "cloudwatch:PutMetricData",
      "ec2:DescribeTags",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
    ]
    resources =  ["*"]
  }
}

data "aws_iam_policy_document" "sqs" {
  statement {
    sid = "SQSPolicy"
    effect = "Allow"
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueUrl",
      "sqs:ChangeMessageVisibility",
      "sqs:SendMessageBatch",
      "sqs:UntagQueue",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:ListQueueTags",
      "sqs:TagQueue",
      "sqs:ListDeadLetterSourceQueues",
      "sqs:DeleteMessageBatch",
      "sqs:PurgeQueue",
      "sqs:DeleteQueue",
      "sqs:CreateQueue",
      "sqs:ChangeMessageVisibilityBatch",
      "sqs:SetQueueAttributes"
    ]
    resources = ["${aws_sqs_queue.deployment_payload.arn}"]
  }
}
