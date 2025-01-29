from hello_world.app import Cow


def test_moo():
    app = Cow("John")
    app.say_hello()
