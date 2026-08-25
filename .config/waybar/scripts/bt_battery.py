#!/usr/bin/env python3
"""
Waybar Bluetooth battery module.
AirPods: reads from /tmp/airstatus.out (written by airstatus.service).
Other devices: reads BlueZ Battery1.
"""
import dbus, json, sys

AIRSTATUS_FILE = '/tmp/airstatus.out'

ICONS = {
    'airpods':   '󰋋',
    'headphones':'󰋋',
    'mouse':     '󰍽',
    'keyboard':  '󰌌',
    'unknown':   '󰂯',
}

def device_type(name, dev_class, icon_hint):
    n = name.lower()
    if 'airpod' in n:
        return 'airpods'
    if icon_hint in ('audio-headset', 'audio-headphones'):
        return 'headphones'
    for k in ('headphone','headset','earphone','earbud','buds','wh-','wf-','bose','jabra','sennheiser','beats'):
        if k in n: return 'headphones'
    for k in ('mouse','mx master','mx anywhere','lift'):
        if k in n: return 'mouse'
    for k in ('keyboard','keychron'):
        if k in n: return 'keyboard'
    if dev_class:
        major = (int(dev_class) >> 8) & 0x1F
        if major == 4: return 'headphones'
        if major == 5:
            minor = (int(dev_class) >> 2) & 0x3F
            if minor & 0x10: return 'keyboard'
            if minor & 0x08: return 'mouse'
    return 'unknown'

def read_airstatus():
    try:
        import os, time
        if time.time() - os.path.getmtime(AIRSTATUS_FILE) > 30:
            return None  # stale
        with open(AIRSTATUS_FILE) as f:
            return json.loads(f.read().strip())
    except Exception:
        return None

try:
    bus  = dbus.SystemBus()
    mgr  = dbus.Interface(bus.get_object('org.bluez', '/'), 'org.freedesktop.DBus.ObjectManager')
    objs = mgr.GetManagedObjects()

    bat1 = {str(p): int(i['org.bluez.Battery1']['Percentage'])
            for p, i in objs.items() if 'org.bluez.Battery1' in i}

    connected = [(str(p), dict(i['org.bluez.Device1']))
                 for p, i in objs.items()
                 if 'org.bluez.Device1' in i and i['org.bluez.Device1'].get('Connected', False)]

    if not connected:
        print(json.dumps({'text': '', 'tooltip': ''}))
        sys.exit(0)

    airstatus = read_airstatus()
    parts, tooltips = [], []

    for dev_path, dev in connected:
        name  = str(dev.get('Name', 'Unknown'))
        dtype = device_type(name, dev.get('Class'), str(dev.get('Icon', '')))
        icon  = ICONS[dtype]

        if dtype == 'airpods':
            if airstatus and airstatus.get('status') == 1:
                ch  = airstatus['charge']
                L, R, C = ch.get('left', -1), ch.get('right', -1), ch.get('case', -1)
                cl, cr = airstatus.get('charging_left', False), airstatus.get('charging_right', False)
                def fmt(pct, charging):
                    s = f'{pct}%' if pct >= 0 else '--'
                    return f"<span color='#666666'>{s}</span>" if charging else s
                l_s = f'{L}%' if L >= 0 else '--'
                r_s = f'{R}%' if R >= 0 else '--'
                label = f'{icon} {fmt(L, cl)} {fmt(R, cr)}' + (f' C:{C}%' if C >= 0 else '')
                tip   = f'{name}\nL: {l_s}{"  charging" if cl else ""}  R: {r_s}{"  charging" if cr else ""}' + (f'  Case: {C}%' if C >= 0 else '')
            else:
                label = f'{icon} -- --'
                tip   = f'{name}: waiting for AirStatus data...'
        else:
            b     = bat1.get(dev_path)
            label = f'{icon} {b}%' if b is not None else icon
            tip   = f'{name}: {b}%' if b is not None else name

        parts.append(label)
        tooltips.append(tip)

    print(json.dumps({'text': '  '.join(parts), 'tooltip': '\n\n'.join(tooltips)}))

except Exception as e:
    print(json.dumps({'text': '', 'tooltip': str(e)}))
