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
  count             = 1
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
    Disk = count.index+1
  }

  depends_on = [
    null_resource.web_cluster
  ]
}

data "null_data_source" "values" {
  count = var.volumes_number

  inputs = {
    all_server_ids = "${concat(aws_instance.green.*.id, aws_instance.blue.*.id)}"
    all_server_ips = "${concat(aws_instance.green.*.private_ip, aws_instance.blue.*.private_ip)}"
  }

  depends_on = [
    null_resource.web_cluster
  ]
}

resource "null_resource" "web_cluster" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = "${join(",", aws_instance.web.*.id)}"
  }

  provisioner "local-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    command = "gather-volumes-information.sh"
  }
}
