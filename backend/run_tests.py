import pytest
import sys

if __name__ == "__main__":
    # Run pytest and capture output to stdout (which this script ensures is utf-8)
    sys.exit(pytest.main(["tests/unit/test_health_profile_flexibility.py", "-vv"]))
