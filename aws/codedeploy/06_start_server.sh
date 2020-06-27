# ApplicationStart:
# You typically use this deployment lifecycle event to restart services
# that were stopped during ApplicationStop.
# Run the rails server command - same command for all environments
echo "ApplicationStart starting..."
cd /var/www >> tmp/06.txt
export RACK_ENV=production >> tmp/06.txt
export RAILS_SERVE_STATIC_FILES=true >> tmp/06.txt
export PORT=3000 >> tmp/06.txt
bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-production} & >> tmp/06.txt
