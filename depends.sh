#!/bin/bash

set -euo pipefail

GAPHOR_VERSION=${1}

BUILD=build/pip

mkdir -p ${BUILD}
pip3 download -q --dest ${BUILD}  gaphor==${GAPHOR_VERSION}

cat << EOF
name: gaphor-bin
buildsystem: simple
build-commands:
  - pip3 install --no-index --find-links="file://\${PWD}" --prefix=\${FLATPAK_DEST} gaphor
cleanup:
  - /share/man
sources:
EOF

ls ${BUILD} | awk -F- '{ print $1 " " $0 }' | \
while read DEP FILE
do
	curl -sSfL https://pypi.org/pypi/${DEP}/json | jq -r '.releases[][] | select(.filename == "'${FILE}'") | "\(.digests.sha256) \(.url)"'
done | \
while read SHA URL
do
	echo "  - type: file"
	echo "    url: ${URL}"
	echo "    sha256: ${SHA}"
done
