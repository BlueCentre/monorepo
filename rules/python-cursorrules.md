# Python - Rules for AI

This file provides guidance for working with Python projects.

## Project Structure

```
python-project/
|-- README.md
|-- requirements.txt
|-- setup.py (optional)
|-- pyproject.toml (optional)
|-- .cursorrules
|-- src/
|   |-- my_package/
|   |   |-- __init__.py
|   |   |-- module1.py
|   |   |-- module2.py
|   |   `-- ...
|-- tests/
|   |-- __init__.py
|   |-- test_module1.py
|   |-- test_module2.py
|   `-- ...
`-- docs/
    |-- index.md
    `-- ...
```

## General Guidelines

1. Follow PEP 8 style guidelines
2. Use type hints for function parameters and return values
3. Write docstrings for all modules, classes, and functions
4. Use virtual environments for dependency management
5. Write unit tests for all functionality

## Implementation Details

- Use appropriate data structures for the task
- Prefer built-in functions and standard library modules when possible
- Follow the principle of "Explicit is better than implicit"
- Use context managers for resource management

## Example .cursorrules File

```
// Python - Rules for AI
// This file provides guidance for working with Python projects

// Project Structure
// - src/: Source code for the package
// - tests/: Test files
// - docs/: Documentation
// - requirements.txt: Project dependencies

// General Guidelines
// 1. Follow PEP 8 style guidelines
// 2. Use type hints for function parameters and return values
// 3. Write docstrings for all modules, classes, and functions
// 4. Use virtual environments for dependency management
// 5. Write unit tests for all functionality

// Code Style
// - Use 4 spaces for indentation
// - Limit line length to 88 characters (Black default)
// - Use snake_case for variables and functions
// - Use CamelCase for classes
// - Use UPPER_CASE for constants
// - Use descriptive variable names

// Documentation
// - Use Google-style or NumPy-style docstrings
// - Document parameters, return values, and exceptions
// - Include examples in docstrings for complex functions
// - Keep docstrings up-to-date with code changes

// Testing
// - Use pytest for unit testing
// - Aim for high test coverage
// - Use fixtures for test setup
// - Mock external dependencies
// - Test edge cases and error conditions

// Error Handling
// - Use specific exception types
// - Handle exceptions at the appropriate level
// - Provide helpful error messages
// - Use logging instead of print statements
// - Consider using a context manager for cleanup

// Performance Considerations
// - Use appropriate data structures for the task
// - Avoid unnecessary computation
// - Consider using generators for large datasets
// - Profile code to identify bottlenecks
// - Use built-in functions when possible
```

## How to Use

1. Copy the above `.cursorrules` content to a file named `.cursorrules` in the root of your repository.
2. Customize it to match your project's specific needs and conventions.
3. Commit the file to your repository.

The content of the `.cursorrules` file will be appended to the global "Rules for AI" settings in Cursor, providing project-specific guidance to Cursor AI.

## Benefits

- Helps Cursor AI understand Python best practices
- Provides context about code organization and style
- Guides Cursor AI to suggest Pythonic solutions
- Ensures consistent code style across the project
- Improves code generation and understanding for Python-specific patterns

## Additional Resources

- [PEP 8 Style Guide](https://peps.python.org/pep-0008/)
- [PEP 257 Docstring Conventions](https://peps.python.org/pep-0257/)
- [PEP 484 Type Hints](https://peps.python.org/pep-0484/)
- [Python Documentation](https://docs.python.org/3/)
- [Pytest Documentation](https://docs.pytest.org/) 