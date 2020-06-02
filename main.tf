provider "aws" {
  region = "eu-north-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "example" {
  for_each = data.aws_subnet_ids.all.ids

  id = each.value
}

output "subnets" {
  value = {
    for subnet in data.aws_subnet.example:
    subnet.id => {
      AZ = subnet.availability_zone
      Name = subnet.tags.Name
    }
  }
}



resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  provisioner "local-exec" {
    command = "scripts/attach-volumes.sh ${self.id}"
  }

  tags = {
    Name = "trans.eu"
  }
}
#
# data.get.all.ec2.instances.with.tags
#   depeneds_on aws_instance
#
#
# null_resource.runscript.attached-if-exists--create-if-not
#
# resource "aws_volume_attachment" "this_ec2" {
#   count = data.get.all.ec2.instances.with.tags
#
#   device_name  = "/dev/xvdg"
#   volume_id    = aws_ebs_volume.this[count.index].id
#   instance_id  = data.get.all.ec2.instances.with.tags
#   skip_destroy = true
#   force_detach = true
# }
#
# resource "aws_ebs_volume" "this" {
#   count = var.instances_number * var.volumes_number
#
#   availability_zone = module.ec2.availability_zone[count.index]
#   size              = 1
#   tags              = {
#     Name = "trans.eu"
#   }
# }
