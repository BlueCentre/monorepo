from projects.py.helloworld_py_app.app.cli import Helloworld

if __name__ == "__main__":
    app = Helloworld("Jane")
    app.say_hello()
