import logging

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

# Simple mock of FastAPI functionality
class MockFastAPI:
    def __init__(self):
        self.startup_handlers = []
        self.shutdown_handlers = []
        self.routes = {}
        
    def on_event(self, event_type):
        def decorator(func):
            if event_type == "startup":
                self.startup_handlers.append(func)
            elif event_type == "shutdown":
                self.shutdown_handlers.append(func)
            return func
        return decorator
    
    def get(self, path):
        def decorator(func):
            self.routes[path] = func
            return func
        return decorator
    
    async def handle_request(self, path):
        if path in self.routes:
            return await self.routes[path]()
        return {"error": "Not Found"}
    
    async def startup(self):
        for handler in self.startup_handlers:
            await handler()
    
    async def shutdown(self):
        for handler in self.shutdown_handlers:
            await handler()

# Create a mock FastAPI app
app = MockFastAPI()

@app.on_event("startup")
async def startup_event():
    logging.info(f"=== [Starting Mock FastAPI app...] ===")

@app.on_event("shutdown")
async def shutdown_event():
    logging.info(f"=== [Stopping Mock FastAPI app...] ===")

@app.get("/")
async def root():
    return "I am alive"

@app.get("/status")
async def read_root():
    return {"status": "UP", "version": "0.1.0"}
