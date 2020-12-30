#!/bin/bash

source "$(cd $(dirname $0);pwd)/bash_template.sh"

mkdir -p "${TMP_DIR}"

i=0
for source_path in ${source_paths_array[@]}; do
    find "${source_path}" | { grep -e ".*.java" || true; } >> "${TMP_DIR}/lib_list${i}"
    i=$((++i))
done

i=0
for class_path in ${class_paths_array[@]}; do
    mkdir -p "${class_path}"
    if [ -s "${TMP_DIR}/lib_list${i}" ]; then
        javac -d "${class_path}" @${TMP_DIR}/lib_list${i}
    fi
    i=$((++i))
done

rm -r "${TMP_DIR}"