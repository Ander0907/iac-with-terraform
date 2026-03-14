echo "This is a message from userdata script" > /var/www/html/index.html
yum update -y
yum install httpd -y
systemctl enable httpd
systemctl start httpd