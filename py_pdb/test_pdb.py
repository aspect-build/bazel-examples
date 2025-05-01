import pdb
import pytest
import sys

def test_pdb() -> None:

    a = 1
    print("before set trace")

    pdb.set_trace()

    print("after set_trace")
    a = 2

if __name__ == "__main__":
    sys.exit(pytest.main(sys.argv[1:]))
