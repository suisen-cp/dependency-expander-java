#!/bin/bash

EXPANDER_DIR=$(cd $(dirname $0);cd ../;pwd)

DEP_DIR="${EXPANDER_DIR}/dependency_data"
TMP_DIR="${EXPANDER_DIR}/tmp"
OUT_DIR="${EXPANDER_DIR}/out"
SRC_DIR="${EXPANDER_DIR}/src"

# --------------- edit here ------------------ #
source_paths="test/lib1/src:test/lib2/src:test/lib3/src"
class_paths="test/lib1/classes:test/lib2/classes:test/lib3/classes"
