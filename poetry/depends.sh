#!/bin/bash

set -euo pipefail

POETRY_VERSION=1.0.3
mkdir -p build
pip3 download -q --dest build poetry==${POETRY_VERSION}

cat << EOF
name: python3-poetry
buildsystem: simple
build-commands:
  - pip3 install --no-index --find-links="file://\${PWD}" --prefix=\${FLATPAK_DEST}
    poetry
cleanup:
  - /bin
  - /share/man/man1
sources:
EOF

ls build | awk -F- '{ print $1 " " $0 }' | \
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
