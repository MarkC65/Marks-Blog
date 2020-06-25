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
  export RACK_ENV=development
  export PORT=3000
  # export DATABASE_URL=
  rm -rf .bundle
  bundle install --without production
  yarn install --check-files
  rm -rf .bundle
fi

if [ "$DEPLOYMENT_GROUP_NAME" == "Production" ]
then
  export RACK_ENV=production
  export RAILS_SERVE_STATIC_FILES=true
  export PORT=80
  export REDIS_URL=redis://marks-blog.wezsnv.0001.euw2.cache.amazonaws.com:6379
  unset DATABASE_URL
  aws s3 cp s3://eb-rails-server/credentials.yml.enc ./config/credentials.yml.enc
  aws s3 cp s3://eb-rails-server/master.key ./config/master.key 
  rm -r .bundle
  bundle config set deployment 'true'
  bundle config set path 'vendor/bundle'
  bundle config set without 'development:test'
  bundle install --binstubs vendor/bundle/bin -j4
  yarn install --check-files
  rm -rf .bundle
fi
echo "AfterInstall complete."
