#!/bin/bash
set -e

echo "Running dependency security scan with Safety..."
safety check -r ../requirements.txt

echo "Running security scan with Bandit..."
bandit -r ../app -f txt

echo "Dependency scanning complete!" 