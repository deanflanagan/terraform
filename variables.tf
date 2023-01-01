variable "AWS_ACCESS_KEY" {}

variable "AWS_SECRET_KEY" {}

variable "AWS_REGION" {
default = "us-east-1"
}

variable "AMIS" {
    type = map
    default = {
        us-east-1 = "ami-0574da719dca65348"
    }
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "kafka_cluster_key"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "kafka_cluster_key.pub"
}

variable "INSTANCE_USERNAME" {
  default = "ubuntu"
}