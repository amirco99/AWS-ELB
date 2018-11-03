# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL WHAT REQUESTS CAN GO IN AND OUT OF THE EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "instance" {
  name = "${var.instance_name}"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port = "${var.instance_port}"
    to_port   = "${var.instance_port}"
    protocol  = "tcp"
    # to keep this example simple, we allow incoming http requests from any ip. in real-world usage, you may want to
    # lock this down to just the ips of trusted servers (e.g., of a load balancer).
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ssh access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO EXPLICITLY ALLOWS INCOMING REQUESTS ON PORT 80 TO ELB
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "elb" {
   name = "terraform-example-elb"
   vpc_id      = "${aws_vpc.main.id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp" cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1" cidr_blocks = ["0.0.0.0/0"]
   }
}
