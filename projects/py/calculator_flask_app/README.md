# Calculator Flask App

A minimal web calculator service built with only Python's standard library HTTP server (no Flask runtime yet—name retained for future migration). It reuses the shared `Calculator` model from `libs/py/calculator`.

## Overview

Demonstrates wiring shared library logic into a trivial HTML interface. Kept intentionally simple to serve as a scaffold for later enhancement (e.g., migrating to real Flask + JSON endpoints).

## Features

- Pure standard-library HTTP server
- Randomized landing page teaser (`/`)
- Query-based addition: `/calculate?num1=1&num2=2`
- Reuses shared arithmetic logic (`Calculator.add`)
- Ready for future conversion to Flask app

## Project Structure

```text
calculator_flask_app/
├── app/app.py                # HTTP server implementation
├── BUILD.bazel               # (future) Bazel target location
├── README.md
└── tests/ (added in this PR)

libs/py/calculator/
└── models/calculator.py      # Shared Calculator class
```

## Getting Started

### Prerequisites

- Python 3.11 (repository baseline)
- Bazel (for future build target; direct run works now)

### Run

Direct (current supported mode):

```bash
python projects/py/calculator_flask_app/app/app.py
```

The server will start on port 8080 by default.

### Using the Calculator

1. Navigate to <http://localhost:8080/>
1. Landing page shows random addition example
1. Submit two numbers via form → result rendered inline

## Tests

Smoke tests (added) cover:

- Calculator model addition correctness
- Basic HTTP handler output (status code + fragment check)

Run (after creating virtualenv or using repo tooling):

```bash
pytest -q projects/py/calculator_flask_app/tests
```

## Development Guidelines

- Keep server minimal until Flask migration is implemented
- Prefer reusing shared libs over duplicating logic
- Avoid adding heavy deps directly—update central `pyproject.toml` instead

## Future Enhancements

- Replace custom handler with real Flask `Flask` app
- Add JSON API endpoints
- Introduce subtraction / multiplication / division routes
- Provide Bazel `py_binary` + `py_test` targets
- Containerize + Skaffold profile

## License

Apache 2.0 (inherits repository license)
