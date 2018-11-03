resource "aws_iam_role" "ec2-s3" {
  name               = "new-role"
  assume_role_policy = "${file("assume-role-policy.json")}"
}

resource "aws_iam_policy" "policy" {
  name        = "new-policy"
  description = "A new policy"
  policy      = "${file("policy-s3-bucket.json")}"
}

resource "aws_iam_policy_attachment" "new-attach" {
  name       = "new-attachment"
  roles      = ["${aws_iam_role.ec2-s3.name}"]
  policy_arn = "${aws_iam_policy.policy.arn}"
}

resource "aws_iam_instance_profile" "new_profile" {
  name  = "test_profile"
  role = "${aws_iam_role.ec2-s3.name}"
}
