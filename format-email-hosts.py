#!/usr/bin/env python3

from pathlib import Path


INPUT_FILE = Path("email-domains.txt")
OUTPUT_FILE = Path("formatted-email-hosts.txt")


def main() -> None:
    if not INPUT_FILE.exists():
        raise FileNotFoundError(f"Input file not found: {INPUT_FILE}")

    values = [line.strip() for line in INPUT_FILE.read_text().splitlines()]
    values = [value for value in values if value]

    formatted = " | ".join(f'("{value}")' for value in values)

    if not formatted:
        print("No nonblank lines found in email-domains.txt. Writing empty output.")

    print(formatted)
    OUTPUT_FILE.write_text(formatted)


if __name__ == "__main__":
    main()
