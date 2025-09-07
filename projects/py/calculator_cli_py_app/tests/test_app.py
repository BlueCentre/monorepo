"""
Test suite for calculator CLI application
"""

import os
import sys
from unittest.mock import patch

import pytest

# Add the app directory to the path for testing
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "app"))

from app import hello, my_calculator


class TestCalculatorApp:
    """Test cases for calculator CLI application"""

    def test_calculator_instance_exists(self):
        """Test that calculator instance is created"""
        assert my_calculator is not None

    @patch("app.randint")
    @patch("builtins.print")
    def test_hello_function_output(self, mock_print, mock_randint):
        """Test hello function produces expected output"""
        # Mock random number generation to make test predictable
        mock_randint.side_effect = [10, 5]  # First call returns 10, second returns 5

        # Call the function
        hello()

        # Verify that randint was called twice
        assert mock_randint.call_count == 2
        mock_randint.assert_any_call(0, 100)

        # Verify that print was called with correct message
        expected_message = "Did you know 10 + 5 = 15?"
        mock_print.assert_called_once_with(expected_message)

    @patch("app.randint")
    @patch("builtins.print")
    def test_hello_function_different_numbers(self, mock_print, mock_randint):
        """Test hello function with different random numbers"""
        # Mock different random numbers
        mock_randint.side_effect = [25, 30]

        # Call the function
        hello()

        # Verify the calculation and output
        expected_message = "Did you know 25 + 30 = 55?"
        mock_print.assert_called_once_with(expected_message)

    def test_calculator_add_operation(self):
        """Test that the calculator performs addition correctly"""
        result = my_calculator.add(10, 5)
        assert result == 15

        result = my_calculator.add(0, 0)
        assert result == 0

        result = my_calculator.add(-5, 3)
        assert result == -2

    @patch("app.randint")
    def test_hello_uses_random_numbers_in_range(self, mock_randint):
        """Test that hello function uses numbers in expected range"""
        mock_randint.side_effect = [50, 75]

        # Call the function (output doesn't matter for this test)
        with patch("builtins.print"):
            hello()

        # Verify that randint was called with correct range
        assert mock_randint.call_count == 2
        for call in mock_randint.call_args_list:
            args, kwargs = call
            assert args == (0, 100)  # Verify range is 0-100


# Integration tests
class TestCalculatorIntegration:
    """Integration tests for calculator app with real calculator library"""

    def test_real_calculator_operations(self):
        """Test actual calculator operations without mocking"""
        # These tests use the real calculator library
        assert my_calculator.add(1, 2) == 3
        assert my_calculator.add(100, 200) == 300

    def test_hello_function_real_execution(self):
        """Test hello function execution without mocking output"""
        # This should run without errors
        try:
            hello()
        except Exception as e:
            pytest.fail(f"hello() function raised an exception: {e}")


if __name__ == "__main__":
    pytest.main([__file__])
