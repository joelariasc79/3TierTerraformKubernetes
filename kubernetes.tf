variable "public_key" {
  description = "The public key to use for SSH access"
  type        = string
}

provider "aws" {
  region = "us-west-1"
}

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

resource "aws_key_pair" "my_key" {
  key_name   = "my-unique-key-pair"  # Change the key pair name to a unique name
  public_key = var.public_key
}

resource "aws_instance" "worker_backend_worker_node" {
  ami           = "ami-07d2649d67dbe8900"
  instance_type = "t2.medium"
  key_name      = aws_key_pair.my_key.key_name

  tags = {
    Name = "kubernetes-backend-worker-node"
  }

  vpc_security_group_ids = [aws_security_group.kubernetes_backend_worker_node_sg.id]
}

resource "aws_security_group" "kubernetes_backend_worker_node_sg" {
  name        = "kubernetes-backend-worker-sg"
  description = "Security group for kubernetes backend worker instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "worker_frontend_worker_node" {
  ami           = "ami-07d2649d67dbe8900"
  instance_type = "t2.medium"
  key_name      = aws_key_pair.my_key.key_name

  tags = {
    Name = "kubernetes-frontend-worker-node"
  }

  vpc_security_group_ids = [aws_security_group.kubernetes_frontend_worker_node_sg.id]
}

resource "aws_security_group" "kubernetes_frontend_worker_node_sg" {
  name        = "kubernetes-frontend-worker-sg"
  description = "Security group for kubernetes frontend worker instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4200
    to_port     = 4200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "kubernetes_master" {
  ami           = "ami-07d2649d67dbe8900"
  instance_type = "t2.medium"
  key_name      = aws_key_pair.my_key.key_name

  tags = {
    Name = "kubernetes-master-node"
  }
}

resource "aws_security_group" "kubernetes_master_node_sg" {
  name        = "kubernetes-master-sg"
  description = "Security group for kubernetes master instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4200
    to_port     = 4200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Elastic IP
resource "aws_eip" "eip_backend_worker_node" {
  instance = aws_instance.worker_backend_worker_node.id
  tags = {
    Name = "backend-worker-node-eip"
  }
}

# Elastic IP
resource "aws_eip" "eip_frontend_worker_node" {
  instance = aws_instance.worker_frontend_worker_node.id
  tags = {
    Name = "frontend-worker-node-eip"
  }
}

# Elastic IP
resource "aws_eip" "eip_master" {
  instance = aws_instance.kubernetes_master.id
  tags = {
    Name = "master-node-eip"
  }
}

output "kubernetes_backend_worker_node_public_ip" {
  value = aws_instance.worker_backend_worker_node.public_ip
}

output "kubernetes_frontend_worker_node_public_ip" {
  value = aws_instance.worker_frontend_worker_node.public_ip
}

output "kubernetes_master_public_ip" {
  value = aws_instance.kubernetes_master.public_ip
}

output "kubernetes_backend_worker_node_private_ip" {
  value = aws_instance.worker_backend_worker_node.private_ip
}

output "kubernetes_frontend_worker_node_private_ip" {
  value = aws_instance.worker_frontend_worker_node.private_ip
}

output "kubernetes_master_node_private_ip" {
  value = aws_instance.kubernetes_master.private_ip
}


