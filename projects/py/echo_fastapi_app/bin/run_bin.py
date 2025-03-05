#!/usr/bin/env python3
"""
Simple HTTP server that mimics the FastAPI echo app functionality.
"""

import http.server
import socketserver
import json
import sys
import os

# Add the parent directory to the path to allow importing from app
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Import the app module if needed, but don't rely on it for core functionality
try:
    from app import web_app
    has_web_app = True
except ImportError:
    has_web_app = False

class SimpleHandler(http.server.SimpleHTTPRequestHandler):
    """Simple HTTP request handler that returns JSON responses."""
    
    def do_GET(self):
        """Handle GET requests."""
        if self.path == '/':
            self.send_json("I am alive")
        elif self.path == '/status':
            self.send_json({"status": "UP", "version": "0.1.0"})
        else:
            self.send_error(404, "Not found")
    
    def send_json(self, data):
        """Send a JSON response."""
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        
        # Convert to JSON and encode as bytes
        response = json.dumps(data).encode('utf-8')
        self.wfile.write(response)
        
    # Override the default directory listing behavior
    def list_directory(self, path):
        """Override to prevent directory listing."""
        self.send_error(403, "Directory listing forbidden")
        return None

def main():
    """Run the server."""
    port = 5678
    handler = SimpleHandler
    
    print(f"=== Starting server on port {port} ===")
    print(f"Visit http://localhost:{port}/ or http://localhost:{port}/status")
    
    # Log whether we have the web_app module
    if has_web_app:
        print("Web app module loaded successfully")
    else:
        print("Web app module not found, running standalone server")
    
    with socketserver.TCPServer(("", port), handler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n=== Server stopped ===")

if __name__ == "__main__":
    main()
