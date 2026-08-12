#!/usr/bin/env python3
"""Inject the VFB Google Analytics (gtag.js) snippet into CATMAID templates.

Run at container start by /opt/VFB/init.sh, only when ${GA_TAG_ID} is set.
The script is idempotent: it tags the injected block with a marker and
skips re-injection on rebuild or restart.

The live VFB site (virtualflybrain.org) uses a direct GA4 gtag.js install
with measurement ID G-K7DDZVVXM7, not a GTM container. This patch emits
the matching gtag.js snippet so CATMAID hits land in the same property.

Consent gating is *not* applied here: the live VFB site itself currently
fires gtag with anonymize_ip=false and no CMP. Compliance is the wider
Klaro rollout's job, not this image.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path

MARKER = "VFB-GA-INJECTED"

TEMPLATES = [
    Path("/home/django/applications/catmaid/templates/catmaid/index.html"),
    Path("/home/django/applications/catmaid/templates/catmaid/base.html"),
]


def head_snippet(ga_id: str) -> str:
    return (
        f"<!-- Google tag (gtag.js) (VFB) {MARKER} -->\n"
        f'<script async src="https://www.googletagmanager.com/gtag/js?id={ga_id}"></script>\n'
        "<script>\n"
        "  window.dataLayer = window.dataLayer || [];\n"
        "  function gtag(){dataLayer.push(arguments);}\n"
        "  gtag('js', new Date());\n"
        f"  gtag('config', '{ga_id}', {{ 'anonymize_ip': false }});\n"
        "</script>\n"
        "<!-- End Google tag (VFB) -->\n"
    )


def inject(path: Path, ga_id: str) -> str:
    if not path.is_file():
        return f"skip (missing): {path}"
    html = path.read_text()
    if MARKER in html:
        return f"skip (already injected): {path}"

    head_close = html.find("</head>")
    if head_close == -1:
        return f"skip (no </head>): {path}"
    html = html[:head_close] + head_snippet(ga_id) + html[head_close:]

    path.write_text(html)
    return f"injected: {path}"


def main() -> int:
    ga_id = os.environ.get("GA_TAG_ID", "").strip()
    if not ga_id:
        print("inject_ga: GA_TAG_ID not set, skipping")
        return 0
    # Defensive: GA4 measurement IDs are G-XXXXXXXXXX (alphanumeric/underscore).
    if not ga_id.startswith("G-") or not ga_id[2:].replace("_", "").isalnum():
        print(f"inject_ga: refusing suspicious GA_TAG_ID={ga_id!r}", file=sys.stderr)
        return 1
    for path in TEMPLATES:
        print(f"inject_ga: {inject(path, ga_id)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
