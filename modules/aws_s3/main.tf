locals {
  name              = var.bucket_name
  allow_public_read = var.allow_public_read
  create_queue      = var.create_queue
}

resource "aws_s3_bucket" "this" {
  bucket = local.name
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = local.allow_public_read ? 1 : 0

  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "this" {
  count = local.allow_public_read ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this[0].json
}

data "aws_iam_policy_document" "this" {
  count = local.allow_public_read ? 1 : 0

  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}

# ref: https://quickwit.hacker-linner.com/ingest-data/sqs-files/
# deadletter queue
resource "aws_sqs_queue" "s3_events_deadletter" {
  count = local.create_queue ? 1 : 0

  name = "${local.name}_event_queue_deadletter"
}

# notification queue
resource "aws_sqs_queue" "s3_events" {
  count = local.create_queue ? 1 : 0

  name   = "${local.name}_event_queue"
  policy = data.aws_iam_policy_document.sqs_notification[0].json

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.s3_events_deadletter[0].arn
    maxReceiveCount     = 5
  })
}

data "aws_iam_policy_document" "sqs_notification" {
  count = local.create_queue ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:*:*:${local.name}_event_queue"]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.this.arn]
    }
  }
}

resource "aws_sqs_queue_redrive_allow_policy" "s3_events_deadletter" {
  count = local.create_queue ? 1 : 0

  queue_url = aws_sqs_queue.s3_events_deadletter[0].id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.s3_events[0].arn]
  })
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count = local.create_queue ? 1 : 0

  bucket = aws_s3_bucket.this.id
  queue {
    queue_arn = aws_sqs_queue.s3_events[0].arn
    events    = ["s3:ObjectCreated:*"]
  }
}

# IAM for read queue and get object from s3
# data "aws_iam_policy_document" "iam" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "sqs:ReceiveMessage",
#       "sqs:DeleteMessage",
#       "sqs:ChangeMessageVisibility",
#       "sqs:GetQueueAttributes",
#     ]
#     resources = [aws_sqs_queue.s3_events[0].arn]
#   }
#   statement {
#     effect    = "Allow"
#     actions   = ["s3:GetObject"]
#     resources = ["${aws_s3_bucket.this.arn}/*"]
#   }
# }
