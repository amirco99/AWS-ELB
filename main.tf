# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN EC2 INSTANCE THAT RUNS A SIMPLE "HELLO, WORLD" WEB SERVER
# 
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "${var.aws_region}"
}


#----------------------------------------------------------------------------------------------------------------------
# DEPLOY main VPC
# ---------------------------------------------------------------------------------------------------------------------
resource  "aws_vpc" "main"  {
  cidr_block  = "${var.vpc_ip}"
  instance_tenancy = "default"
  tags {
     Name = "Main"
     Lcation = "Tel-Aviv"
  }
}
#----------------------------------------------------------------------------------------------------------------------
# DEPLOY Subnets in  all AZ in the define Regions
# ---------------------------------------------------------------------------------------------------------------------
resource  "aws_subnet" "subnets"  {
  count = "${length(data.aws_availability_zones.avzs.names)}"
  availability_zone =  "${element(data.aws_availability_zones.avzs.names,count.index)}"
  vpc_id  = "${aws_vpc.main.id}"
  cidr_block  = "${element(var.subnet_ip,count.index)}"
 tags {
    Name = "Subnet-${count.index+1}"
    Location = "Mod-${count.index+1}"
  }
}
/*
resource  "aws_subnet" "sub2"  {
 vpc_id  = "${aws_vpc.main.id}"
 availability_zone =  "${element(data.aws_availability_zones.avzs.names,1)}"
 cidr_block  = "${element(var.subnet_ip,1)}"
 tags {
    Name = "Subnet-2"
  }
}
resource  "aws_subnet" "sub3"  {
 vpc_id  = "${aws_vpc.main.id}"
 availability_zone =  "${element(data.aws_availability_zones.avzs.names,2)}"
 cidr_block  = "${element(var.subnet_ip,2)}"
 tags {
    Name = "Subnet-3"
  }
}
*/
#----------------------------------------------------------------------------------------------------------------------
# Define the internet gateway
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "VPC IGW"
  }
}
#----------------------------------------------------------------------------------------------------------------------
# Define A route table - Allow Public Connection
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "pubsub" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "Public Subnet "
  }
}
#----------------------------------------------------------------------------------------------------------------------
# Assign the route table to the public Subnet
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route_table_association" "sub1-rt" {
  subnet_id = "${aws_subnet.subnets.0.id}"
  route_table_id = "${aws_route_table.pubsub.id}"
}
resource "aws_route_table_association" "sub2-rt" {
  subnet_id = "${aws_subnet.subnets.1.id}"
  route_table_id = "${aws_route_table.pubsub.id}"
}

