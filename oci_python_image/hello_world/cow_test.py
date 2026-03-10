from hello_world.app import Cow


def test_cow_stores_name():
    cow = Cow("Bessie")
    assert cow.name == "Bessie"


def test_cow_name_is_string():
    cow = Cow("Daisy")
    assert isinstance(cow.name, str)


def test_cow_different_names():
    cow1 = Cow("Alice")
    cow2 = Cow("Bob")
    assert cow1.name != cow2.name
