provider "aws" {
  region = "eu-west-2"
}

resource "aws_key_pair" "my_key" {
  key_name   = "my-ec2-key"
  public_key = file("C:/Users/Kajal/.ssh/id_rsa.pub")
}

resource "aws_security_group" "sg" {
  name_prefix = "http-service-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "flask_instance" {
  ami           = "ami-019374baf467d6601"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y python3-pip python3-dev
              pip3 install flask boto3
              cd /home/ubuntu
              echo 'from flask import Flask, jsonify, abort' > app.py
              echo 'import boto3' >> app.py
              echo 'app = Flask(__name__)' >> app.py
              echo "s3 = boto3.client('s3')" >> app.py
              echo "BUCKET_NAME = 'http-bucket-task'" >> app.py
              echo "if __name__ == '__main__':" >> app.py
              echo "    app.run(debug=True, host='0.0.0.0', port=8000)" >> app.py
              python3 app.py &
              EOF
}

output "ec2_public_ip" {
  value = aws_instance.flask_instance.public_ip
}
 
