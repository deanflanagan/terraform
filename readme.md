# Terraform Kakfa Cluster 

This document outlines how to provision a small Kafka cluster of three brokers/nodes and three Zookeeper instances.

**Table of Contents**

1. [Introduction](#introduction)
2. [Setup](#logic)
3. [Next steps](#next-steps)

## Introduction <a name="introduction"></a>

Terraform is an open source infrastucture configuration language, allowing one to implement Infrastructure As Code - IAC. You can spin up instances, security groups, persistent storage volumes... anything server based on any cloud platform. 

## Setup <a name="logic"></a>

To follow along, you will want to install Terraform and Git on your machine (instructions here: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli). 

Next, clone this repo:

`git clone https://github.com/deanflanagan/terraform`

In the directory, there are 3 `.tf` files:

`providers.tf` I use to store the login credentials for our admin user who will programatically do the work. Now for security reasons I will not upload these credentials to GitHub. Terraform will prompt their values upon using Terraform commands. 

`variables.tf` defines variables we will re-use in our code. Notice I uploaded my access key but not my secret access key... you will be prompted for it when you run terraform commands, but you can also enter it in for convenience when you work locally. 

`instances.tf` is the logic for creating the instances (1 zookeeper & 3 kafka), a security group for them to communicate and a script to install the software on the machine. 

Lets begin. 

```
ssh-keygen -f kafka_cluster_key # just press return here at prompt, no need for password in demo
terraform init
terraform plan
```

If it all worked out, you will see 9 resources to add. Let's do it:

`terraform apply`

Zookeeper must be started first, and so the last (manual) step is to start each kafka broker. This can be done by ssh into each instance (use the kafka_cluster_key without the `.pem` extension) and running `kafka_2.13-3.0.0/bin/kafka-server-start.sh kafka_2.13-3.0.0/config/server.properties`. You now have a 3 broker cluster set up.

## Next steps<a name="next-steps"></a>

This demo does the grunt work for installing the cluster but the manual `ubuntuKafka.sh` script should be replaced by an Ansible playbook. This allows for abstraction of configuration and role management.

Secondly, in production/enterprise environments, Terraform provisioning will be abstracted further out into modules. This allows resources to be grouped together and attached as needed. This also follows good coding practice (DRY principle).
