import sys
import http.server
import socketserver
import json
import random
import logging
from urllib.parse import urlparse, parse_qs

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: (%(module)s) %(message)s')
logger = logging.getLogger(__name__)

# Import the DevOps models directly
try:
    from libs.py.devops.models.devops import DevOps, InfrastructureEngineer, DeveloperExperienceEngineer, DataEngineer, MachineLearningEngineer, WebEngineer, ReliabilityEngineer, PlatformEngineer, PlatformOrganization
except ImportError:
    logger.error("Failed to import DevOps models. Some functionality may be limited.")
    
    # Define mock classes for testing
    class DevOps:
        def __init__(self, name):
            self.name = name
        def __str__(self):
            return f"MockDevOps<{self.name}>"
        def speak(self):
            pass
    
    class InfrastructureEngineer(DevOps):
        def __str__(self):
            return f"MockInfrastructureEngineer<{self.name}>"
    
    class PlatformOrganization:
        def __init__(self, factory):
            self.devops_factory = factory
        def request_devops(self, name):
            return self.devops_factory(name)

# Create a DevOpsApp class to handle business logic
class DevOpsApp:
    """DevOps App implementation."""
    
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
    
    def get_devops(self, devops_id):
        """Get a devops."""
        try:
            platform = PlatformOrganization(InfrastructureEngineer)
            devops = platform.request_devops(devops_id)
            return {"devops": str(devops)}
        except Exception as e:
            logger.error(f"Error in get_devops: {e}")
            return {"error": "Failed to get devops", "devops_id": devops_id}
    
    def get_devops_random_item(self, name):
        """Get a random devops."""
        try:
            def random_platform(name):
                return random.choice([
                    InfrastructureEngineer, 
                    DeveloperExperienceEngineer, 
                    DataEngineer, 
                    MachineLearningEngineer, 
                    WebEngineer, 
                    ReliabilityEngineer, 
                    PlatformEngineer])(name)
                
            platform = PlatformOrganization(random_platform)
            devops = platform.request_devops(name)
            return {"random_devops": str(devops)}
        except Exception as e:
            logger.error(f"Error in get_devops_random_item: {e}")
            return {"error": "Failed to get random devops", "name": name}

# Create a singleton instance
app = DevOpsApp()

class DevOpsHandler(http.server.SimpleHTTPRequestHandler):
    """Simple HTTP request handler for DevOps App."""
    
    def do_GET(self):
        """Handle GET requests."""
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        
        if path == '/':
            self.send_response_json(app.get_root())
        elif path == '/status':
            self.send_response_json(app.get_status())
        elif path == '/healthcheck':
            self.send_response_json(app.get_healthcheck())
        elif path.startswith('/devops/'):
            parts = path.split('/')
            if len(parts) >= 3:
                if parts[2] == 'random' and len(parts) >= 4:
                    name = parts[3]
                    response = app.get_devops_random_item(name)
                    self.send_response_json(response)
                else:
                    devops_id = parts[2]
                    response = app.get_devops(devops_id)
                    self.send_response_json(response)
            else:
                self.send_error(404, "Not Found")
        else:
            self.send_error(404, "Not Found")
    
    def send_response_json(self, data):
        """Send a JSON response."""
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode('utf-8'))

def main():
    """Run the server."""
    port = 9090
    handler = DevOpsHandler
    
    with socketserver.TCPServer(("", port), handler) as httpd:
        print(f"Server started at http://localhost:{port}")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("Server stopped.")
            httpd.server_close()

if __name__ == "__main__":
    main()
