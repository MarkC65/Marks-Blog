# AfterInstall:
# You can use this deployment lifecycle event for tasks such as configuring 
# your application or changing file permissions.
# Install the appropriate master.key / credentials files for the environment.
# Use the "$DEPLOYMENT_GROUP_NAME" env var to determine the environment
# Point to correct DB
# Set the env vars for the appropriate staging/test or production environment
# Disable redis caching for non-production. Point to correct elasticache in production
echo "AfterInstall starting..." >> tmp/05.txt
cd /var/www >> tmp/05.txt
aws s3 cp s3://eb-rails-server/credentials.yml.enc ./config/credentials.yml.enc >> tmp/05.txt
aws s3 cp s3://eb-rails-server/master.key ./config/master.key >> tmp/05.txt
bundle install --without development:test --path vendor/bundle --binstubs vendor/bundle/bin -j4 --deployment >> tmp/05.txt
bundle exec rake assets:precompile RAILS_ENV=production >> tmp/05.txt
echo "AfterInstall complete."
