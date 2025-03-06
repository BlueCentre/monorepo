"""
Tests for OpenTelemetry integration.
"""

import unittest
from unittest.mock import MagicMock, patch

from fastapi import FastAPI
from sqlalchemy.engine import Engine

from app.core.telemetry import setup_telemetry


class TestOpenTelemetry(unittest.TestCase):
    """Test the OpenTelemetry integration."""
    
    @patch('app.core.telemetry.FastAPIInstrumentor')
    @patch('app.core.telemetry.LoggingInstrumentor')
    @patch('app.core.telemetry.SQLAlchemyInstrumentor')
    @patch('app.core.telemetry.trace')
    @patch('app.core.telemetry.TracerProvider')
    @patch('app.core.telemetry.BatchSpanProcessor')
    @patch('app.core.telemetry.OTLPSpanExporter')
    @patch('app.core.telemetry.ConsoleSpanExporter')
    @patch('app.core.telemetry.Resource')
    def test_setup_telemetry(
        self,
        mock_resource,
        mock_console_exporter,
        mock_otlp_exporter,
        mock_batch_processor,
        mock_tracer_provider,
        mock_trace,
        mock_sqlalchemy_instrumentor,
        mock_logging_instrumentor,
        mock_fastapi_instrumentor,
    ):
        """Test that setup_telemetry configures all components correctly."""
        # Arrange
        app = FastAPI()
        engine = MagicMock(spec=Engine)
        service_name = "test-service"
        exporter_endpoint = "http://test:4317"
        
        # Resource configuration
        mock_resource_instance = MagicMock()
        mock_resource.create.return_value = mock_resource_instance
        
        # Tracer provider configuration
        mock_tracer_provider_instance = MagicMock()
        mock_tracer_provider.return_value = mock_tracer_provider_instance
        
        # Console exporter
        mock_console_exporter_instance = MagicMock()
        mock_console_exporter.return_value = mock_console_exporter_instance
        
        # OTLP exporter
        mock_otlp_exporter_instance = MagicMock()
        mock_otlp_exporter.return_value = mock_otlp_exporter_instance
        
        # Batch processor
        mock_batch_processor_instance = MagicMock()
        mock_batch_processor.return_value = mock_batch_processor_instance
        
        # Instrumentors
        mock_fastapi_instrumentor_instance = MagicMock()
        mock_fastapi_instrumentor.instrument_app.return_value = mock_fastapi_instrumentor_instance
        
        mock_logging_instrumentor_instance = MagicMock()
        mock_logging_instrumentor.return_value.instrument.return_value = mock_logging_instrumentor_instance
        
        mock_sqlalchemy_instrumentor_instance = MagicMock()
        mock_sqlalchemy_instrumentor.return_value.instrument.return_value = mock_sqlalchemy_instrumentor_instance
        
        # Act
        setup_telemetry(
            app=app,
            sqlalchemy_engine=engine,
            service_name=service_name,
            exporter_endpoint=exporter_endpoint,
        )
        
        # Assert
        # Verify resource was created with correct service name
        mock_resource.create.assert_called_once_with({"service.name": service_name})
        
        # Verify tracer provider was created with correct resource
        mock_tracer_provider.assert_called_once_with(resource=mock_resource_instance)
        
        # Verify OTLP exporter was created with correct endpoint
        mock_otlp_exporter.assert_called_once_with(endpoint=exporter_endpoint)
        
        # Verify batch processors were added
        mock_tracer_provider_instance.add_span_processor.assert_called()
        
        # Verify tracer provider was set globally
        mock_trace.set_tracer_provider.assert_called_once_with(mock_tracer_provider_instance)
        
        # Verify FastAPI was instrumented
        mock_fastapi_instrumentor.instrument_app.assert_called_once_with(
            app, tracer_provider=mock_tracer_provider_instance
        )
        
        # Verify logging was instrumented
        mock_logging_instrumentor.return_value.instrument.assert_called_once_with(
            tracer_provider=mock_tracer_provider_instance
        )
        
        # Verify SQLAlchemy was instrumented
        mock_sqlalchemy_instrumentor.return_value.instrument.assert_called_once_with(
            engine=engine, tracer_provider=mock_tracer_provider_instance
        ) 