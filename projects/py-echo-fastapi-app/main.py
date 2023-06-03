from fastapi import FastAPI

app = FastAPI()


@app.get("/status")
def read_root():
    return {"status": "UP", "version": "0.1.0"}
