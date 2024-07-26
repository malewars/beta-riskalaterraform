provider "http" {
  # Configure the HTTP provider (e.g., timeouts, headers, etc.)
}

# Read client credentials from the file
locals {
  credentials = jsondecode(file("${path.module}/credentials.json"))
  client = join("+",[local.credentials.client_id,local.credentials.client_secret])
}

# Obtain the access token
data "http" "get_access_token" {
#  insecure = "true"
  url = local.credentials.token_url
  request_headers = {
    "Authorization" = "Basic ${base64encode(local.client)}"
  }
}


# Get user details from randomuser.me
data "http" "get_user_details" {
  url = "https://randomuser.me/api/"
}

# Use the access token to call your API
resource "null_resource" "api_call" {
  triggers = {
    access_token = data.http.get_access_token.response_body
  }


  provisioner "local-exec" {
    command = <<-EOT
      curl -X POST https://httpbin.org/anything/ \
        -H "Authorization: Bearer ${data.http.get_access_token}" \
        -H "Content-Type: application/json" \
        -d '${data.http.get_user_details.response_body}'
    EOT
  }
}

output "tokenvalue" {
 value = data.http.get_access_token.response_body
}
