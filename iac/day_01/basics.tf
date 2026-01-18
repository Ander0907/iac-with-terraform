/*
    Creacion de un archivo local con Terraform
*/
resource "local_file" "productos" {
  content  = "Lista de productos"
  filename  = "productos.txt"
}
