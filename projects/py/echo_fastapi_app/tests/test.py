#!/usr/bin/env python3
"""
Test file for the Echo FastAPI App using Python's standard library.
"""

import unittest
import json
import urllib.request
import subprocess
import time
import os
import signal
import sys
import threading
import socket

class TestEchoApp(unittest.TestCase):
    """Test cases for the Echo FastAPI App."""
    
    # Define the port as a class variable
    PORT = 5678
    
    @classmethod
    def setUpClass(cls):
        """Start the server before running tests."""
        # Path to the run_bin.py script
        script_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 
                                  "bin", "run_bin.py")
        
        # Check if port is already in use
        cls.port_in_use = False
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            cls.port_in_use = s.connect_ex(('localhost', cls.PORT)) == 0
        
        if cls.port_in_use:
            print(f"Port {cls.PORT} is already in use, skipping server start")
            return
        
        # Start the server in a separate process
        cls.server_process = subprocess.Popen([sys.executable, script_path],
                                             stdout=subprocess.PIPE,
                                             stderr=subprocess.PIPE)
        
        # Give the server time to start
        time.sleep(2)
        
        # Check if server started successfully
        if cls.server_process.poll() is not None:
            stdout, stderr = cls.server_process.communicate()
            print(f"Server stdout: {stdout.decode('utf-8')}")
            print(f"Server stderr: {stderr.decode('utf-8')}")
            raise RuntimeError("Server failed to start")
        
        # Wait for the server to be ready
        max_retries = 5
        for i in range(max_retries):
            try:
                with urllib.request.urlopen(f'http://localhost:{cls.PORT}/status', timeout=1) as response:
                    if response.getcode() == 200:
                        break
            except Exception:
                if i == max_retries - 1:
                    cls.server_process.terminate()
                    cls.server_process.wait()
                    raise RuntimeError("Server did not respond in time")
                time.sleep(1)
        
        print("Server started for testing")
    
    @classmethod
    def tearDownClass(cls):
        """Stop the server after running tests."""
        # Terminate the server process only if we started it
        if not hasattr(cls, 'port_in_use') or not cls.port_in_use:
            if hasattr(cls, 'server_process') and cls.server_process:
                cls.server_process.terminate()
                cls.server_process.wait()
                print("Server stopped after testing")
    
    def test_root_endpoint(self):
        """Test the root endpoint."""
        try:
            with urllib.request.urlopen(f'http://localhost:{self.PORT}/') as response:
                data = response.read().decode('utf-8')
                self.assertEqual(json.loads(data), "I am alive")
        except Exception as e:
            self.fail(f"Root endpoint test failed: {e}")
    
    def test_status_endpoint(self):
        """Test the status endpoint."""
        try:
            with urllib.request.urlopen(f'http://localhost:{self.PORT}/status') as response:
                data = json.loads(response.read().decode('utf-8'))
                self.assertEqual(data['status'], 'UP')
                self.assertEqual(data['version'], '0.1.0')
        except Exception as e:
            self.fail(f"Status endpoint test failed: {e}")

if __name__ == '__main__':
    unittest.main()
