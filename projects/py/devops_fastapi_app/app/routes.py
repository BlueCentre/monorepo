from fastapi import APIRouter, Path, HTTPException
from typing import Dict, Any
import random
import logging

from libs.py.devops.models.devops import (
    PlatformOrganization,
    random_platform,
    InfrastructureEngineer,
    DeveloperExperienceEngineer,
    DataEngineer,
    MachineLearningEngineer,
    WebEngineer,
    ReliabilityEngineer,
    PlatformEngineer
)
from .models import StatusResponse, HealthResponse, DevOpsResponse

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create router
router = APIRouter()


@router.get("/", response_model=Dict[str, str])
async def get_root() -> Dict[str, str]:
    """
    Root endpoint that returns a simple alive message.
    
    Returns:
        Dict[str, str]: A dictionary with a message key.
    """
    logger.info("GET request to root endpoint")
    return {"message": "I am alive"}


@router.get("/status", response_model=StatusResponse)
async def get_status() -> StatusResponse:
    """
    Status endpoint that returns application status and version.
    
    Returns:
        StatusResponse: Application status information.
    """
    logger.info("GET request to status endpoint")
    return StatusResponse()


@router.get("/healthcheck", response_model=HealthResponse)
async def get_healthcheck() -> HealthResponse:
    """
    Health check endpoint that returns detailed health status.
    
    Returns:
        HealthResponse: Detailed health information.
    """
    logger.info("GET request to health check endpoint")
    return HealthResponse()


@router.get("/devops/{id}", response_model=DevOpsResponse)
async def get_devops(
    id: str = Path(..., description="The ID or name of the DevOps role")
) -> DevOpsResponse:
    """
    Endpoint to get a specific DevOps role by ID.
    
    Args:
        id: The ID or name for the DevOps role.
        
    Returns:
        DevOpsResponse: Information about the requested DevOps role.
        
    Raises:
        HTTPException: If the DevOps role is not found.
    """
    logger.info(f"GET request to devops endpoint with id: {id}")
    
    try:
        # Create a PlatformOrganization with the random platform factory
        platform = PlatformOrganization(random_platform)
        
        # Request a DevOps with the given ID/name
        devops = platform.request_devops(id)
        
        # Capture the message that would be printed
        import io
        from contextlib import redirect_stdout
        
        f = io.StringIO()
        with redirect_stdout(f):
            devops.speak()
        
        message = f.getvalue().strip()
        
        return DevOpsResponse(
            name=devops.name,
            type=devops.__class__.__name__,
            message=message or "No message provided"
        )
    except Exception as e:
        logger.error(f"Error retrieving DevOps role: {str(e)}")
        raise HTTPException(status_code=404, detail=f"DevOps role not found: {str(e)}")


@router.get("/devops/random/{name}", response_model=DevOpsResponse)
async def get_devops_random(
    name: str = Path(..., description="The name for the random DevOps role")
) -> DevOpsResponse:
    """
    Endpoint to get a random DevOps role with the given name.
    
    Args:
        name: The name for the DevOps role.
        
    Returns:
        DevOpsResponse: Information about a random DevOps role.
        
    Raises:
        HTTPException: If there's an error creating the DevOps role.
    """
    logger.info(f"GET request to random devops endpoint with name: {name}")
    
    try:
        # Get a random DevOps with the given name
        devops = random_platform(name)
        
        # Capture the message that would be printed
        import io
        from contextlib import redirect_stdout
        
        f = io.StringIO()
        with redirect_stdout(f):
            devops.speak()
        
        message = f.getvalue().strip()
        
        return DevOpsResponse(
            name=devops.name,
            type=devops.__class__.__name__,
            message=message or "No message provided"
        )
    except Exception as e:
        logger.error(f"Error creating random DevOps role: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error creating DevOps role: {str(e)}") 