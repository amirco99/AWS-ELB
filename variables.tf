# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "aws_region" {
  description = "The AWS region to deploy into"
  default     = "eu-west-2"
}

variable "key_name" {
	description = "The AWS Key pair name"
	default = "MyEc2Key"
}

variable  "number_of_instances" {
	description = "Number of instances to create and attach to ELB"
    default     = 2
}
variable "instance_name" {
	description = "The Name tag to set for the EC2 Instance."
	default     = "Test-web"
}

variable "instance_port" {
	description = "The port the EC2 Instance should listen on for HTTP requests."
	default     = 8080
}

variable "instance_text" {
	description = "The text the EC2 Instance should return when it gets an HTTP request."
	default     = "Hi This is  EC2 test Machine"
}
#variable  "avail-zones" {
#	type = "list"
#	default = ["eu-west-2a","eu-west-2b","eu-west-2c"]
#}
variable "vpc_ip"  {
	default = "10.0.0.0/16"
}
variable "subnet_ip"  {
    type = "list"
    default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
}

# ---------------------------------------------------------------------------------------------------------------------
#  REQUIRED DATA
# ---------------------------------------------------------------------------------------------------------------------

data "aws_availability_zones"  "avzs" {}

# ---------------------------------------------------------------------------------------------------------------------
# LOOK UP THE LATEST UBUNTU AMI
# ---------------------------------------------------------------------------------------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
}

