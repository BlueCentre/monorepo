from typing import Dict, Optional, Any, List
from pydantic import BaseModel, Field


class StatusResponse(BaseModel):
    """
    Represents the status of the application.
    
    Attributes:
        status: Current status of the application. Default is "UP".
        version: Version of the application. Default is "0.1.0".
    """
    status: str = Field(default="UP", description="Current status of the application")
    version: str = Field(default="0.1.0", description="Version of the application")
    
    model_config = {
        "json_schema_extra": {
            "example": {
                "status": "UP",
                "version": "0.1.0"
            }
        }
    }


class HealthResponse(BaseModel):
    """
    Represents health check information for the application.
    
    Attributes:
        status: Health status of the application. Default is "UP".
        details: Detailed health status of various components.
    """
    status: str = Field(default="UP", description="Health status of the application")
    details: Dict[str, Dict[str, str]] = Field(
        default={
            "database": {"status": "UP"},
            "cache": {"status": "UP"},
            "storage": {"status": "UP"}
        },
        description="Detailed health status of various components"
    )
    
    model_config = {
        "json_schema_extra": {
            "example": {
                "status": "UP",
                "details": {
                    "database": {"status": "UP"},
                    "cache": {"status": "UP"},
                    "storage": {"status": "UP"}
                }
            }
        }
    }


class DevOpsResponse(BaseModel):
    """
    Represents a DevOps role response.
    
    Attributes:
        name: Name of the DevOps role.
        type: Type of the DevOps role.
        message: Message from the DevOps role.
    """
    name: str = Field(..., description="Name of the DevOps role")
    type: str = Field(..., description="Type of the DevOps role")
    message: str = Field(..., description="Message from the DevOps role")
    
    model_config = {
        "json_schema_extra": {
            "example": {
                "name": "Cloud",
                "type": "InfrastructureEngineer",
                "message": "How would you like your cloud today?"
            }
        }
    }


class ErrorResponse(BaseModel):
    """
    Represents an error response.
    
    Attributes:
        detail: Error detail message.
        status_code: HTTP status code.
    """
    detail: str = Field(..., description="Error detail message")
    status_code: int = Field(..., description="HTTP status code")
    
    model_config = {
        "json_schema_extra": {
            "example": {
                "detail": "Not found",
                "status_code": 404
            }
        }
    } 