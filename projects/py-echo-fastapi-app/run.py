import sys
import uvicorn

if __name__ == "__main__":
    # freeze_support()
    # uvicorn.run("dispatch.main:app", host="0.0.0.0")
    # sys.argv.insert(1, "exp_python.webapp.main:app")
    sys.argv.insert(1, "projects.py-echo-fastapi-app.main:app")
    sys.exit(uvicorn.main())  # pylint: disable=no-value-for-parameter
