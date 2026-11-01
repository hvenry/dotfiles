#!/usr/bin/env python3
"""Waybar custom module for one Hyprland workspace button.

Usage: workspace.py <id>

Prints one JSON line per state change ({"text", "class", "tooltip"}) for Waybar's
`return-type: json`, driven by Hyprland's event socket (socket2), so the button
updates instantly without polling.

Waybar's built-in hyprland/workspaces module sends the legacy `dispatch workspace N`
syntax, which Hyprland rejects when it runs a Lua config. Clicks are handled by the
module's `on-click` with `hl.dsp.focus` instead; see docs/hyprland-desktop.md.
"""

import json
import os
import socket
import sys
import time

# Events that can change which workspace is active or occupied.
REFRESH_EVENTS = {
    "workspace",
    "workspacev2",
    "focusedmon",
    "focusedmonv2",
    "createworkspace",
    "createworkspacev2",
    "destroyworkspace",
    "destroyworkspacev2",
    "moveworkspace",
    "moveworkspacev2",
    "openwindow",
    "closewindow",
    "movewindow",
    "movewindowv2",
    "monitoradded",
    "monitoraddedv2",
    "monitorremoved",
    "monitorremovedv2",
}


def socket_dir() -> str:
    runtime = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    return os.path.join(runtime, "hypr", os.environ["HYPRLAND_INSTANCE_SIGNATURE"])


def request(command: str):
    """Send a JSON request over Hyprland's command socket (socket1)."""
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
        sock.connect(os.path.join(socket_dir(), ".socket.sock"))
        sock.sendall(f"j/{command}".encode())
        chunks = []
        while chunk := sock.recv(65536):
            chunks.append(chunk)
    return json.loads(b"".join(chunks))


def render(ws_id: int, urgent: bool) -> str:
    active = request("activeworkspace").get("id") == ws_id
    occupied = any(
        ws["id"] == ws_id and ws["windows"] > 0 for ws in request("workspaces")
    )
    classes = [
        c
        for c, on in (("active", active), ("occupied", occupied), ("urgent", urgent))
        if on
    ]
    return json.dumps(
        {
            "text": str(ws_id),
            "class": classes or ["empty"],
            "tooltip": f"Workspace {ws_id}",
        }
    )


def workspace_of_window(address: str):
    for client in request("clients"):
        if client["address"].removeprefix("0x") == address.removeprefix("0x"):
            return client["workspace"]["id"]
    return None


def run(ws_id: int) -> None:
    urgent = False
    last = None

    def emit():
        nonlocal last
        out = render(ws_id, urgent)
        if out != last:
            print(out, flush=True)
            last = out

    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as events:
        events.connect(os.path.join(socket_dir(), ".socket2.sock"))
        emit()
        buffer = b""
        while chunk := events.recv(4096):
            buffer += chunk
            *lines, buffer = buffer.split(b"\n")
            changed = False
            for line in lines:
                name, _, data = line.decode(errors="replace").partition(">>")
                if name == "urgent":
                    if workspace_of_window(data) == ws_id:
                        urgent = True
                        changed = True
                elif name in REFRESH_EVENTS:
                    changed = True
            if changed:
                if urgent and request("activeworkspace").get("id") == ws_id:
                    urgent = False
                emit()
    raise ConnectionError("Hyprland event socket closed")


def main() -> None:
    if len(sys.argv) != 2 or not sys.argv[1].isdigit():
        sys.exit("usage: workspace.py <id>")
    ws_id = int(sys.argv[1])
    # Survive Hyprland restarts and a socket that is not up yet when Waybar starts.
    while True:
        try:
            run(ws_id)
        except (OSError, ValueError, KeyError) as err:
            print(f"workspace.py {ws_id}: {err}", file=sys.stderr, flush=True)
            time.sleep(1)


if __name__ == "__main__":
    main()
