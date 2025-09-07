"""
OpenTelemetry configuration for observability.
"""

import logging

from fastapi import FastAPI
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.logging import LoggingInstrumentor
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter
from sqlalchemy.engine import Engine

from app.core.config import settings

logger = logging.getLogger(__name__)


def setup_telemetry(
    app: FastAPI,
    sqlalchemy_engine: Engine | None = None,
    service_name: str | None = None,
    exporter_endpoint: str | None = None,
) -> None:
    """
    Set up OpenTelemetry for the application.

    Args:
        app: FastAPI application instance.
        sqlalchemy_engine: SQLAlchemy engine instance.
        service_name: Name of the service for OpenTelemetry.
        exporter_endpoint: Endpoint for the OTLP exporter.
    """
    # Use service name from settings if not provided
    service_name = service_name or settings.PROJECT_NAME.replace(" ", "_").lower()

    # Create resource
    resource = Resource.create({"service.name": service_name})

    # Create tracer provider
    tracer_provider = TracerProvider(resource=resource)

    # Add console exporter for development
    if settings.ENVIRONMENT == "development":
        logger.info("Setting up console exporter for OpenTelemetry")
        tracer_provider.add_span_processor(BatchSpanProcessor(ConsoleSpanExporter()))

    # Add OTLP exporter if endpoint is provided
    if exporter_endpoint or settings.OTLP_EXPORTER_ENDPOINT:
        endpoint = exporter_endpoint or settings.OTLP_EXPORTER_ENDPOINT
        logger.info(
            f"Setting up OTLP exporter for OpenTelemetry with endpoint: {endpoint}"
        )

        otlp_exporter = OTLPSpanExporter(endpoint=endpoint)
        tracer_provider.add_span_processor(BatchSpanProcessor(otlp_exporter))

    # Set global tracer provider
    trace.set_tracer_provider(tracer_provider)

    # Instrument FastAPI
    logger.info("Instrumenting FastAPI with OpenTelemetry")
    FastAPIInstrumentor.instrument_app(app, tracer_provider=tracer_provider)

    # Instrument logging
    logger.info("Instrumenting logging with OpenTelemetry")
    LoggingInstrumentor().instrument(tracer_provider=tracer_provider)

    # Instrument SQLAlchemy if engine is provided
    if sqlalchemy_engine:
        logger.info("Instrumenting SQLAlchemy with OpenTelemetry")
        SQLAlchemyInstrumentor().instrument(
            engine=sqlalchemy_engine,
            tracer_provider=tracer_provider,
        )

    logger.info("OpenTelemetry setup complete")
