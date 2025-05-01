from pudb.remote import set_trace
import pytest
import sys

def test_pdb() -> None:

    a = 1
    print("before set trace")

    set_trace()

    print("after set_trace")
    a = 2

if __name__ == "__main__":
    sys.exit(pytest.main(sys.argv[1:]))
