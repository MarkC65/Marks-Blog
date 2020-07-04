echo "s/an_unknown_server/"$(curl http://169.254.169.254/latest/meta-data/public-hostname)"/g" >./edit.txt
chmod +x ./edit.txt
sed -f ./edit.txt /var/www/app/views/pages/about.html.erb >/var/www/app/views/pages/about.txt
rm -rf /var/www/app/views/pages/about.html.erb
cp /var/www/app/views/pages/about.txt /var/www/app/views/pages/about.html.erb
rm -rf /var/www/app/views/pages/about.txt
