/*
  Generates random strings to create unique suffixes.
  Creates 5 instances with 4 lowercase letters each.
*/
resource "random_string" "suffix" {
    count = 5
	length  = 4
	upper = false
	special = false
	numeric = false
}
