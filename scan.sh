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
raw_file_name_front="${filename}_1.$format"
raw_file_name_back="${filename}_2.$format"

ocr_pdf_file_name_front="${filename}_1"
ocr_pdf_file_name_back="${filename}_2"

mkdir -p "$destination_dir_ocr" "$destination_dir_raw"

function do_scan() (
    cd
    rm -f *."$format"
    rm -f *.pdf
    scanimage --resolution "$resolution" -p --brightness=0 \
              --batch="${filename}_%d.$format" \
              -d 'epjitsu:libusb:001:002' \
              --page-width="$page_width" \
              --page-height="$page_height" \
              --source="ADF Duplex" \
              --threshold=170 --mode="$mode" \
              "$@" --format="$format" || return 1

    local count=1
    for i in "${filename}_"*."$format"; do
        if [ "$do_ocr" == "true" ]; then
            echo Start tesseract job $count with file $i
            tesseract -l "$ocr_lang" "$i" "$destination_dir_ocr/${filename}_$count" pdf
        fi
        ((count++))
    done
    wait

    for i in "${filename}_"*."$format"; do
        mv "$i" "$destination_dir_raw"
    done

    return 0
)


do_scan || exit 1

# echo rm "$destination_dir_ocr/$raw_file_name"
# rm "$destination_dir_ocr/$raw_file_name"
