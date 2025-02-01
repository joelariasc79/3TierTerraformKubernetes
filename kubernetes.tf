provider "aws" {
  region = "us-west-1"
}


resource "aws_instance" "worker_node_1" {
  ami           = "ami-07d2649d67dbe8900"
  instance_type = "t2.medium"

  tags = {
    Name = "kubernetes-worker-node-1"
  }
}

resource "aws_instance" "worker_node_2" {
  ami           = "ami-07d2649d67dbe8900"
  instance_type = "t2.medium"

  tags = {
    Name = "kubernetes-worker-node-2"
  }
}

resource "aws_instance" "kubernetes_master" {
  ami           = "ami-07d2649d67dbe8900"
  instance_type = "t2.medium"

  tags = {
    Name = "kubernetes-master-node"
  }
}

resource "aws_eip" "eip_worker_1" {
  instance = aws_instance.worker_node_1.id
  vpc      = false # Set to true if you're in a VPC
  tags = {
    Name = "worker-node-1-eip"
  }
}

resource "aws_eip" "eip_worker_2" {
  instance = aws_instance.worker_node_2.id
  vpc      = false # Set to true if you're in a VPC
  tags = {
    Name = "worker-node-2-eip"
  }
}

resource "aws_eip" "eip_master" {
  instance = aws_instance.kubernetes_master.id
  vpc      = false # Set to true if you're in a VPC
  tags = {
    Name = "master-node-eip"
  }
}

output "kubernetes_worker_node_1_public_ip" {
  value = aws_instance.worker_node_1.public_ip
}

output "kubernetes_worker_node_2_public_ip" {
  value = aws_instance.worker_node_2.public_ip
}

output "kubernetes_master_public_ip" {
  value = aws_instance.kubernetes_master.public_ip
}