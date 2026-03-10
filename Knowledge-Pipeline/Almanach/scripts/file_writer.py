import sys
target=sys.argv[1]
with open(target, "w") as out:
    out.write(sys.stdin.read())