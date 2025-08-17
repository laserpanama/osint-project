import yaml
import sys
import os

# This script parses the subject.yml file and prints the configuration
# in a format that can be easily sourced by a bash script.

CONFIG_FILE = 'subject.yml'

def main():
    if not os.path.exists(CONFIG_FILE):
        print(f"Error: Configuration file '{CONFIG_FILE}' not found.", file=sys.stderr)
        print("Please copy 'subject.yml.example' to 'subject.yml' and configure it.", file=sys.stderr)
        sys.exit(1)

    try:
        with open(CONFIG_FILE, 'r') as f:
            config = yaml.safe_load(f)
    except Exception as e:
        print(f"Error parsing YAML file '{CONFIG_FILE}': {e}", file=sys.stderr)
        sys.exit(1)

    # --- Export tool configurations ---
    tool_config = config.get('tool_config', {})
    print(f"export RUN_SHERLOCK={str(tool_config.get('sherlock', False)).lower()}")
    print(f"export RUN_MAIGRET={str(tool_config.get('maigret', False)).lower()}")
    print(f"export RUN_EXIFTOOL={str(tool_config.get('exiftool', False)).lower()}")

    # --- Export subject data ---
    subject_data = config.get('subject_data', {})

    # Export usernames as a space-separated string
    usernames = subject_data.get('usernames', [])
    if usernames:
        # Quote the string to handle potential spaces or special characters in a single variable
        print(f"export USERNAMES=\"{' '.join(usernames)}\"")
    else:
        print("export USERNAMES=\"\"")

    # For now, we only need usernames for the script.
    # Other data is for documentation or future tools.
    full_name = subject_data.get('full_name', 'UnknownSubject')
    # Sanitize full_name to be used in a directory name
    safe_name = "".join(c if c.isalnum() else "_" for c in full_name)
    print(f"export SUBJECT_NAME=\"{safe_name}\"")


if __name__ == "__main__":
    main()
