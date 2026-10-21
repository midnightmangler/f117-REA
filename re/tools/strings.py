"""Extract printable ASCII strings (len>=4) with file offsets.
usage: py -3 strings.py FILE [minlen]
"""
import re, sys

data = open(sys.argv[1], 'rb').read()
n = int(sys.argv[2]) if len(sys.argv) > 2 else 4
for m in re.finditer(rb'[\x20-\x7e\r\n\t]{%d,}' % n, data):
    s = m.group().decode('ascii').replace('\r', '\\r').replace('\n', '\\n').replace('\t', '\\t')
    print('%06X %s' % (m.start(), s))
