import random
import logging

from libs.py.devops.models.devops import DevOps, InfrastructureEngineer, DeveloperExperienceEngineer, DataEngineer, MachineLearningEngineer, WebEngineer, ReliabilityEngineer, PlatformEngineer, PlatformOrganization

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: (%(module)s) %(message)s')
logger = logging.getLogger(__name__)

# Create a random platform
def random_platform(name: str) -> DevOps:
    """Let's be dynamic!"""
    return random.choice([
        InfrastructureEngineer, 
        DeveloperExperienceEngineer, 
        DataEngineer, 
        MachineLearningEngineer, 
        WebEngineer, 
        ReliabilityEngineer, 
        PlatformEngineer])(name)

class DevOpsApp:
    """DevOps FastAPI App converted to a regular Python class."""
    
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
    
    def get_devops(self, devops_id: str):
        """Get a devops."""
        platform = PlatformOrganization(InfrastructureEngineer)
        devops = platform.request_devops("John")
        devops.speak()
        return devops.__str__()
    
    def get_devops_random_item(self, name: str):
        """Get a random devops."""
        platform = PlatformOrganization(random_platform)
        devops = platform.request_devops(name)
        devops.speak()
        return devops.__str__()

# Create a singleton instance
app = DevOpsApp()

# @router.get("/{workflow_id}", response_model=WorkflowRead)
# def get_workflow(db_session: DbSession, workflow_id: PrimaryKey):
#     """Get a workflow."""
#     workflow = get(db_session=db_session, workflow_id=workflow_id)
#     if not workflow:
#         raise HTTPException(
#             status_code=status.HTTP_404_NOT_FOUND,
#             detail=[{"msg": "A workflow with this id does not exist."}],
#         )
#     return workflow
