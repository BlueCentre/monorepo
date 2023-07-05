import click
import logging
import random

from typing import Union

from fastapi import FastAPI
from fastapi.responses import JSONResponse

# from libs.devops.models.devops import DevOps, InfrastructureEngineer, DeveloperExperienceEngineer, DataEngineer, MachineLearningEngineer, WebEngineer, ReliabilityEngineer, PlatformEngineer, PlatformOrganization

# TODO: Wrap this project into a class maybe?
# class DevOps_v2:
#     def __init__(self, name: str) -> None:
#         self.name = name

#     def __str__(self) -> str:
#         raise NotImplementedError

#     def speak(self) -> None:
#         raise NotImplementedError

#     def responsibility(self) -> None:
#         raise NotImplementedError

# See: https://docs.python.org/3/library/logging.html
logging.basicConfig(level=logging.INFO, format='%(levelname)s: (%(module)s) %(message)s')
logging.getLogger(__name__)

app = FastAPI(title="DevOps FastAPI Application", version="0.1.2")

@app.on_event("startup")
async def startup_event():
    logging.info(f"=== [Starting FastAPI Server] ===")

@app.on_event("shutdown")
async def shutdown_event():
    logging.info(f"=== [Stopping FastAPI Server] ===")


@app.get("/")
async def root():
    return JSONResponse("I am alive!!!")

@app.get("/status")
async def read_status():
    return {"status": "UP", "version": "0.1.2"}

@app.get("/healthcheck")
async def read_healthcheck():
    return {"status": "UP", "msg": "degraded"}
