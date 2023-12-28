# -----------------------------------------------------
# Keypair Creation
#-------------------------------------------------------

resource "aws_key_pair" "auth_key" {

  key_name   = "${var.project_name}-${var.project_env}"
  public_key = file("mykey.pub")
  tags = {
    Name    = "${var.project_name}-${var.project_env}"
    project = var.project_name
    env     = var.project_env
  }
}


# -----------------------------------------------------
# Webserver SecurityGroup
# -----------------------------------------------------

resource "aws_security_group" "http_access" {

  name        = "${var.project_name}-${var.project_env}-http-access"
  description = "${var.project_name}-${var.project_env}-http-access"


  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "${var.project_name}-${var.project_env}-http-access"
    project = var.project_name
    env     = var.project_env
  }
}



# -----------------------------------------------------
# Creating Ec2 Instance
# -----------------------------------------------------

resource "aws_instance" "frontend" {

  ami           = data.aws_ami.latest.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.auth_key.key_name
  #  user_data              = file("setup.sh")
  vpc_security_group_ids = [aws_security_group.http_access.id]
  tags = {
    Name    = "${var.project_name}-${var.project_env}-frontend"
    project = var.project_name
    env     = var.project_env
  }

  lifecycle {
    create_before_destroy = true
  }
}




resource "aws_route53_record" "frontend-dev" {
  count   = var.project_env == "dev" ? 1 : 0
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "${var.hostname}.${var.hosted_zone_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.frontend.public_ip]
}

resource "aws_route53_record" "frontend-prod" {

  count = var.project_env == "prod" ? 1 : 0

  zone_id = data.aws_route53_zone.public.zone_id
  name    = "${var.hostname}.${var.hosted_zone_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.frontend.public_ip]
}
