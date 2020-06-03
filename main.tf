provider "aws" {
  region = local.region
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
  count             = 1
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "t3.micro"
  availability_zone = data.aws_availability_zones.all.names[0]

  provisioner "local-exec" {
    #                         pass     : instanceID; AZ                                         current instacne; number of volumes
    command = "scripts/attach-volumes.sh ${self.id} ${data.aws_availability_zones.all.names[0]} ${count.index} ${var.volumes_number}}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "scripts/detach-volumes.sh ${local.region} ${self.id}"
  }

  tags = {
    Name = "trans.eu"
  }

  volume_tags = {
    Name = "trans.eu"
  }
}
