# Overview

The purpose of this base project aims to provide basic skaffolding for FastAPI
based projects. This project includes basic cross-cutting concerns such as, but
not limited to:

1. Kubernetes
1. Logging
1. Error Handling
1. Authentication
1. Security
1. Observability
1. ...

## Usage

To use this project, the idea is to extend this project through the use of
Bazel's dependency management. Here is a sample snippet to use in your
project's BUILD.bazel file:

```
py_library(
    name = "web_lib",
    srcs = ["app/web_app.py"],
    deps = [
        requirement("other_pypi_libs"),               # PyPi libs
        "//libs/devops:devops_lib",                   # Internal libs
        "//projects/base_py_fastapi_app:fastapi_lib", # This base project
    ],
)
```

## FastAPI Best Practices

Original reference can be found [here](https://github.com/zhanymkanov/fastapi-best-practices).
The list is displayed here for reference, but following the link provided will
give you details about each recommendation and perhaps new additions.

1. Project Structure. Consistent & predictable.
1. Excessively use Pydantic for data validation.
1. Use dependencies for data validation vs DB.
1. Chain dependencies.
1. Decouple & Reuse dependencies. Dependency calls are cached.
1. Follow the REST.
1. Don't make your routes async, if you have only blocking I/O operations.
1. Custom base model from day 0.
1. Docs.
1. Use Pydantic's BaseSettings for configs.
1. SQLAlchemy: Set DB keys naming convention.
1. Migrations. Alembic.
1. Set DB naming convention.
1. Set tests client async from day 0.
1. BackgroundTasks > asyncio.create_task.
1. Typing is important.
1. Save files in chunks.
1. Be careful with dynamic pydantic fields.
1. SQL-first, Pydantic-second.
1. Validate hosts, if users can send publicly available URLs.
1. Raise a ValueError in custom pydantic validators, if schema directly faces the client.
1. Don't forget FastAPI converts Response Pydantic Object...
1. If you must use sync SDK, then run it in a thread pool.
1. Use linters (black, isort, autoflake).
1. Bonus Section.

List of additional references:
- [geeksforgeeks](https://www.geeksforgeeks.org/tips-for-writing-efficient-and-maintainable-code-with-fastapi/)
- [dev.to](https://dev.to/gyudoza/the-best-practice-of-handling-fastapi-schema-2g3a)

## Contribute

