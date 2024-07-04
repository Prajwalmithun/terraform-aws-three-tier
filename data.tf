# Data sources are used to query external information that your configuration depends on. Keeping them in a separate file improves readability and organization.

data "http" "my_ip" {
    url = "http://ipv4.icanhazip.com"
}