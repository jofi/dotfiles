# WSQ conversion tool. amd64 on purpose: the `wsq` wheel's decompressor
# segfaults on macOS/arm64, but the well-tested x86_64 build works under
# Docker's emulation. Pinned base + versions for reproducibility.
FROM --platform=linux/amd64 python:3.11-slim

RUN pip install --no-cache-dir "wsq==0.8" "pillow==11.*"

COPY wsqconv.py /usr/local/bin/wsqconv.py

WORKDIR /data
ENTRYPOINT ["python", "/usr/local/bin/wsqconv.py"]
