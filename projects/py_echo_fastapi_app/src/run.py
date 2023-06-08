import sys
import uvicorn

if __name__ == "__main__":
    # freeze_support()
    uvicorn.run("projects.py_echo_fastapi_app.main:app", host="0.0.0.0")

    # sys.argv.insert(1, "projects.py_echo_fastapi_app.main:app")
    # sys.exit(uvicorn.main())  # pylint: disable=no-value-for-parameter
