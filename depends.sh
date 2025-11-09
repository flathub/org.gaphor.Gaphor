#!/bin/bash

set -euo pipefail

GAPHOR_VERSION=${1}

BUILD=build/pip

mkdir -p ${BUILD}
pip3 download -q --no-binary dulwich --no-binary pillow --dest ${BUILD} --extra-index-url https://pypi.org/simple  gaphor=="${GAPHOR_VERSION}" setuptools_rust wheel pybind11

cat << EOF
name: gaphor-bin
buildsystem: simple
build-commands:
  - pip3 install --no-index --no-cache-dir --find-links="file://\${PWD}" setuptools_rust wheel
  - pip3 install --no-index --no-cache-dir --find-links="file://\${PWD}" --prefix=\${FLATPAK_DEST} gaphor
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

GRAPHVIZ_TAG=$(curl -sSfL "https://gitlab.com/api/v4/projects/4207231/repository/tags?per_page=10" | jq -r '.[] | select(.name | test("^[0-9]+\\.[0-9]+\\.[0-9]+$")) | .name' | head -1)
GRAPHVIZ_VERSION=${GRAPHVIZ_TAG:-14.0.2}
GRAPHVIZ_SHA256_URL="https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/${GRAPHVIZ_VERSION}/graphviz-${GRAPHVIZ_VERSION}.tar.xz.sha256"

GRAPHVIZ_SHA256=$(curl -sSfL "${GRAPHVIZ_SHA256_URL}" | cut -d' ' -f1)

if [ -n "${GRAPHVIZ_SHA256}" ]; then
	OLD_VERSION=$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+' graphviz.yaml | head -1)
	
	sed -i \
		-e "s/${OLD_VERSION}/${GRAPHVIZ_VERSION}/g" \
		-e "s/sha256: [a-f0-9]*/sha256: ${GRAPHVIZ_SHA256}/" \
		graphviz.yaml
else
	echo "Warning: Could not fetch graphviz SHA256 for version ${GRAPHVIZ_VERSION}, keeping existing version" >&2
fi
