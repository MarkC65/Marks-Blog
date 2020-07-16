#!/bin/bash
# BeforeInstall:
# You can use this deployment lifecycle event for preinstall tasks, such as 
# decrypting files and creating a backup of the current version.
echo "BeforeInstall starting..."
rm -rf /var/www
mkdir /var/www
echo "BeforeInstall complete."