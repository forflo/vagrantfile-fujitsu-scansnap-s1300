#!/usr/bin/env bash

##
# TODO:
# - one new directory per $today_str
#   - all scans of that day go into that directory
# - no stupid pmocr.sh
#   - i only need to chain scanimage and tesseract together
# - provide batch mode (scanimage runs as long as there are sheets)
#   - pipe trick for tesseract!
#   - file name handling (!, scanimage's defaults are out1,out2, ...)
##

filename="$1"
format="png"
resolution="300dpi"
mode="gray"
ocr_lang="deu+eng"
do_ocr="true"

# DIN A4
page_width="210"
page_height="297"

today_str="$(TZ="Europe/Berlin" date "+%F-%H-%M-%S")"

while [ "${1:-}" != "" ]; do
  case "$1" in
    "--format")
        shift
        format="$1"
        ;;
    "--filename")
        shift
        filename="${1}"
        ;;
    "--no-ocr")
        shift
        do_ocr="false"
        ;;
    "--resolution")
        shift
        resolution="$1"
        ;;
    "--ocr-lang")
        shift
        ocr_lang="$1"
        ;;
    "--mode")
        shift
        mode="$1"
        ;;
    "--")
        shift
        break;
        ;;
  esac
  shift
done

filename="${filename}_${today_str}"

destination_dir_raw="/vagrant/scanout_raw"
destination_dir_ocr="/vagrant/scanout_pdf"

mkdir -p "$destination_dir_ocr" "$destination_dir_raw"

function mk_scandir() (
    cd
    mkdir -p "$today_str"
    return 0
)

# $1: page suffix (front/back)
function do_scan() (
    cd "$today_str"
    local src="ADF Duplex"
    scanimage --resolution "$resolution" -p --brightness=0 \
              --batch="${filename}_%d.$format" \
              -d 'epjitsu:libusb:001:002' \
              --page-width="$page_width" \
              --page-height="$page_height" \
              --source="$src" \
              --threshold=170 --mode="$mode" \
              --format="$format" || return 1

    return 0
)

function do_ocr() (
    cd "$today_str"

    if [ "$do_ocr" == "true" ]; then
        # see https://github.com/tesseract-ocr/tesseract/issues/898#issuecomment-315202167
        export OMP_THREAD_LIMIT=1
        export OMP_NUM_THREADS=1
        find . -type f -name "${filename}_*.${format}" \
            | parallel -j4 tesseract -l "$ocr_lang" {} {.} pdf
    fi

    return 0
)

function move() (
    cd "$today_str"
    for i in "${filename}_"*."$format"; do
        mv "$i" "$destination_dir_raw"
    done
    for i in "${filename}_"*."pdf"; do
        mv "${i}" "$destination_dir_ocr"
    done
    return 0
)


mk_scandir
do_scan || exit 1
do_ocr || exit 1
move || exit 1

exit 0
