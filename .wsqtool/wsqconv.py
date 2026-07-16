#!/usr/bin/env python3
"""Convert between WSQ and standard raster formats using the `wsq` PIL plugin.

Direction is inferred from file extensions:
  - <in>.wsq  -> <out>.(png|bmp|jpg|tif...)   decode  (WSQ -> raster)
  - <in>.(png|bmp|...) -> <out>.wsq           encode  (raster -> WSQ, 8-bit grey)

Runs inside the amd64 `wsqtool` container (the wsq wheel segfaults on macOS/arm64),
so paths given here are container paths (/data/...); the wrapper maps your cwd to /data.
"""
import sys
from PIL import Image
import wsq  # noqa: F401  — registers the WSQ codec with PIL on import


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print("usage: wsqconv.py <input> <output>", file=sys.stderr)
        return 2
    src, dst = argv[1], argv[2]
    encoding_wsq = dst.lower().endswith(".wsq")

    im = Image.open(src)
    im.load()  # force decode now so failures surface here, not at save
    if encoding_wsq:
        im = im.convert("L")  # WSQ is single-channel 8-bit greyscale
    im.save(dst)

    print(f"{src} {im.size} {im.mode} -> {dst}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
