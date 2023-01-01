
resource "aws_key_pair" "kafka_cluster_key" {
    key_name = "kafka_cluster_key"
    public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "aws_security_group" "kf_sg" {
  name = "kf_sg"
  description = "Allow HTTP and SSH traffic via Terraform plus zookeeper and "

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9092
    to_port     = 9092
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

resource "aws_security_group" "zk_sg" {
  name = "zk_sg"
  description = "Allow HTTP and SSH traffic via Terraform plus zookeeper and "

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 2181
    to_port     = 3888
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

resource "aws_instance" "zookeeper" {
  ami           = lookup(var.AMIS, var.AWS_REGION)
  instance_type = "t2.large"
  key_name      = aws_key_pair.kafka_cluster_key.key_name
  vpc_security_group_ids =["${aws_security_group.zk_sg.id}"]
  count = 3
  tags = {
    Name = "zookeeper-${count.index}"
  }
  subnet_id = "subnet-15f2b634"
  private_ip = "172.31.80.1${count.index}"#,"172.31.80.1","172.31.80.2"] # 172.31.80.0/20

  connection {
    type = "ssh"
    host = coalesce(self.public_ip, self.private_ip)
    user = "ubuntu"
    private_key = file(var.PATH_TO_PRIVATE_KEY)
    }
  
  provisioner "file" {
      source = "ubuntuKafka.sh"
      destination = "/tmp/ubuntuKafka.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/ubuntuKafka.sh",
      "sudo hostnamectl set-hostname zookeeper-${count.index}",
      "sudo /tmp/ubuntuKafka.sh ${count.index}",
      "kafka_2.13-3.0.0/bin/zookeeper-server-start.sh kafka_2.13-3.0.0/config/zookeeper.properties"
    ]
  }
    depends_on = [aws_instance.kafka]
}

resource "aws_instance" "kafka" {
  ami           = lookup(var.AMIS, var.AWS_REGION)
  instance_type = "t2.large"
  count = 3
  subnet_id = "subnet-15f2b634"
  key_name      = aws_key_pair.kafka_cluster_key.key_name
  vpc_security_group_ids =["${aws_security_group.kf_sg.id}"]
  tags = {
    Name = "kafka-${count.index}"
  }
  connection {
    type = "ssh"
    host = coalesce(self.public_ip, self.private_ip)
    user = "ubuntu"
    private_key = file(var.PATH_TO_PRIVATE_KEY)
    }
  
  provisioner "file" {
      source = "ubuntuKafka.sh"
      destination = "/tmp/ubuntuKafka.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/ubuntuKafka.sh",
      "sudo hostnamectl set-hostname kafka-${count.index}",
      "sudo /tmp/ubuntuKafka.sh ${count.index}",
      # "kafka_2.13-3.0.0/bin/kafka-server-start.sh kafka_2.13-3.0.0/config/server.properties"
    ]
  }

}