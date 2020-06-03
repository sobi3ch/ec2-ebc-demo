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

data "aws_availability_zones" "all" {
  state = "available"
}

resource "aws_instance" "web" {
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "t3.micro"
  availability_zone = data.aws_availability_zones.all.names[0]

  provisioner "local-exec" {
    command = "scripts/attach-volumes.sh ${self.id}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "scripts/detach-volumes.sh ${self.id}"
  }

  tags = {
    Name = "trans.eu"
  }

  volume_tags = {
    Name = "trans.eu"
  }

  depends_on = [
    aws_ebs_volume.web
  ]
}

resource "aws_ebs_volume" "web" {
  # count = var.instances_number * var.volumes_number
  count = var.volumes_number

  availability_zone = data.aws_availability_zones.all.names[0]
  size              = 1

  tags              = {
    Name = "trans.eu"
  }
}
