#!/bin/bash
# ApplicationStop:
# Find a way to identify the Rails server process and kill it
echo "ApplicationStop starting..."
# cd /var/www
kill -9 `cat /var/www/tmp/pids/server.pid`
echo "ApplicationStop complete."
