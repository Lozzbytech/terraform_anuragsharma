#aws ecr repository for docker image local build and push to ecr
resource "aws_ecr_repository" "backend" {
    name = "ares-backend"
    image_tag_mutability = "MUTABLE"
    tags = {
        Name = "ares-backend-repo"
    }
    }

resource "aws_ecr_repository" "frontend" {
    name = "ares-frontend"
    image_tag_mutability = "MUTABLE"
    tags = {
        Name = "ares-frontend-repo"
    }
    }

#automated local build and push to ecr using null resource and local-exec provisioner
resource "null_resource" "build_and_push" {
    depends_on = [aws_ecr_repository.backend, aws_ecr_repository.frontend]

    triggers = {
        always_run = timestamp()
    }
    provisioner "local-exec" {
        command = <<-EOT
        #login to ecr
        aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.backend.repository_url}
        aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.frontend.repository_url}
        #build and push backend image
        cd ~/ares/terraform_anuragsharma/backend
        docker build -t ${aws_ecr_repository.backend.repository_url}:latest .
        docker push ${aws_ecr_repository.backend.repository_url}:latest
        #build and push frontend image
        cd ~/ares/terraform_anuragsharma/frontend
        docker build -t ${aws_ecr_repository.frontend.repository_url}:latest .
        docker push ${aws_ecr_repository.frontend.repository_url}:latest
        EOT
    }
}       