# Provider AWS
provider "aws" {
  region = "us-east-2"
}

# Variáveis gerais
locals {
  project_name = "5asor-wordpress-k3s"
  vpc_cidr     = "192.168.5.0/24"
  subnet_cidr  = "192.168.5.0/28"
  key_name     = "${local.project_name}-key"
}

# Criação da VPC
resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.project_name}-vpc"
  }
}

# Criação da Subnet Pública
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"

  tags = {
    Name = "${local.project_name}-public-subnet"
  }
}

# Criação do Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.project_name}-igw"
  }
}

# Criação da Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.project_name}-public-rt"
  }
}

# Associação da Route Table com a Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Criação do Security Group
resource "aws_security_group" "main" {
  name        = "${local.project_name}-sg"
  description = "Security group para EC2 com K3s e WordPress"
  vpc_id      = aws_vpc.main.id

  # SSH - acesso a partir de qualquer lugar (não recomendado para produção)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  # HTTP - para acessar o WordPress
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  # HTTPS - para acessar o WordPress com SSL
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  # Porta do Kubernetes API
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kubernetes API"
  }

  # Permitir todo tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Permite todo trafego de saida"
  }

  tags = {
    Name = "${local.project_name}-sg"
  }
}

# Gerar par de chaves SSH
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Registrar chave pública na AWS
resource "aws_key_pair" "main" {
  key_name   = local.key_name
  public_key = tls_private_key.key.public_key_openssh
}

# Salvar chave privada localmente
resource "local_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "../live/${local.key_name}.pem"
  file_permission = "0600"
}

# Obter AMI mais recente do Ubuntu 22.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical/Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Criar instância EC2
resource "aws_instance" "k3s" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3a.xlarge"
  key_name               = aws_key_pair.main.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.main.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "${local.project_name}-instance"
  }
}

# Outputs
output "instance_public_ip" {
  description = "IP público da instância EC2"
  value       = aws_instance.k3s.public_ip
}

output "ssh_command" {
  description = "Comando para acessar a instância via SSH(Exemplo)"
  value       = "ssh -i '../live/${local.key_name}.pem' ubuntu@${aws_instance.k3s.public_ip}"
}
