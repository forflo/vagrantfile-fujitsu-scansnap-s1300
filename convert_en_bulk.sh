#!/usr/bin/env bash
# Dirty in-situ ad-hoc processing
# To be called from inside of this VM!
find /vagrant/scanout_raw -type f -name "*.png" \
    | parallel -j2 tesseract -l eng+deu {} {.} pdf
