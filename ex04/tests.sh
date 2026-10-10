#!/usr/bin/env bash
# Test driver: 100 positive byte-for-byte tests plus invalid inputs.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! command -v python3 >/dev/null 2>&1; then
    printf '%s\n' 'FAIL: Python 3 is required for these tests (not for the C++ solution).'
    false
elif ! make -C "$ROOT" all >/dev/null; then
    printf '%s\n' 'FAIL: ex04 does not build.'
    false
else
    python3 - "$ROOT/replace" <<'PY04'
import pathlib
import random
import subprocess
import sys
import tempfile

binary = str(pathlib.Path(sys.argv[1]).resolve())
cases = [
    (b'Hello world\nHello again\n', b'Hello', b'Bonjour'),
    (b'ABC\nDEF\n', b'C\nD', b'Z'),
    (b'A\nB\n', b'\n', b' / '),
    (b'aaaaa', b'aa', b'X'),
    (b'aaaaaa', b'aaa', b'X'),
    (b'nothing matches', b'xyz', b'Z'),
    (b'', b'a', b'b'),
    (b'abc', b'abc', b''),
    (b'abcabc', b'a', b'aa'),
    (b'a\r\nb\r\n', b'\r\n', b'\n'),
    (b'ab\x00cd\x00ef', b'cd', b'XY'),
    ('سلام دنیا سلام'.encode('utf-8'), 'سلام'.encode('utf-8'), 'درود'.encode('utf-8')),
    (b'.*?[a-z]+', b'.*?', b'_'),
    (b'$HOME $(pwd) * ? [abc]', b'$', b'@'),
    (b' spaces  and\ttabs\t', b' ', b''),
    (b'\n\n\n', b'\n\n', b'!'),
    (b'ABCDEF', b'ABCDEF', b'Q'),
    (b'one line without newline', b'line', b'LINE'),
    (b'\x00\x01\x02\x03\x00', b'\x01\x02', b'\xff'),
    (b'abc\nabc\n', b'abc\n', b'line\n'),
]
needles = [b'a', b'ab', b'aba', b'\n', b'\r\n', b'X Y', b'00', b'\t', b'<>', b'hello']
repls = [b'', b'Z', b'NEW', b'aaa', b'\n', b'\r\n', b'\x01', b'XYZXYZ', b'$', b'\xff']
alphabet = b'aabbbcXYZ 001\n\r\t<>$!\x00'
for i in range(80):
    rng = random.Random(42001 + i)
    needle = needles[i % len(needles)]
    replacement = repls[(i * 7) % len(repls)]
    prefix = bytes(rng.choice(alphabet) for _ in range(i % 39))
    suffix = bytes(rng.choice(alphabet) for _ in range((i * 3) % 41))
    content = prefix + (needle + prefix + needle) * (i % 5 + 1) + suffix
    cases.append((content, needle, replacement))

passed = 0
with tempfile.TemporaryDirectory(prefix='cpp01-ex04-') as temp:
    root = pathlib.Path(temp)
    for n, (content, old, new) in enumerate(cases, 1):
        source = root / ('input-%03d' % n)
        destination = pathlib.Path(str(source) + '.replace')
        source.write_bytes(content)
        try:
            process = subprocess.run([binary, str(source), old, new],
                                     stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                     timeout=10)
            good = (process.returncode == 0 and destination.exists()
                    and destination.read_bytes() == content.replace(old, new)
                    and source.read_bytes() == content and process.stderr == b'')
        except (OSError, subprocess.TimeoutExpired) as exc:
            good = False
            print('  Error in test %d: %s' % (n, exc))
        if good:
            passed += 1
        else:
            print('  FAIL case %d: old=%r new=%r' % (n, old, new))

    invalid_checks = []
    def is_rejected(arguments):
        p = subprocess.run([binary] + arguments, stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE, timeout=10)
        return p.returncode != 0
    invalid_checks.append(is_rejected([]))
    invalid_checks.append(is_rejected(['too-few']))
    invalid_checks.append(is_rejected([str(root / 'missing'), 'a', 'b']))
    empty_path = root / 'empty-needle'
    empty_path.write_bytes(b'unchanged')
    invalid_checks.append(is_rejected([str(empty_path), '', 'B'])
                          and not pathlib.Path(str(empty_path) + '.replace').exists())

print('ex04 replacement tests: %d/100 passed' % passed)
print('ex04 invalid-input tests: %d/4 passed' % sum(invalid_checks))
if passed != 100 or not all(invalid_checks):
    raise AssertionError('ex04 TESTS FAILED')
print('ex04: PASS')
PY04
fi
