import sys
import uvicorn

if __name__ == "__main__":
    # freeze_support()
    uvicorn.run("projects.template_fastapi_app.app.web_app:app", 
        host="0.0.0.0", 
        port=5000, 
        reload=True, 
        access_log=True
    )

    # sys.argv.insert(1, "projects.echo_fastapi_app.main:app")
    # sys.exit(uvicorn.main())  # pylint: disable=no-value-for-parameter
