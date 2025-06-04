import greet


def test_greet_default():
    assert greet.greet("World") == "Hello, World!"


def test_greet_name():
    assert greet.greet("Alice") == "Hello, Alice!"
