
# -----------------------
# Backend AMI
# -----------------------
data "aws_ami" "backend" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["backend"]
  }
}

resource "aws_ami_from_instance" "ami_backend" {
  name               = "backend-ami"
  source_instance_id = var.instanceid
  snapshot_without_reboot = false

  tags = {
    Name = "backend-ami"
  }
}

# -----------------------
# Backend Launch Template
# -----------------------
# resource "aws_launch_template" "backend" {
#   name                   = "${var.project_name}-backend-lt"
#   description            = "Backend launch template"
#   image_id               = aws_ami_from_instance.ami_backend.id
#   instance_type          = var.instance_type
#   vpc_security_group_ids = [var.backend_sg_id]
#   key_name               = var.key_name
#   update_default_version = true

#   tag_specifications {
#     resource_type = "instance"
#     tags = {
#       Name = "${var.project_name}-backend"
#     }
#   }
#   depends_on = [ aws_ami_from_instance.ami_backend ]
# }

resource "aws_launch_template" "backend" {
  name                   = "${var.project_name}-backend-lt"
  description            = "Backend launch template"
  image_id               = aws_ami_from_instance.ami_backend.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.backend_sg_id]
  key_name               = var.key_name
  update_default_version = true

  user_data = base64encode(<<-EOF
#!/bin/bash

DT_API_URL="https://<your-environment-id>.live.dynatrace.com"
DT_API_TOKEN="<your-api-token>"

wget -O Dynatrace-OneAgent.sh "$DT_API_URL/api/v1/deployment/installer/agent/unix/default/latest?Api-Token=$DT_API_TOKEN&arch=x86&flavor=default"

chmod +x Dynatrace-OneAgent.sh

/bin/sh Dynatrace-OneAgent.sh \
  --set-app-log-content-access=true \
  --set-host-group=${var.project_name}-backend

systemctl restart oneagent
EOF
)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-backend"
    }
  }

  depends_on = [aws_ami_from_instance.ami_backend]
}
