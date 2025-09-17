#!/bin/bash
set -e

echo "Analyzing code complexity with Radon..."
echo "Cyclomatic Complexity:"
radon cc ../app -a -s

echo "Maintainability Index:"
radon mi ../app -s

echo "Raw Metrics:"
radon raw ../app -s

echo "Enforcing complexity thresholds with Xenon..."
xenon --max-absolute B --max-modules B --max-average A ../app

echo "Complexity analysis complete!" 