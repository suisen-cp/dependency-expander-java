#!/bin/bash

source "$(cd $(dirname $0);pwd)/bash_template.sh"

mkdir -p "${TMP_DIR}"

LIB_OBJ_PATH="${DEP_DIR}/lib_dep.txt.object"
STD_OBJ_PATH="${DEP_DIR}/std_dep.txt.object"
ALL_TMP_OUT="${TMP_DIR}/all_tmp"
LIB_TMP_OUT="${TMP_DIR}/lib_tmp"
STD_TMP_OUT="${TMP_DIR}/std_tmp"

if [ $# -lt 1 ]; then
    echo_colored "usage : expander.sh <source file> [destination file]" RED
    exit 1
fi

SRC_FILE=$1
DST_FILE="${2:-$(cd $(dirname $1);pwd)/Main.java}"

function rel_path() {
    realpath --relative-to="$(pwd)" "$1"
}

echo -n "source file: "
echo_colored "$(rel_path "${SRC_FILE}")" $MAGENTA
echo -n "destination file: "
echo_colored "$(rel_path "${DST_FILE}")" $MAGENTA

src_class_name=$(basename "${SRC_FILE}" | sed -e 's/\.java$//')
dst_class_name=$(basename "${DST_FILE}" | sed -e 's/\.java$//')

echo -n "compiling the source file..."
javac -d "${TMP_DIR}" -cp "${CLASS_PATH}" "${SRC_FILE}"
echo_ok

echo -n "getting direct dependencies..."
jdeps -v -cp "${CLASS_PATH}" "${TMP_DIR}" | sed '/^[^ ]/d' | sed -E 's/\$[^ ]+ //g' > "${ALL_TMP_OUT}"
echo_ok

echo -n "extracting direct lib dependencies..."
lib_deps=$(grep -v "java\.base" "${ALL_TMP_OUT}" | sed -E 's/[^ ]+$//' | sed -e 's/ *//g' -e '/^\(.*\)->\1$/d' -e 's/^.*->//' | sort | uniq)
echo_ok
echo_colored "${lib_deps}" $BLUE

echo -n "extracting direct std dependencies..."
std_deps=$(grep    "java\.base" "${ALL_TMP_OUT}" | sed -E 's/[^ ]+$//' | sed -e 's/ *//g' -e 's/^.*->//' | sort | uniq)
echo_ok
echo_colored "${std_deps}" $CYAN

echo -n "getting dependencies recursively..."
java -cp "${OUT_DIR}" Expander "${LIB_TMP_OUT}" "${STD_TMP_OUT}" "${lib_deps}" "${std_deps}" "${LIB_OBJ_PATH}" "${STD_OBJ_PATH}"
echo_ok

lib_deps_rec=$(cat ${LIB_TMP_OUT})
std_deps_rec=$(cat ${STD_TMP_OUT})
echo "lib dependencies:"
echo_colored "${lib_deps_rec}" $BLUE
echo "std dependencies:"
echo_colored "${std_deps_rec}" $CYAN

# remove lines starting with "package", "import"
# replace "class <class name>" with "<class Main>"
echo -n "processing the source file..."
content=$(\
    cat -s "${SRC_FILE}" |
    sed -e '/^package/d' -e '/^import/d' | sed -zE "s/class[ \r\n\t]+${src_class_name}([^a-zA-Z0-9])/class ${dst_class_name}\1/")
echo_ok

echo -n "generating import statements..."
imports=$(cat "${STD_TMP_OUT}" | sed -e 's/^/import /' -e 's/$/;/')
echo_ok

echo -n "inserting import statements..."
{
    echo "${imports}"
    echo ""
    echo "${content}"
} > "${DST_FILE}"
echo_ok

echo "expanding libraries..."
cat ${LIB_TMP_OUT} | sed 's;\.;/;g' | while read -r line ; do
    if [ -n "${line}" ]; then
        echo -n "path: "
        echo -en "\033[0;${BLUE}m${SOURCE_PATH}/${line}\033[0;39m..."
        cat "${SOURCE_PATH}/${line}.java" | sed -e '/^package/d' -e '/^import/d' -e 's/^public //' >> "${DST_FILE}"
        echo_ok
    fi
done

echo -n "cleaning..."
rm -r "${TMP_DIR}"
echo_ok
