provider "aws" {
}

resource "random_id" "id" {
  byte_length = 8
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "/tmp/lambda-src-${random_id.id.hex}.zip"
  source_dir  = "src"
}

resource "aws_lambda_function" "lambda-package" {
  function_name = "${random_id.id.hex}-inline-function"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  handler = "index.handler"
  runtime = "nodejs14.x"
  role    = aws_iam_role.lambda_exec.arn
}

data "archive_file" "lambda_inline_zip" {
  type        = "zip"
  output_path = "/tmp/lambda-inline-${random_id.id.hex}.zip"
  source {
    content  = <<EOF
const b = await (async () => {
	return 2;
})();
export const handler = async (event) => {
	return "called from mjs! value=" + b;
};
EOF
    filename = "index.mjs"
  }
}

resource "aws_lambda_function" "lambda-mjs" {
  function_name = "${random_id.id.hex}-mjs-function"

  filename         = data.archive_file.lambda_inline_zip.output_path
  source_code_hash = data.archive_file.lambda_inline_zip.output_base64sha256

  handler = "index.handler"
  runtime = "nodejs14.x"
  role    = aws_iam_role.lambda_exec.arn
}

resource "aws_iam_role" "lambda_exec" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

output "lambda_package" {
  value = aws_lambda_function.lambda-package.arn
}

output "lambda_mjs" {
  value = aws_lambda_function.lambda-mjs.arn
}
