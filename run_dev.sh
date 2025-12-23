#!/bin/bash

# Development run script
# Loads configuration from .env file and runs the app with --dart-define flags

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found!"
    echo "Please copy .env.example to .env and fill in your configuration."
    exit 1
fi

# Load environment variables from .env
export $(cat .env | grep -v '^#' | xargs)

# Run Flutter with dart-define flags
flutter run \
  --dart-define=GEMINI_API_KEY="${GEMINI_API_KEY:-AIzaSyDqn-m4hiyYESH_PoMU-jOzZ2tSTPgGO58}" \
  --dart-define=GEMINI_MODEL="${GEMINI_MODEL:-gemini-2.0-flash}" \
  --dart-define=GEMINI_BASE_URL="${GEMINI_BASE_URL:-https://generativelanguage.googleapis.com/v1beta}" \
  --dart-define=FAKE_STORE_API_URL="${FAKE_STORE_API_URL:-https://fakestoreapi.com}" \
  --dart-define=DUMMY_JSON_API_URL="${DUMMY_JSON_API_URL:-https://dummyjson.com}" \
  --dart-define=MAX_RETRIES="${MAX_RETRIES:-3}"
