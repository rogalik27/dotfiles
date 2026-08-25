#!/usr/bin/env python3
import subprocess, hashlib, sys, time

MAXLEN = 25
FRAMES = 3
FRAME_DELAY = 0.25
POS_FILE  = '/tmp/waybar_media_scroll_pos'
HASH_FILE = '/tmp/waybar_media_scroll_hash'

def get_info():
    try:
        r = subprocess.run(
            ['playerctl', 'metadata', '--format', '{{title}} – {{artist}}'],
            capture_output=True, text=True, timeout=1
        )
        return r.stdout.strip() or 'No player'
    except Exception:
        return 'No player'

def get_status():
    try:
        r = subprocess.run(['playerctl', 'status'], capture_output=True, text=True, timeout=1)
        return r.stdout.strip()
    except Exception:
        return ''

info = get_info()
status = get_status()
h = hashlib.md5(info.encode()).hexdigest()[:8]

try:
    last_hash = open(HASH_FILE).read().strip()
except Exception:
    last_hash = ''

if h != last_hash:
    open(HASH_FILE, 'w').write(h)
    open(POS_FILE,  'w').write('0')
    pos = 0
else:
    try:
        pos = int(open(POS_FILE).read().strip())
    except Exception:
        pos = 0

if len(info) <= MAXLEN:
    print(f'{info:<{MAXLEN}}', flush=True)
    sys.exit(0)

padded = info + '   '
n = len(padded)

for i in range(FRAMES):
    end = pos + MAXLEN
    if end <= n:
        print(padded[pos:end], flush=True)
    else:
        part = padded[pos:]
        print(part + padded[:MAXLEN - len(part)], flush=True)

    if status == 'Playing':
        pos = (pos + 1) % n

    if i < FRAMES - 1:
        time.sleep(FRAME_DELAY)

open(POS_FILE, 'w').write(str(pos))
