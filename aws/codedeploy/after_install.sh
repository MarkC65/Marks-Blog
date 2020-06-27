# AfterInstall:
# You can use this deployment lifecycle event for tasks such as configuring 
# your application or changing file permissions.
# Install the appropriate master.key / credentials files for the environment.
# Use the "$DEPLOYMENT_GROUP_NAME" env var to determine the environment
# Point to correct DB
# Set the env vars for the appropriate staging/test or production environment
# Disable redis caching for non-production. Point to correct elasticache in production
echo "AfterInstall starting..."
mkdir /var/www && cd /var/www
unzip ../aws-eb-demo-deployable.zip -d .
if [ "$DEPLOYMENT_GROUP_NAME" == "Staging" ]
then
  echo "Detected staging environment"
  export RACK_ENV=production
  export RAILS_SERVE_STATIC_FILES=true
  export PORT=3000
  bundle install --without development:test --path vendor/bundle --binstubs vendor/bundle/bin -j4 --deployment
  bundle exec rake assets:precompile RAILS_ENV=production
fi

echo "AfterInstall complete."
