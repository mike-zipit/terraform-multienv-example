# Example usage:
# ami_id = "${data.aws_ami.rancheros.id}"

# (Since you've entered your region in the aws provider, this will find the latest release for this AMI in that region)

data "aws_ami" "rancheros" {
  owners      = [
    "679593333241"]
  filter {
    name   = "name"
    values = [
      "rancheros*-hvm-*"]
  }
  most_recent = true
}

