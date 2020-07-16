#!/bin/bash
# ApplicationStart:
# You typically use this deployment lifecycle event to restart services
# that were stopped during ApplicationStop.
# Run the rails server command - same command for all environments
echo "ApplicationStart starting..."
cd /var/www
./aws/codedeploy/set-hostname.sh
export RACK_ENV=production
export RAILS_SERVE_STATIC_FILES=true
export PORT=3000
bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-production} &> /dev/null < /dev/null &
