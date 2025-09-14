#!/bin/bash
set -e

cd ..

# Run tests with coverage and generate XML report
echo "Running tests with coverage..."
python -m pytest --cov=app --cov-report=xml:coverage.xml --cov-report=term --junitxml=test-results.xml

# Display coverage report
echo "Coverage report:"
python -m coverage report

echo "Test reports generated for SonarQube!" 