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

destination_dir="/vagrant/scanout_raw"
destination_dir_ocr="/vagrant/scanout_pdf"
raw_file_name="$filename.$format"
raw_scan_file="$destination_dir/$raw_file_name"
ocr_pdf_file="$destination_dir_ocr"/$filename

mkdir -p "$destination_dir_ocr" "$destination_dir"

echo [scanimage] --resolution "$resolution" \
    -p --brightness=0 \
    --threshold=170 --mode="$mode" \
    "$@" --format="$format" \
    \> "$raw_scan_file"

scanimage --resolution "$resolution" -p --brightness=0 \
    --page-width="$page_width" --page-height="$page_height" \
	--threshold=170 --mode="$mode" \
    "$@" --format="$format" \
	> "$raw_scan_file"
 
# copy over in order to tesseract ocr the image
echo cp "$raw_scan_file" "$destination_dir_ocr/$raw_file_name"
cp "$raw_scan_file" "$destination_dir_ocr/$raw_file_name"

if [ "$do_ocr" == "true" ]; then
    echo tesseract -l "$ocr_lang" "$raw_scan_file" "$ocr_pdf_file" pdf
    tesseract -l "$ocr_lang" "$raw_scan_file" "$ocr_pdf_file" pdf
fi


echo rm "$destination_dir_ocr/$raw_file_name"
rm "$destination_dir_ocr/$raw_file_name"
