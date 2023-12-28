#-----------------------------------
#data source for  hosted zone
#-----------------------------------
data "aws_route53_zone" "public" {
  name         = var.hosted_zone_name
  private_zone = false
}


#-----------------------------------
#data source for  custom AMI - linux in ap-south-1
#-----------------------------------
data "aws_ami" "latest" {

  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${var.project_name}-${var.project_env}-*"]
  }

  filter {
    name   = "tag:project"
    values = ["${var.project_name}"]
  }

  filter {
    name   = "tag:env"
    values = ["${var.project_env}"]
  }

}
