#!/bin/bash
    sudo apt update -y 
    sudo wget http://nginx.org/keys/nginx_signing.key
    sudo apt-key add nginx_signing.key
    echo "deb [arch=amd64] http://nginx.org/packages/mainline/ubuntu/ focal nginx" > /etc/apt/sources.list.d/nginx.list
    sudo apt update -y 
    sudo apt install nginx -y 
    sudo systemctl start nginx
    sudo systemctl enable nginx
    sudo echo '''
    server {
      listen 80;
      listen [::]:80;
      #you proxy server ip
      server_name example.com;

      location / {
          #your web server ip
          proxy_pass http://localhost:3000/;
      }
    }
    ''' > /etc/nginx/conf.d/proxy.conf
    sudo mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.org