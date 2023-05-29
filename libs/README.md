# Overview

Directoy containing custom common libraries used in our projects. This is different from third party dependencies which are vendor specific. This does not mean custom common libraries cannot use third party dependencies, but this allows use to keep our code separate from vendor code.

## Directory Convention

```
ROOT
|-- libs/
|   |-- BUILD.bazel
|   |-- README.md
|   |-- base/
|   |-- my_library/
|   |   |-- BUILD.bazel
|   |   |-- src/
|   |   |   |-- __init__.py
|   |   |   `-- my_code.py
|   |   `-- tests/
|   |       `-- my_test.py
|   `-- ...
```

## Library Reference Table

| Library | Short Description | Upstream | State | CODEOWNER |
|--------------|-------------------|-------|----------|----------|
| Example | My example library | None | Production | [John Doe](mailto://john.doe@email) |
| base | Base library with cross-cutting concerns implemented | some_lib | Production | [James Nguyen](mailto://james.nguyen@example.com) |
| caculator | Calculator helper library | base_go_franework_app | Development | [James Nguyen](mailto://james.nguyen@example.com) |
| devops | DevOps helper library | base | Development | [James Nguyen](mailto://james.nguyen@example.com) |

## Best Practice

1. Keep library implementation simple and avoid long chained dependencies
1. Keep strong, well defined contracts
1. Test and validate against contracts
1. Maintain high quality code coverage that is not just based on percentage of coverage
1. For ease of maintenance and upgrades, PLEASE test critical functionality for expected behavior should upstream dependencies introduce breaking changes
1. Maintain documentation on what your library does and changelogs including potential breaking changes downstream
1. Support backwards compatiblity where possible and for exceptions when you cannot, PLEASE DOCUMENT
1. If you see downstream tests breaking from your change, please work with downstream CODEOWNERS to resolve
1. Error on the side of deprecating code given explicit supported timeframes, unless you are fixing a critical bug or security issue

## Use Cases

1. Wrap vendor dependencies especially if you find yourself copy/pasting a lot of boilerplate code
1. Remove boilerplate code from projects

## Benefits

1. Keeping project code clean and consistent
1. Maintenance and fixes will be faster and safer giving higher confidence
1. Easy to refactor and validate both upstream and downstream
1. Collaboration is MUCH easier
1. Onboarding and training engineers will be simpler and quicker
