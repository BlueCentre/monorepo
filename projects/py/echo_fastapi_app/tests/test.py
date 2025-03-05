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

class TestEchoApp(unittest.TestCase):
    """Test cases for the Echo FastAPI App."""
    
    @classmethod
    def setUpClass(cls):
        """Start the server before running tests."""
        # Path to the run_bin.py script
        script_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 
                                  "bin", "run_bin.py")
        
        # Start the server in a separate process
        cls.server_process = subprocess.Popen([sys.executable, script_path],
                                             stdout=subprocess.PIPE,
                                             stderr=subprocess.PIPE)
        
        # Give the server time to start
        time.sleep(1)
        
        # Check if server started successfully
        if cls.server_process.poll() is not None:
            raise RuntimeError("Server failed to start")
        
        print("Server started for testing")
    
    @classmethod
    def tearDownClass(cls):
        """Stop the server after running tests."""
        # Terminate the server process
        if hasattr(cls, 'server_process') and cls.server_process:
            cls.server_process.terminate()
            cls.server_process.wait()
            print("Server stopped after testing")
    
    def test_root_endpoint(self):
        """Test the root endpoint."""
        try:
            with urllib.request.urlopen('http://localhost:5000/') as response:
                data = response.read().decode('utf-8')
                self.assertEqual(data, '"I am alive"')
        except Exception as e:
            self.fail(f"Root endpoint test failed: {e}")
    
    def test_status_endpoint(self):
        """Test the status endpoint."""
        try:
            with urllib.request.urlopen('http://localhost:5000/status') as response:
                data = json.loads(response.read().decode('utf-8'))
                self.assertEqual(data['status'], 'UP')
                self.assertEqual(data['version'], '0.1.0')
        except Exception as e:
            self.fail(f"Status endpoint test failed: {e}")

if __name__ == '__main__':
    unittest.main()
