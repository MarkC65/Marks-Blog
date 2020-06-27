echo "Create_test_db starting..."
cd /var/www
curl "http://localhost:3000" | grep "Mark's" > ./tmp/curl.txt
echo "Create_test_db complete."
