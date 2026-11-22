"""tallyfile: count the words in a text file."""
import argparse
import collections
import re
import sys


def count_words(text):
    return collections.Counter(re.findall(r"[a-z']+", text.lower()))


def main(argv=None):
    parser = argparse.ArgumentParser(prog="tallyfile")
    parser.add_argument("file")
    args = parser.parse_args(argv)
    with open(args.file, encoding="utf-8") as handle:
        counts = count_words(handle.read())
    for word, number in sorted(counts.items(), key=lambda item: (-item[1], item[0])):
        print(f"{number}\t{word}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
