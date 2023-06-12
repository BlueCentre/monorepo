import click
import logging
import random

from fastapi import FastAPI
from fastapi.responses import JSONResponse

from libs.devops.models.devops import DevOps, InfrastructureEngineer, DeveloperExperienceEngineer, DataEngineer, MachineLearningEngineer, WebEngineer, ReliabilityEngineer, PlatformEngineer, PlatformOrganization

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

app = FastAPI()


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


@app.on_event("startup")
async def startup_event():
    logging.info(f"===[Starting FastAPI app...]===")

@app.on_event("shutdown")
async def shutdown_event():
    logging.info(f"===[Stopping FastAPI app...]===")


@app.get("/")
async def root():
    return JSONResponse("I am alive")

@app.get("/status")
async def read_root():
    return {"status": "UP", "version": "0.1.0"}


@app.get("/devops/{devops_id}")
async def get_devops(devops_id):
    """Get a devops."""
    platform = PlatformOrganization(InfrastructureEngineer)
    devops = platform.request_devops("James")
    devops.speak()
    return devops.__str__()

@app.get("/devops/random/{name}")
async def get_devops_random(name):
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
