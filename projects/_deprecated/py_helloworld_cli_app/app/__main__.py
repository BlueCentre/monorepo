from projects.py_helloworld_cli_app.app.cli import Helloworld

if __name__ == "__main__":
    app = Helloworld("John")
    app.say_hello()
