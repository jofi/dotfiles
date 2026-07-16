# wsqtool — WSQ ↔ raster conversion on macOS (Apple Silicon)

A small, reliable WSQ codec for biometrics work, wrapped as the `wsq2img` command.

## Usage

```bash
wsq2img in.wsq  out.png     # decode WSQ -> raster (PNG/BMP/JPG/TIF/...)
wsq2img in.png  out.wsq     # encode raster -> WSQ (converted to 8-bit grey)
```

Direction is inferred from the file extensions. Relative and absolute paths both work.

## Why it's built this way

WSQ (FBI Wavelet Scalar Quantization, the standard fingerprint codec) has two dead ends
on an Apple Silicon Mac, both verified 2026-07-16:

- **ImageMagick** ships no WSQ coder in any standard build — `magick in.wsq out.png` fails.
- The Python **`wsq`** package's native decompressor **segfaults on arm64**, even recompiled
  from source (the crash is in its vendored NBIS C code — not a numpy/Pillow issue).

The well-tested **x86_64** build of the same `wsq` package works fine, so this tool runs it
inside a small pinned `linux/amd64` Docker image under Docker Desktop's emulation. A single
decode is well under a second, so emulation cost is not noticeable for interactive use.

## What's installed

| Path | What |
|------|------|
| `~/.wsqtool/Dockerfile` | image definition (`python:3.11-slim` amd64 + `wsq==0.8` + `pillow`) |
| `~/.wsqtool/wsqconv.py` | the converter run inside the container |
| `~/.local/bin/wsq2img` | the wrapper command on your PATH |
| docker image `wsqtool:latest` | the built image |

## Rebuild after editing

```bash
cd ~/.wsqtool && docker build --platform linux/amd64 -t wsqtool:latest .
```

## Batch example

```bash
for f in *.wsq; do wsq2img "$f" "${f%.wsq}.png"; done
```

## Upgrade path (optional)

For a native, faster, encode-capable toolkit — and the full NIST fingerprint suite
(`dwsq`, `cwsq`, `mindtct`, `nfiq`, `bozorth3`) — NBIS can be built in a native `arm64`
Linux container instead of this emulated `amd64` Python image. Not done here because the
Python route is simpler and already reliable; worth it if WSQ throughput ever matters.
