from projects.py_helloworld_v2_cli_app.app.cli import Helloworld

if __name__ == "__main__":
    app = Helloworld("Jane")
    app.say_hello()