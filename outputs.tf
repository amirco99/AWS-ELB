output "instance_id" {
  value = "${aws_instance.web1.id}"
}

output "public_ip" {
  value = "${aws_instance.web1.public_ip}"
}

output "instance_url" {
  value = "http://${aws_instance.web1.public_ip}:${var.instance_port}"
}

output "elb_dns_name" {
      value = "${aws_elb.app.dns_name}"
}
