import cowsay

class Cow:
    def __init__(self, name):
        self.name = name

    def say_hello(self):
        cowsay.cow(f"hello py_image_layer! - {cowsay.__version__}")
