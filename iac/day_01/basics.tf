/*
  Creates a local file with static content.
  This demonstrates basic Terraform resource declaration.
*/
resource "local_file" "products" {
    content  = "Lista de products"
    filename  = "products.txt"
}
