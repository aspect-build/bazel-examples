import cowsay

class Cow:
    def __init__(self, name):
        self.name = name

    def say_hello(self):
        cowsay.cow("why is this slow?")
