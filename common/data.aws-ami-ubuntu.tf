# Example usage:
# ami_id = "${data.aws_ami.ubuntu.id}"

# (Since you've entered your region in the aws provider, this will find the latest release for this AMI in that region)

data "aws_ami" "ubuntu" {
  owners      = [
    "099720109477"]
  filter {
    name   = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = [
      "hvm"]
  }
  most_recent = true
}