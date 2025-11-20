 # Day 01 – Jenkins Setup on AWS EC2 🚀
# This guide walks through setting up Jenkins on an EC2 instance, installing required dependencies, and configuring a Jenkins pipeline to run Terraform code.
# 🖥️ EC2 Instance Setup
- Instance Name: Jenkins
- Instance Type: t2.medium
- OS: Amazon Linux 2
  
# 🔧 Installation Steps
1. Connect to EC2 and Switch to Root
ssh -i <your-key>.pem ec2-user@<public-ip>
sudo su -

# 2. Create Installation Script
Create a shell script install.sh to install all dependencies:
vim install.sh

Paste the following content:

or you can install it one by one

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
 http://public-ip:8080
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


# DAY02 JENKINS
-------------------------
Connect to Jenkins on EC2
install the dependencies 

# Retrieve the initial Jenkins admin password:
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
# Open Jenkins in browser:
http://public-ip:8080
# 📦 2. Install Required Plugins
Navigate to:
Jenkins → Manage Jenkins → Plugins → Available Plugins
Install the following plugins:

-Pipeline Stage View
-Blue Ocean
-Generic Webhook Trigger
-GitHub Integration

# 🛠️ 3. Create a New Pipeline Job
Optional: Add Build Parameters
Useful for choosing apply or destroy during Terraform operations.
 This project is parameterized
→ Add Parameter → Choice Parameter
Name: action
Choices:
apply
destroy
# Declarative Pipeline Example
    pipeline {
    agent any

    stages {

        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/Ranjit-08/Terraform-Repo.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('day-1-basic-code') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('day-1-basic-code') {
                    sh 'terraform plan'
                }
            }
        }

        stage('Terraform Apply/Destroy') {
            steps {
                dir('day-1-basic-code') {
                    sh "terraform ${params.action} -auto-approve"
                }
            }
        }

    }
    }

# 📜 5. Scripted Pipeline Example
    node {

    stage('Clone Repo') {
        git branch: 'main', url: 'https://github.com/Ranjit-08/jenkins.git'
    }

    stage('Terraform Init') {
        sh 'terraform init'
    }

    stage('Terraform Plan') {
        sh 'terraform plan'
    }

    stage('Terraform Apply') {
        sh "terraform ${params.button} -auto-approve"
    }

    }

 # ⏱️ 6. Jenkins Trigger Types
 ##  1. Build After Other Projects Are Built
Used for chaining pipelines.
Steps:
Pipeline2 → Configure → Build Triggers → Build after other projects are built
Project: Pipeline1
Pipeline2 will run automatically after Pipeline1 completes.

# 2. Build Periodically (CRON)
\* \* \* \* \*
Meaning → Run the pipeline every 1 minute
Trigger continues until manually disabled.

# 3. GitHub Hook Trigger for GITScm Polling
Automatically runs when changes are pushed to GitHub.
# Jenkins:steps
Build Triggers → GitHub hook trigger for GITScm polling
# GitHub Repository:
Settings → Webhooks → Add Webhook
Payload URL: http://<public-ip>:8080/github-webhook/
Content type: application/json
After saving — committing code will automatically trigger Jenkins.
# 4. Poll SCM Trigger

Combination of webhook + schedule.

Example:
   \* \* \* \* \*
Behaviour:

Jenkins does not run immediately after a GitHub commit

It checks for changes according to the schedule (every minute)

# Summary
✔ Connecting Jenkins on EC2
✔ Installing essential plugins
✔ Creating Declarative & Scripted pipelines
✔ Adding Apply/Destroy parameters
✔ Implementing Jenkins triggers:
 • Upstream build trigger
 • Cron-based trigger
 • GitHub webhook
 • Poll SCM trigger

