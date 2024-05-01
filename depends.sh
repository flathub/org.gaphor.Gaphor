#!/bin/bash

set -euo pipefail

GAPHOR_VERSION=${1}

BUILD=build/pip

mkdir -p ${BUILD}
pip3 download -q --dest ${BUILD} --extra-index-url https://pypi.org/simple  gaphor=="${GAPHOR_VERSION}"

# Generate stubs for any binary installation file
for FILE in ${BUILD}/*manylinux*
do
  touch "$(echo $FILE | cut -d- -f1,2)-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
  touch "$(echo $FILE | cut -d- -f1,2)-cp311-cp311-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
done

cat << EOF
name: gaphor-bin
buildsystem: simple
build-commands:
  - pip3 install --no-index --find-links="file://\${PWD}" --prefix=\${FLATPAK_DEST} gaphor
sources:
EOF

find ${BUILD} -type f -printf '%P\n' | awk -F- '{ print $1 " " $0 }' | \
while read -r DEP FILE
do
  curl -sSfL https://pypi.org/pypi/"${DEP}"/json | jq -r '.releases[][] |
    select(.filename == "'"${FILE}"'") | "\(.digests.sha256) \(.url)"'
done | \
while read -r SHA URL
do
	echo "  - type: file"
	echo "    url: ${URL}"
	echo "    sha256: ${SHA}"
done
