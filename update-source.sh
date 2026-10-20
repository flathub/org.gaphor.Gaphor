#!/bin/bash

set -euo pipefail

VERSION=$1
MANIFEST=org.gaphor.Gaphor.yaml

if [[ ! "$VERSION" =~ ^[0-9]+(\.[0-9]+)+([a-zA-Z0-9.+-]*)$ ]]; then
	echo "Invalid Gaphor version: $VERSION" >&2
	exit 1
fi

COMMIT=$(git ls-remote --exit-code https://github.com/gaphor/gaphor.git "refs/tags/$VERSION" | cut -f1)

if [[ ! "$COMMIT" =~ ^[0-9a-f]{40}$ ]]; then
	echo "Could not resolve Gaphor $VERSION to a commit" >&2
	exit 1
fi

sed -i \
	-e "s/^        tag: .*/        tag: '$VERSION'/" \
	-e "s/^        commit: .*/        commit: '$COMMIT'/" \
	"$MANIFEST"

echo "Pinned Gaphor assets to $VERSION ($COMMIT)"