#----------------------------------------------------------------------------------------------------------------------
# DEPLOY Network Interface  in  all AZ in the define Regions
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_network_interface" "net" {
  subnet_id = "${aws_subnet.subnets.0.id}"
 # subnets = ["${aws_subnet.subnets.0.id}","${aws_subnet.subnets.1.id}","${aws_subnet.subnets.2.id}"]
  #private_ips = ["190.169.1.0"]
  tags {
    Name = "primary_network_interface"
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# CREATE LOAD BALANCER 
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_elb" "app" {
  name               =   "app-elb"
 # availability_zones =  ["${data.aws_availability_zones.avzs.names}"]
 #  subnets         =  ["${aws_subnet.subnets.0.id}","${aws_subnet.subnets.1.id}","${aws_subnet.subnets.2.id}"]
  subnets         =  ["${aws_subnet.subnets.*.id}"]
  security_groups =   ["${aws_security_group.elb.id}"]



#  access_logs {
#   bucket        = "foo"
#   bucket_prefix = "bar"
#   interval      = 60
# }

  listener {
    instance_port     = "${var.instance_port}"
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:${var.instance_port}/"
    interval            = 30
  }

  instances                   = ["${aws_instance.web1.id}","${aws_instance.web2.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400


  tags {
    Name = "Http-Elb"
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# CREATE S3 Bucket
# ---------------------------------------------------------------------------------------------------------------------
 resource "aws_s3_bucket" "b" {
  bucket = "amirco99-bucket"
  acl    = "public-read-write"

  tags {
    Name        = "My bucket"
   Environment = "Dev"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Uploading a file to S3
# ---------------------------------------------------------------------------------------------------------------------
#resource "aws_s3_bucket_object" "object" {
 # bucket = "amirco99-bucket"
  #key    = "myindex.html"
  #source = "/Users/acohan/Documents/terraform/exam/user-data/myindex.html"
  #etag   = "${md5(file("${path.module}/user-data/myindex.html"))}"
#}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "web1" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  user_data              = "${data.template_file.user_data.rendered}"
  vpc_security_group_ids =  ["${aws_security_group.instance.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.new_profile.name}"
  availability_zone      =  "${element(data.aws_availability_zones.avzs.names,0)}"
  subnet_id = "${aws_subnet.subnets.0.id}"
  associate_public_ip_address = true

  key_name   = "${var.key_name}"
 
  tags {
    Name = "web1-public"
  }
} 

resource "aws_instance" "web2" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  user_data              = "${data.template_file.user_data.rendered}"
  vpc_security_group_ids =  ["${aws_security_group.instance.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.new_profile.name}"
  availability_zone      =  "${element(data.aws_availability_zones.avzs.names,1)}"
  subnet_id = "${aws_subnet.subnets.1.id}"
  associate_public_ip_address = true

  key_name   = "${var.key_name}"
 
  tags {
    Name = "web2-public"
  }
} 
/*
resource "aws_instance" "web3" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  user_data              = "${data.template_file.user_data.rendered}"
  vpc_security_group_ids =  ["${aws_security_group.instance.id}"]
  availability_zone      =  "${element(data.aws_availability_zones.avzs.names,2)}"
  subnet_id = "${aws_subnet.subnets.2.id}"
  associate_public_ip_address = true

  key_name   = "${var.key_name}"
 
  tags {
    Name = "web3-public"
  }
} 

resource "aws_instance" "web" {
  count = "${length(data.aws_availability_zones.avzs.names)}"
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  user_data              = "${data.template_file.user_data.rendered}"
  vpc_security_group_ids =  ["${aws_security_group.instance.id}"]
  availability_zone      =  "${element(data.aws_availability_zones.avzs.names,count.index)}"
  subnet_id = "${aws_subnet.subnets.0.id}"
  associate_public_ip_address = true
 

   key_name   = "${var.key_name}"
 
  tags {
    Name = "web-${count.index+1}"
  }

#------------------------------

resource "aws_spot_instance_request" "web2" {
 ami           = "${data.aws_ami.ubuntu.id}"
 spot_price    = "0.03"
 instance_type = "t2.micro"
 user_data              = "${data.template_file.user_data.rendered}"
 vpc_security_group_ids =  ["${aws_security_group.instance.id}"]
 key_name   = "${var.key_name}"

 tags {
    Name = "Web2-CheapWorker"
# }
}
*/
# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE USER DATA SCRIPT THAT WILL RUN DURING BOOT ON THE EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data/user-data.sh")}"

  vars {
    instance_text = "${var.instance_text}"
    instance_port = "${var.instance_port}"
  }
}

/*
# ---------------------------------------------------------------------------------------------------------------------
# CREATE  a launch conguration
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_launch_configuration" "basis" {
   image_id = "${data.aws_ami.ubuntu.id}"
   instance_type = "t2.micro"
   security_groups = ["${aws_security_group.instance.id}"]
   user_data              = "${data.template_file.user_data.rendered}"

lifecycle { 
create_before_destroy = true
  } 
}
resource "aws_autoscaling_group" "From-3-6" {
      launch_configuration = "${aws_launch_configuration.basis.id}"
      availability_zones = ["${data.aws_availability_zones.avzs.names}"]
    # vpc_zone_identifier = ["${aws_subnet.subnets.0.id}","${aws_subnet.subnets.1.id}","${aws_subnet.subnets.2.id}"]
      load_balancers = ["${aws_elb.app.name}"]
      health_check_type = "ELB"

      min_size = 3
      max_size = 6
tag {
  key = "Name"
  value = "autoscaling-from-3-to-4" 
  propagate_at_launch = true
  } 
}
*/

