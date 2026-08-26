import re
range_match = re.match(r"bytes=(\d+)-(\d*)", "bytes=0-")
if range_match:
    print(f"group1: {range_match.group(1)}")
    print(f"group2: '{range_match.group(2)}'")
    end = int(range_match.group(2)) if range_match.group(2) else 100 - 1
    print(f"end: {end}")
