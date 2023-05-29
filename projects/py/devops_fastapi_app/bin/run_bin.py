#!/usr/bin/env python3
"""
DevOps FastAPI App Runner.

This script runs the DevOps FastAPI application using uvicorn.
"""

import logging
import sys
import os
import uvicorn

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger(__name__)

# Add the parent directory to sys.path to allow importing the app module
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Import the DevOps models directly
try:
    from libs.py.devops.models.devops import DevOps, InfrastructureEngineer, DeveloperExperienceEngineer, DataEngineer, MachineLearningEngineer, WebEngineer, ReliabilityEngineer, PlatformEngineer, PlatformOrganization
except ImportError:
    logger.error("Failed to import DevOps models. Some functionality may be limited.")
    
    # Define mock classes for testing
    class DevOps:
        def __init__(self, name):
            self.name = name
        def __str__(self):
            return f"MockDevOps<{self.name}>"
        def speak(self):
            pass
    
    class InfrastructureEngineer(DevOps):
        def __str__(self):
            return f"MockInfrastructureEngineer<{self.name}>"
    
    class PlatformOrganization:
        def __init__(self, factory):
            self.devops_factory = factory
        def request_devops(self, name):
            return self.devops_factory(name)

# Create a DevOpsApp class to handle business logic
class DevOpsApp:
    """DevOps App implementation."""
    
    def __init__(self):
        """Initialize the app."""
        logger.info("=== [Starting DevOps App] ===")
    
    def get_root(self):
        """Get the root endpoint."""
        return {"message": "I am alive!!!"}
    
    def get_status(self):
        """Get the status endpoint."""
        return {"status": "UP", "version": "0.1.2"}
    
    def get_healthcheck(self):
        """Get the healthcheck endpoint."""
        return {"status": "UP", "msg": "degraded"}
    
    def get_devops(self, devops_id):
        """Get a devops."""
        try:
            platform = PlatformOrganization(InfrastructureEngineer)
            devops = platform.request_devops(devops_id)
            return {"devops": str(devops)}
        except Exception as e:
            logger.error(f"Error in get_devops: {e}")
            return {"error": "Failed to get devops", "devops_id": devops_id}
    
    def get_devops_random_item(self, name):
        """Get a random devops."""
        try:
            def random_platform(name):
                return random.choice([
                    InfrastructureEngineer, 
                    DeveloperExperienceEngineer, 
                    DataEngineer, 
                    MachineLearningEngineer, 
                    WebEngineer, 
                    ReliabilityEngineer, 
                    PlatformEngineer])(name)
                
            platform = PlatformOrganization(random_platform)
            devops = platform.request_devops(name)
            return {"random_devops": str(devops)}
        except Exception as e:
            logger.error(f"Error in get_devops_random_item: {e}")
            return {"error": "Failed to get random devops", "name": name}

# Create a singleton instance
app = DevOpsApp()

def main() -> None:
    """
    Main function to run the FastAPI application using uvicorn.
    """
    logger.info("Starting DevOps FastAPI app with uvicorn...")
    
    # Configure and run uvicorn server
    uvicorn.run(
        "app.web_app:app",
        host="0.0.0.0",
        port=9090,
        reload=False,
        log_level="info",
        access_log=True
    )

if __name__ == "__main__":
    main()
