import random

from libs.devops.models.devops import DevOps, InfrastructureEngineer, DeveloperExperienceEngineer, DataEngineer, MachineLearningEngineer, WebEngineer, ReliabilityEngineer, PlatformEngineer, PlatformOrganization

from projects.base_py_fastapi_app.app.main import app, logging

logging.getLogger(__name__)


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


@app.get("/devops/{devops_id}")
async def get_devops(devops_id: str):
    """Get a devops."""
    platform = PlatformOrganization(InfrastructureEngineer)
    devops = platform.request_devops("James")
    devops.speak()
    return devops.__str__()

@app.get("/devops/random/{name}")
async def get_devops_random_item(name: str):
    """Get a random devops."""
    platform = PlatformOrganization(random_platform)
    devops = platform.request_devops(name)
    devops.speak()
    return devops.__str__()



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
