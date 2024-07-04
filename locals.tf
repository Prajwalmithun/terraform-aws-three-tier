# Local values are useful for defining constants or reusable expressions that simplify the configuration

locals {
    my_ip = chomp(data.http.my_ip.response_body)
}
