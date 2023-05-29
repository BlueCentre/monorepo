# Overview

Results from just enabling remote executor on BuildBuddy.

## Configs

```
build:ci --remote_executor=grpcs://remote.buildbuddy.io
build:ci --remote_timeout=3600
build:ci --jobs=50
```

## Results

Validation done using the same Pull Request:

| Validation | Number of Targets | Build Time |
|------------|-------------------|------------|
| Without Remote Executors | 90 | 4m 38s |
| With 50 Remote Executors | 90 | 2m 21s |

## Reference

- https://www.buildbuddy.io/docs/rbe-setup
