import click
import logging

from fastapi import FastAPI
from fastapi.responses import JSONResponse

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

app = FastAPI()


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
