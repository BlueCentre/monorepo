#!/usr/bin/env bash

echo "Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s http://localhost:8000/health)
echo "Health response: $HEALTH_RESPONSE"
echo ""

echo "Attempting to login..."
LOGIN_RESPONSE=$(curl -s -X 'POST' 'http://localhost:8000/api/v1/login/access-token' -H 'Content-Type: application/x-www-form-urlencoded' -d 'username=admin@example.com&password=admin')
echo "Login response: $LOGIN_RESPONSE"
echo ""

# Try to extract token if login was successful
if [[ $LOGIN_RESPONSE == *"access_token"* ]]; then
  TOKEN=$(echo $LOGIN_RESPONSE | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')
  echo "============================================="
  echo "AUTHENTICATION TOKEN: $TOKEN"
  echo "============================================="
  echo ""

  echo "Getting users..."
  USER_RESPONSE=$(curl -s -X 'GET' 'http://localhost:8000/api/v1/users/' -H 'accept: application/json' -H "Authorization: Bearer $TOKEN")
  echo "Users response: $USER_RESPONSE"
  echo ""

  echo "Getting items..."
  ITEMS_RESPONSE=$(curl -s -X 'GET' 'http://localhost:8000/api/v1/items/' -H 'accept: application/json' -H "Authorization: Bearer $TOKEN")
  echo "Items response: $ITEMS_RESPONSE"
  echo ""

  echo "Getting notes..."
  NOTES_RESPONSE=$(curl -s -X 'GET' 'http://localhost:8000/api/v1/notes/' -H 'accept: application/json' -H "Authorization: Bearer $TOKEN")
  echo "Notes response: $NOTES_RESPONSE"
  echo ""
  
  echo "Smoke test completed successfully!"
else
  echo "Failed to get token. Cannot proceed with API tests."
  echo ""
  
  # Try to get more information about the error
  echo "Checking database connection..."
  DB_POD=$(kubectl get pods -n template-fastapi-app -l app=postgres -o jsonpath='{.items[0].metadata.name}')
  echo "Database pod: $DB_POD"
  echo ""
  
  echo "Checking if database initialization job ran successfully..."
  kubectl get jobs -n template-fastapi-app
  echo ""
  
  echo "Checking application logs for errors..."
  APP_POD=$(kubectl get pods -n template-fastapi-app -l app=template-fastapi-app -o jsonpath='{.items[0].metadata.name}')
  kubectl logs -n template-fastapi-app $APP_POD --tail=50
fi
