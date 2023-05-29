#!/usr/bin/env python3
"""
Simple HTTP server for the Calculator app using Python's standard library.
"""

import http.server
import socketserver
import json
import random
from urllib.parse import urlparse, parse_qs

# Import the Calculator class
from libs.py.calculator.models.calculator import Calculator

# Create a calculator instance
my_calculator = Calculator()

class CalculatorHandler(http.server.SimpleHTTPRequestHandler):
    """HTTP request handler for the Calculator app."""
    
    def do_GET(self):
        """Handle GET requests."""
        parsed_url = urlparse(self.path)
        path = parsed_url.path
        
        if path == '/':
            # Generate random numbers for the calculator
            num1 = random.randint(0, 100)
            num2 = random.randint(0, 100)
            result = my_calculator.add(num1, num2)
            
            # Create a message
            message = f"Did you know {num1} + {num2} = {result}?"
            self.send_response_html(message)
        elif path == '/calculate':
            # Parse query parameters
            query_params = parse_qs(parsed_url.query)
            
            try:
                num1 = int(query_params.get('num1', ['0'])[0])
                num2 = int(query_params.get('num2', ['0'])[0])
                result = my_calculator.add(num1, num2)
                
                result_message = f"Result: {num1} + {num2} = {result}"
                self.send_response_html(result_message, result=f"{num1} + {num2} = {result}")
            except (ValueError, TypeError) as e:
                self.send_error(400, f"Bad request: {str(e)}")
        else:
            self.send_error(404, "Not found")
    
    def send_response_html(self, message, result=None):
        """Send an HTML response."""
        self.send_response(200)
        self.send_header('Content-Type', 'text/html')
        self.end_headers()
        
        html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Calculator App</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }}
                h1 {{ color: #333; }}
                .message {{ font-size: 24px; margin: 20px 0; padding: 20px; background-color: #f0f0f0; border-radius: 5px; }}
                .calculator {{ margin-top: 30px; }}
                input, button {{ padding: 10px; margin: 5px; }}
                button {{ background-color: #4CAF50; color: white; border: none; cursor: pointer; }}
                button:hover {{ background-color: #45a049; }}
                #result {{ font-weight: bold; margin-top: 20px; }}
            </style>
        </head>
        <body>
            <h1>Calculator App</h1>
            <div class="message">{message}</div>
            
            <div class="calculator">
                <h2>Try it yourself:</h2>
                <form action="/calculate" method="get">
                    <input type="number" name="num1" placeholder="First number" required>
                    <input type="number" name="num2" placeholder="Second number" required>
                    <button type="submit">Add</button>
                </form>
                {f'<div id="result">{result}</div>' if result else ''}
            </div>
        </body>
        </html>
        """
        
        self.wfile.write(html.encode('utf-8'))
    
    # Override the default directory listing behavior
    def list_directory(self, path):
        """Override to prevent directory listing."""
        self.send_error(403, "Directory listing forbidden")
        return None

def main():
    """Run the server."""
    port = 8080
    handler = CalculatorHandler
    
    print(f"=== Starting Calculator server on port {port} ===")
    print(f"Visit http://localhost:{port}/ to use the calculator")
    
    with socketserver.TCPServer(("", port), handler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n=== Server stopped ===")

if __name__ == "__main__":
    main()
