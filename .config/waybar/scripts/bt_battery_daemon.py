#!/usr/bin/env python3
"""
Passive BLE D-Bus daemon for waybar AirPods battery.
Uses BlueZ SetDiscoveryFilter(Transport=le) — passive scan, no active requests,
no interference with other BT apps or device switching.
Parses AirPods advertisement data using AirStatus byte offsets.
Writes /tmp/airstatus.out in AirStatus-compatible JSON format.
Signals waybar RTMIN+9 on update.
"""
import dbus, dbus.mainloop.glib, json, subprocess, time, sys
from binascii import hexlify
from gi.repository import GLib

OUTPUT_FILE        = '/tmp/airstatus.out'
APPLE_ID           = 0x004C
AIRPODS_DATA_LEN   = 54   # hex chars = 27 bytes
SIGNAL_COOLDOWN    = 3.0  # min seconds between waybar signals

_last_signal = 0.0


# --- AirStatus-compatible parsing (nibble indices on hex string) ---

def airstatus_parse(raw_bytes):
    """Parse AirPods proximity pairing payload. raw_bytes is bytes of length 27."""
    raw = hexlify(raw_bytes)          # 54-char bytes object, e.g. b'07190113...'
    if len(raw) != AIRPODS_DATA_LEN:
        return None
    if raw[0:4] != b'0719':           # must be proximity pairing message
        return None

    flip = (int(chr(raw[10]), 16) & 0x02) == 0

    def charge(nibble_char):
        n = int(chr(nibble_char), 16)
        if n == 10:   return 100
        if n <= 10:   return n * 10 + 5
        return -1     # unavailable / in case

    left  = charge(raw[12 if flip else 13])
    right = charge(raw[13 if flip else 12])
    case  = charge(raw[15])

    cs = int(chr(raw[14]), 16)
    charging_left  = bool(cs & (0x02 if flip else 0x01))
    charging_right = bool(cs & (0x01 if flip else 0x02))
    charging_case  = bool(cs & 0x04)

    model_char = chr(raw[7])
    model = {'e': 'AirPodsPro', '3': 'AirPods3', 'f': 'AirPods2',
             '2': 'AirPods1',   'a': 'AirPodsMax'}.get(model_char, 'unknown')

    return dict(
        status=1,
        charge=dict(left=left, right=right, case=case),
        charging_left=charging_left,
        charging_right=charging_right,
        charging_case=charging_case,
        model=model,
        date=time.strftime('%Y-%m-%d %H:%M:%S'),
        raw=raw.decode(),
    )


def write_output(data):
    try:
        with open(OUTPUT_FILE, 'w') as f:
            json.dump(data, f)
            f.write('\n')
    except Exception:
        pass


def signal_waybar():
    global _last_signal
    now = time.time()
    if now - _last_signal < SIGNAL_COOLDOWN:
        return
    _last_signal = now
    subprocess.run(['pkill', '-RTMIN+9', 'waybar'], capture_output=True)


def on_properties_changed(interface, changed, invalidated, path=None):
    if interface != 'org.bluez.Device1':
        return

    if 'Connected' in changed:
        signal_waybar()

    if 'ManufacturerData' not in changed:
        return

    try:
        mfr = {int(k): bytes(v) for k, v in changed['ManufacturerData'].items()}
        if APPLE_ID not in mfr:
            return
        result = airstatus_parse(mfr[APPLE_ID])
        if result:
            write_output(result)
            signal_waybar()
    except Exception:
        pass


def on_interfaces_changed(path, interfaces):
    if 'org.bluez.Device1' in interfaces:
        signal_waybar()


dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
bus = dbus.SystemBus()

bus.add_signal_receiver(
    on_properties_changed,
    dbus_interface='org.freedesktop.DBus.Properties',
    signal_name='PropertiesChanged',
    arg0='org.bluez.Device1',
    path_keyword='path',
)
bus.add_signal_receiver(on_interfaces_changed, signal_name='InterfacesAdded',
                        dbus_interface='org.freedesktop.DBus.ObjectManager', bus_name='org.bluez')
bus.add_signal_receiver(on_interfaces_changed, signal_name='InterfacesRemoved',
                        dbus_interface='org.freedesktop.DBus.ObjectManager', bus_name='org.bluez')

try:
    adapter = dbus.Interface(
        bus.get_object('org.bluez', '/org/bluez/hci0'), 'org.bluez.Adapter1')
    adapter.SetDiscoveryFilter(dbus.Dictionary(
        {'Transport': dbus.String('le'), 'DuplicateData': dbus.Boolean(True)},
        signature='sv'))
    adapter.StartDiscovery()
except Exception as e:
    print(f'Warning: could not start LE scan: {e}', file=sys.stderr)

loop = GLib.MainLoop()
try:
    loop.run()
finally:
    try:
        adapter.StopDiscovery()
    except Exception:
        pass
