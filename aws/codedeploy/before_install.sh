# BeforeInstall:
# You can use this deployment lifecycle event for preinstall tasks, such as 
# decrypting files and creating a backup of the current version.
echo "BeforeInstall starting..."
cd /var
rm -f ./aws-eb-demo-deployable.zip
echo "BeforeInstall complete."