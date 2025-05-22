#!/bin/bash
set -e

# Update and install necessary packages
apt update -y
apt install -y amazon-cloudwatch-agent docker.io

# Create a user with sudo privileges
useradd -m -s /bin/bash ${username}
usermod -aG sudo ${username}
usermod -aG docker ${username}

# Set up SSH access for the new user
mkdir -p /home/${username}/.ssh
echo "${public_key}" > /home/${username}/.ssh/authorized_keys
chmod 700 /home/${username}/.ssh
chmod 600 /home/${username}/.ssh/authorized_keys
chown -R ${username}:${username} /home/${username}/.ssh

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Configure CloudWatch agent
cat <<EOT > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "metrics": {
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      },
      "cpu": {
        "measurement": ["cpu_usage_idle", "cpu_usage_user", "cpu_usage_system"],
        "metrics_collection_interval": 60
      }
    },
    "append_dimensions": {
      "InstanceId": "$${aws:InstanceId}"
    }
  }
}
EOT

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
