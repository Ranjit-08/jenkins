Day 01 – Jenkins Setup on AWS EC2 🚀
This guide walks through setting up Jenkins on an EC2 instance, installing required dependencies, and configuring a Jenkins pipeline to run Terraform code.
🖥️ EC2 Instance Setup
- Instance Name: Jenkins
- Instance Type: t2.medium
- OS: Amazon Linux 2
  
🔧 Installation Steps
1. Connect to EC2 and Switch to Root
ssh -i <your-key>.pem ec2-user@<public-ip>
sudo su -

2. Create Installation Script
Create a shell script install.sh to install all dependencies:
vim install.sh

Paste the following content:


#!/bin/bash
sudo yum update -y

# Git
sudo yum install git -y

# Java (required for Jenkins)
sudo yum install java-17-amazon-corretto.x86_64 -y

# Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

# 3. Make Script Executable and Run
chmod 755 install.sh
sh install.sh

# - Open your browser and navigate to:
http://<public-ip>:8080
- Copy the initial admin password from the path shown on the Jenkins page:
cat /var/lib/jenkins/secrets/initialAdminPassword
- Complete the setup wizard and install recommended plugins.

#  🔐 IAM Role for Terraform
Attach an IAM role to the EC2 instance with permissions to manage AWS resources. This is required for Terraform to function properly within Jenkins.

# 🔌 Install Required Jenkins Plugins
- Go to: Manage Jenkins → Plugins
- Install: Pipeline, Pipeline: Stage View
- Return to Jenkins home page

# Configure Jenkins Pipeline
Create a new pipeline job and use the following script:


  pipeline {
  
      stages {
      
          stage('Clone Repo') {
            steps {
                git url: 'https://github.com/Ranjit-08/Terraform-Repo.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('day-1-basic-code') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                dir('day-1-basic-code') {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }
}

# Jenkins Workspace Path
Terraform code will execute from:
cd /var/lib/jenkins/workspace/<pipeline-name>

- Click Build Now to trigger the pipeline.
- Monitor console output for execution logs.


