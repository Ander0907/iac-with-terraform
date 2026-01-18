/*
  Creates multiple local files with unique names.
  Uses count and interpolation to generate files with random suffixes.
*/
resource "local_file" "products" {
	count = 5
	content  = "List of products"
  	filename  = "products-${random_string.suffix[count.index].id}.txt"
}
