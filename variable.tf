variable "region"{
    type = list
    default = ["us-east-2","us-west-2","ap-south-1"]
}
variable "ami"{
    default = "ami-0d718c3d715cec4a7"
    type = string
}

variable "Itypes"{
    type = map
    default = {
        us-east-2 = "t2.micro"
        us-west-2 = "t2.nano"
        ap-south-1 = "t2.small"
    }
}