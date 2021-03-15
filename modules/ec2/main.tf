resource "random_shuffle" "subnets" {
  input = var.subnets
  result_count = 1
}

resource "aws_instance" "cloudcasts_web" {
  ami           = var.instance_ami
  instance_type = var.instance_size

  root_block_device {
    volume_size = var.instance_root_device_size
    volume_type = "gp3"
  }

  subnet_id = random_shuffle.subnets.result[0]
  vpc_security_group_ids = var.security_groups

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "cloudcasts-${var.infra_env}-web"
    Role        = var.infra_role
    Project     = "cloudcasts.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

resource "aws_eip" "cloudcasts_addr" {
  # We're not doing this directly
  # instance = aws_instance.cloudcasts_web.id
  vpc      = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "cloudcasts-${var.infra_env}-web-address"
    Role        = var.infra_role
    Project     = "cloudcasts.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.cloudcasts_web.id
  allocation_id = aws_eip.cloudcasts_addr.id
}