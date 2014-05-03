#! /bin/bash

set -e
set -x

mkdir -p upload

ME=$(readlink -f "$0")
DIR=$(dirname "$ME")
MYDIR=$(cd "$DIR" && pwd)

for nb in [0-9]*/*ipynb; do
  echo "PROCESSING $nb"
  DIR="$(dirname "$nb")"

  CONV_DIR="upload/$DIR"
  mkdir -p "$CONV_DIR"
  CONV_BASE="upload/${nb%.ipynb}"
  CONV_PY="${CONV_BASE}.py"
  CONV_HTML="${CONV_BASE}.html"

  "$MYDIR/demo-ready-ipynb" --keep "$nb" "${CONV_BASE}.ipynb"
  if test "$nb" -nt "$CONV_PY"; then
    ipython nbconvert "$nb" --to=python "--output=${CONV_BASE}"
  fi
  if test "$nb" -nt "$CONV_HTML"; then
    ipython nbconvert "$nb" --to=html "--output=${CONV_BASE}"
  fi

  CONV_DIR="cleared/$DIR"
  mkdir -p "$CONV_DIR"
  CONV_IPYNB="cleared/$nb"
  "$MYDIR/demo-ready-ipynb" "$nb" "$CONV_IPYNB"
done
