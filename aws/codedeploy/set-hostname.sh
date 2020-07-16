#!/bin/bash
sed -i.bkp "s/an_unknown_server/$(curl http://169.254.169.254/latest/meta-data/public-hostname)/" /var/www/app/views/pages/about.html.erb
