import sys

try:
    with open("test_result.log", "r", encoding="utf-16le") as f:
        lines = f.readlines()
        for i, line in enumerate(lines[:100]):
            print(f"{i}: {repr(line)}")
except Exception as e:
    try:
        with open("test_result.log", "r", encoding="utf-8") as f:
            lines = f.readlines()
            for i, line in enumerate(lines[:100]):
                print(f"{i}: {repr(line)}")
    except Exception as e2:
        print(f"Error: {e}\n{e2}")
