#!/usr/bin/env bash

echo "STABLE_BUILD_GIT_DESCRIBE $(git --no-pager describe --always --dirty --broken)"
