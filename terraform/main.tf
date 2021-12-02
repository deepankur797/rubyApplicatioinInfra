data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_security_group" "sg" {
  name        = "sg"
  description = "SSH"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "app-instance-1" {
  ami = data.aws_ami.ubuntu.id
  #count                  = var.number
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = "atVenu-dsb"
  user_data              = file("manual.sh")
  tags = {
    owner = "deepankur"
    Name  = "app-instance-1"
  }
}

resource "aws_instance" "app-instance-2" {
  ami = data.aws_ami.ubuntu.id
  #count                  = var.number
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = "atVenu-dsb"
  user_data              = file("manual.sh")
  tags = {
    owner = "deepankur"
    Name  = "app-instance-2"
  }
}

data "template_file" "haproxyconf" {
  template = file("haproxy.cfg.tpl")
  vars = {
    web1_priv_ip = "${aws_instance.app-instance-1.public_ip}"
    web2_priv_ip = "${aws_instance.app-instance-2.public_ip}"
  }
}
resource "aws_instance" "haproxy" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = "atVenu-dsb"
  provisioner "remote-exec" {
    inline = [
      "sleep 5",
      "sudo apt-get update",
      "sudo apt-get -y install haproxy",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file("~/Documents/AWS/venu/atVenu-dsb.pem")
    }
  }
  provisioner "file" {
    content      = data.template_file.haproxyconf.rendered
    destination = "/home/ubuntu/haproxy.cfg"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file("~/Documents/AWS/venu/atVenu-dsb.pem")
    }
  }
  provisioner "remote-exec" {
    inline = [
	"sudo mv /home/ubuntu/haproxy.cfg /etc/haproxy/haproxy.cfg",
      "sudo service haproxy restart",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file("~/Documents/AWS/venu/atVenu-dsb.pem")
    }
  }

  tags = {
    owner = "deepankur"
    Name  = "haproxy"
  }
}


