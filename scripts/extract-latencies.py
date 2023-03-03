#!/usr/bin/env python3

import re
import sys


def get_latency(path):
    # Iterate over the file and find the line that has "latency="
    with open(path) as f:
        for line in f:
            if "latency=" in line:
                # Look for /*latency=*/N where N is an integer
                latency = re.search(r"/\*latency=\*/(\d+)", line)
                return int(latency.group(1))


def main():
    # Map filename to latency
    filament = {}
    aetherling = {}
    # Accept a list of paths to files as arguments
    for path in sys.argv[1:]:
        latency = get_latency(path)
        # Strip the ".fil" extension
        path = path[:-4]
        # Get the name of the file and parent directory
        path = path.split("/")[-2:]
        if path[0] == "filament":
            filament[path[1]] = latency
        elif path[0] == "aetherling":
            aetherling[path[1]] = latency
        else:
            print("Unknown path: {}".format(path))

    # Join the two dictionaries based on the keys
    print("name,aetherling,filament")
    for key in filament:
        print("{},{},{}".format(key, aetherling[key], filament[key]))


if __name__ == "__main__":
    main()
