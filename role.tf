resource "aws_iam_role" "ec2-s3_access_role" {
  name               = "s3-role"
  assume_role_policy = "${file("${path.module}/user-data/assume-role-policy.json")}"
}
resource "aws_iam_instance_profile" "new_profile" {
  name  = "ec2-s3-role"
  role = "${aws_iam_role.ec2-s3_access_role.name}"
}

resource "aws_iam_policy" "policy" {
  name        = "mynew-policy"
  description = "A new policy"
  policy      = "${file("${path.module}/user-data/policy-s3-bucket.json")}"
}

resource "aws_iam_policy_attachment" "new-attach" {
  name       = "new-attachment"
  roles      = ["${aws_iam_role.ec2-s3_access_role.name}"]
  policy_arn = "${aws_iam_policy.policy.arn}"
}

