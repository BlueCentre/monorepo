# Template FastAPI Application

A modern FastAPI application template with PostgreSQL, Google Cloud Pub/Sub, and more.

## Features

- **FastAPI**: Modern, fast (high-performance) web framework for building APIs
- **PostgreSQL**: Robust relational database with SQLAlchemy ORM
- **Alembic**: Database migration tool
- **Pydantic**: Data validation and settings management
- **JWT Authentication**: Secure authentication with JSON Web Tokens
- **Google Cloud Pub/Sub**: Asynchronous messaging
- **OpenTelemetry**: Comprehensive observability with distributed tracing, metrics, and logs
- **Docker**: Containerization for easy deployment
- **Kubernetes**: Deployment configuration for Kubernetes
- **Testing**: Pytest for unit and integration tests

## Project Structure

```
template_fastapi_app/
├── app/                    # Application package
│   ├── api/                # API endpoints
│   │   ├── deps.py         # Dependencies for API endpoints
│   │   └── v1/             # API version 1
│   │       ├── endpoints/  # API endpoints
│   │       └── api.py      # API router
│   ├── core/               # Core modules
│   │   ├── config.py       # Configuration settings
│   │   ├── security.py     # Security utilities
│   │   └── telemetry.py    # OpenTelemetry configuration
│   ├── crud/               # CRUD operations
│   ├── db/                 # Database modules
│   │   ├── base.py         # Base model imports
│   │   ├── base_class.py   # Base class for models
│   │   ├── init_db.py      # Database initialization
│   │   └── session.py      # Database session
│   ├── models/             # SQLAlchemy models
│   ├── pubsub/             # Pub/Sub modules
│   │   ├── publisher.py    # Pub/Sub publisher
│   │   └── subscriber.py   # Pub/Sub subscriber
│   ├── schemas/            # Pydantic schemas
│   └── main.py             # FastAPI application
├── migrations/             # Alembic migrations
├── tests/                  # Tests
├── .env                    # Environment variables
├── .env.example            # Example environment variables
├── Dockerfile              # Docker configuration
├── docker-compose.yml      # Docker Compose configuration
├── requirements.txt        # Python dependencies
└── run.py                  # Script to run the application
```

## Getting Started

### Prerequisites

- Python 3.11+
- PostgreSQL
- Google Cloud SDK (for Pub/Sub)

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/template_fastapi_app.git
cd template_fastapi_app
```

2. Create a virtual environment:

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:

```bash
pip install -r requirements.txt
```

4. Create a `.env` file based on `.env.example`:

```bash
cp .env.example .env
```

5. Edit the `.env` file with your configuration.

### Running the Application

```bash
python run.py
```

The API will be available at http://localhost:8000.

### API Documentation

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

### Running Tests

```bash
pytest
```

## Observability with OpenTelemetry

This template includes OpenTelemetry for comprehensive observability:

- **Tracing**: Distributed tracing for all requests and database operations
- **Metrics**: Application and runtime metrics
- **Logging**: Correlation between logs and traces

### Tracing in Development

When running locally with Docker Compose, OpenTelemetry Collector is included for trace collection:

1. Start the application with Docker Compose:
   ```bash
   docker-compose up -d
   ```

2. Access the tracing UI at http://localhost:16686 (compatible with Jaeger UI)

### Tracing in Kubernetes

For Kubernetes deployments, Istio is used for distributed tracing:

1. Ensure Istio is installed in your cluster with tracing enabled
2. Apply the Kubernetes configurations:
   ```bash
   kubectl apply -f kubernetes/
   ```

3. Access the tracing UI through your Istio installation (typically Kiali or the configured tracing backend)

### Custom Instrumentation

You can add custom spans to your code:

```python
from opentelemetry import trace

tracer = trace.get_tracer(__name__)

with tracer.start_as_current_span("my-operation") as span:
    span.set_attribute("attribute.key", "attribute.value")
    # Your code here
```

## Docker

### Building the Docker Image

```bash
docker build -t template_fastapi_app .
```

### Running with Docker Compose

```bash
docker-compose up -d
```

## Deployment

### Kubernetes

```bash
kubectl apply -f kubernetes/
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
