import importlib

from libs.py.calculator.models.calculator import Calculator


def test_add_simple() -> None:  # noqa: ANN201
    c = Calculator()
    assert c.add(2, 3) == 5  # noqa: S101


def test_module_import() -> None:  # noqa: ANN201
    # Ensure the app module imports without side effects raising errors
    module_path = "projects.py.calculator_flask_app.app.app".replace("/", ".")
    mod = importlib.import_module(module_path)
    assert hasattr(mod, "CalculatorHandler")  # noqa: S101
