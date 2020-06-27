# ApplicationStart:
# You typically use this deployment lifecycle event to restart services
# that were stopped during ApplicationStop.
# Run the rails server command - same command for all environments
echo "ApplicationStart starting..."
cd /var/www
if [ "$DEPLOYMENT_GROUP_NAME" == "Staging" ]
then
  echo "Detected staging environment"
  bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-production} &
fi
if [ "$DEPLOYMENT_GROUP_NAME" == "Production" ]
then
  echo "Detected staging environment"
  bundle exec puma -t 5:5 -p ${PORT:-80} -e ${RACK_ENV:-production} &
fi
echo "ApplicationStart complete."
