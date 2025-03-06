#!/usr/bin/env bash

TOKEN=$(curl -s -X 'POST' 'http://localhost:8000/api/v1/login/access-token' -H 'Content-Type: application/x-www-form-urlencoded' -d 'username=admin@example.com&password=admin' | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')

echo "Getting users..."
curl -s -X 'GET' 'http://localhost:8000/api/v1/users/' -H 'accept: application/json' -H "Authorization: Bearer $TOKEN"

echo "Getting items..."
curl -s -X 'GET' 'http://localhost:8000/api/v1/items/' -H 'accept: application/json' -H "Authorization: Bearer $TOKEN"

echo "Getting notes..."
curl -s -X 'GET' 'http://localhost:8000/api/v1/notes/' -H 'accept: application/json' -H "Authorization: Bearer $TOKEN"
