#!/usr/bin/env bash
# Verifies exact ex06 stdout for every level, invalid and missing arguments.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! command -v python3 >/dev/null 2>&1; then
    printf '%s\n' 'FAIL: Python 3 is required for these tests (not for C++).'
    false
elif ! make -C "$ROOT" all >/dev/null; then
    printf '%s\n' 'FAIL: ex06 does not build.'
    false
else
    python3 - "$ROOT/harlFilter" <<'PY06'
import pathlib
import subprocess
import sys

binary = str(pathlib.Path(sys.argv[1]).resolve())
levels = ['DEBUG', 'INFO', 'WARNING', 'ERROR']
blocks = {
    'DEBUG': '[ DEBUG ]\nI love having extra bacon for my 7XL-double-cheese-triple-pickle-special-ketchup burger. I really do!\n\n',
    'INFO': "[ INFO ]\nI cannot believe adding extra bacon costs more money. You didn't put enough bacon in my burger! If you did, I wouldn't be asking for more!\n\n",
    'WARNING': "[ WARNING ]\nI think I deserve to have some extra bacon for free.\nI've been coming for years, whereas you started working here just last month.\n\n",
    'ERROR': '[ ERROR ]\nThis is unacceptable! I want to speak to the manager now.\n\n',
}
invalid = '[ Probably complaining about insignificant problems ]\n'
usage = 'Usage: ./harlFilter <DEBUG|INFO|WARNING|ERROR>\n'
cases = [
    (['DEBUG'], ''.join(blocks[x] for x in levels), 0),
    (['INFO'], ''.join(blocks[x] for x in levels[1:]), 0),
    (['WARNING'], ''.join(blocks[x] for x in levels[2:]), 0),
    (['ERROR'], blocks['ERROR'], 0),
    (['INVALID'], invalid, 0),
    ([''], invalid, 0),
    (['warning'], invalid, 0),
    ([], usage, 1),
    (['INFO', 'ERROR'], usage, 1),
]
passed = 0
for arguments, expected, code in cases:
    p = subprocess.run([binary] + arguments, stdout=subprocess.PIPE,
                       stderr=subprocess.PIPE, timeout=5)
    if p.returncode == code and p.stdout == expected.encode('utf-8') and not p.stderr:
        passed += 1
    else:
        print('FAIL ex06 args=%r return=%d stderr=%r' % (arguments, p.returncode, p.stderr))
print('ex06 exact-output tests: %d/%d passed' % (passed, len(cases)))
if passed != len(cases):
    raise AssertionError('ex06 TESTS FAILED')
print('ex06: PASS')
PY06
fi
