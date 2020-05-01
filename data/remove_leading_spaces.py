#!/usr/bin/env python3

import argparse
import csv
import sys


def main(argv):
    parser = argparse.ArgumentParser(description='Remove leading spaces from CSV fields')
    parser.add_argument('csvfile')
    parser.add_argument('--write', '-w', action='store_true',
                        help='Write back to the original file')
    args = parser.parse_args(argv[1:])
    with open(args.csvfile, 'r', newline='') as f:
        # Detect dialect so that we can write back same dialect
        sample = f.read(4096)
        f.seek(0)
        dialect = csv.Sniffer().sniff(sample)
        if '\r' not in sample:
            # Sniffer doesn't seem to set the line terminator
            dialect.lineterminator = '\n'
        # Force initial spaces to be skipped, to erase them
        dialect.skipinitialspace = True
        lines = list(csv.reader(f, dialect))
    if args.write:
        with open(args.csvfile, 'w') as f:
            writer = csv.writer(f, dialect)
            for row in lines:
                writer.writerow(row)
    else:
        writer = csv.writer(sys.stdout, dialect)
        for row in lines:
            writer.writerow(row)


if __name__ == '__main__':
    main(sys.argv)
