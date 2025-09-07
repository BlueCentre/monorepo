"""
Test suite for helloworld_py_app
"""

import pytest
from unittest.mock import patch
import sys
import os

# Add the app directory to the path for testing
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'app'))

from cli import Helloworld


class TestHelloworld:
    """Test cases for Helloworld class"""
    
    def test_helloworld_initialization(self):
        """Test that Helloworld class initializes correctly"""
        hello = Helloworld("Alice")
        assert hello.name == "Alice"
    
    def test_helloworld_initialization_empty(self):
        """Test that Helloworld class handles empty name"""
        hello = Helloworld("")
        assert hello.name == ""
    
    @patch('builtins.print')
    def test_say_hello_output(self, mock_print):
        """Test that say_hello produces expected output"""
        hello = Helloworld("Bob")
        hello.say_hello()
        
        mock_print.assert_called_once_with("Hello Bob!")
    
    @patch('builtins.print')
    def test_say_hello_different_names(self, mock_print):
        """Test say_hello with different names"""
        test_cases = ["Alice", "Bob", "Charlie", ""]
        
        for name in test_cases:
            mock_print.reset_mock()
            hello = Helloworld(name)
            hello.say_hello()
            
            expected_output = f"Hello {name}!"
            mock_print.assert_called_once_with(expected_output)
    
    @patch('builtins.print')
    def test_say_hello_special_characters(self, mock_print):
        """Test say_hello with names containing special characters"""
        hello = Helloworld("José")
        hello.say_hello()
        
        mock_print.assert_called_once_with("Hello José!")


class TestDefaultUsage:
    """Test the default usage pattern from __main__.py"""
    
    @patch('builtins.print')
    def test_default_jane_usage(self, mock_print):
        """Test the default usage creates 'Jane' greeting"""
        hello = Helloworld("Jane")
        hello.say_hello()
        
        mock_print.assert_called_once_with("Hello Jane!")


if __name__ == '__main__':
    pytest.main([__file__])