# echo "message" | nc 127.0.0.1 8080
curl --http0.9 -X GET -H "Authorization: Bearer" http://localhost:8080
# curl -v -X GET -H "Authorization: Bearer" http://localhost:8080 #get details