#!/usr/bin/env python3

import argparse
import csv
import sys


SUFFIXES = ['WC', 'NC', 'EC', 'GP', 'KZN', 'MP', 'FS', 'LP', 'NW']
PROVINCE_MAP = {
    'Western Cape': 'ZA-WC',
    'Northern Cape': 'ZA-NC',
    'Eastern Cape': 'ZA-EC',
    'Gauteng': 'ZA-GP',
    'KwaZuluNatal': 'ZA-KZN',
    'KwaZulu Natal': 'ZA-KZN',
    'Kwazulu-Natal': 'ZA-KZN',
    'Mpumalanga': 'ZA-MP',
    'Free State': 'ZA-FS',
    'Limpopo': 'ZA-LP',
    'North-West': 'ZA-NW',
    'North West': 'ZA-NW',
    'UNK': '',
    '': ''
}
for suffix in SUFFIXES:
    PROVINCE_MAP[suffix] = f'ZA-{suffix}'
    PROVINCE_MAP[f'ZA-{suffix}'] = f'ZA-{suffix}'


def write(f, header, rows, dialect):
    writer = csv.DictWriter(f, header, dialect=dialect)
    writer.writeheader()
    for row in rows:
        writer.writerow(row)


def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument('csvfile')
    parser.add_argument('--old-column', default='province',
                        help='Column from which to get province data [%(default)s]')
    parser.add_argument('--new-column', default='geo_subdivision',
                        help='New column name to add [%(default)s]')
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
        # DictReader doesn't provide a trivial way to get the header row (you
        # have to read the first row of data), so get it manually.
        reader = csv.reader(f, dialect=dialect)
        header = next(reader)
        if args.old_column not in header:
            raise RuntimeError(f'Column {args.old_column} not found')
        if args.new_column in header:
            raise RuntimeError(f'Column {args.new_column} is already present')
        new_header = header + [args.new_column]
        new_rows = []
        reader = csv.DictReader(f, header)
        for i, row in enumerate(reader, 1):
            old = row[args.old_column]
            try:
                row[args.new_column] = PROVINCE_MAP[old]
            except KeyError:
                raise RuntimeError(f'{old!r} (row {i}) is not a recognised province') from None
            new_rows.append(row)

    if args.write:
        with open(args.csvfile, 'w') as f:
            write(f, new_header, new_rows, dialect)
    else:
        write(sys.stdout, new_header, new_rows, dialect)


if __name__ == '__main__':
    main(sys.argv)
