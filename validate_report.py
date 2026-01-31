import json
import sys

def validate_report(filepath):
    try:
        with open(filepath, 'r') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON - {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error: Could not read file - {e}")
        sys.exit(1)

    if not isinstance(data, list):
        print("Error: Root element must be a JSON array.")
        sys.exit(1)

    if len(data) == 0:
        print("Report is empty (valid).")
        sys.exit(0)

    required_keys = {
        "title", "description", "deepLink", "filePath",
        "lineNumber", "confidence", "rationale", "context", "language"
    }

    for index, item in enumerate(data):
        if not isinstance(item, dict):
            print(f"Error: Item at index {index} is not an object.")
            sys.exit(1)

        keys = set(item.keys())
        missing = required_keys - keys
        if missing:
            print(f"Error: Item at index {index} missing keys: {missing}")
            sys.exit(1)

        if not isinstance(item.get("confidence"), int) or not (1 <= item["confidence"] <= 3):
            print(f"Error: Item at index {index} has invalid confidence score.")
            sys.exit(1)

        # Basic type checks for other fields
        string_fields = ["title", "description", "deepLink", "filePath", "rationale", "context", "language"]
        for field in string_fields:
            if not isinstance(item.get(field), str):
                print(f"Error: Item at index {index} field '{field}' is not a string.")
                sys.exit(1)

        if not isinstance(item.get("lineNumber"), int):
             print(f"Error: Item at index {index} field 'lineNumber' is not an integer.")
             sys.exit(1)

    print("Validation passed.")
    sys.exit(0)

if __name__ == "__main__":
    validate_report("todo_report.json")
