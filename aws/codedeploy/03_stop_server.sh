#!/bin/bash
# ApplicationStop:
# Find a way to identify the Rails server process and kill it
echo "ApplicationStop starting..."
kill -9 `cat /var/www/tmp/pids/server.pid`
echo "ApplicationStop complete."
