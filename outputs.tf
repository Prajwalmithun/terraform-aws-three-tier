output "my_ip" {
  value = data.http.my_ip.response_body
}