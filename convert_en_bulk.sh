#!/usr/bin/env bash
# dirty in-situ ad-hoc processing
find /vagrant/scanout_raw -type f -name "*.png" \
    | parallel -j2 tesseract -l eng+deu {} {.} pdf
