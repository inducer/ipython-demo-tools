#! /bin/zsh

set -e
set -x
setopt -o EXTENDED_GLOB

mkdir -p upload

ME=$(readlink -f "$0")
DIR=$(dirname "$ME")
MYDIR=$(cd "$DIR" && pwd)

for nb in [0-9]*/**/*ipynb; do
  echo "PROCESSING $nb"
  DIR="$(dirname "$nb")"

  CONV_DIR="upload/$DIR"
  mkdir -p "$CONV_DIR"
  CONV_BASE="upload/${nb%.ipynb}"
  CONV_PY="${CONV_BASE}.py"
  CONV_HTML="${CONV_BASE}.html"

  PROCESSED_IPYNB="${CONV_BASE}.ipynb"
  "$MYDIR/demo-ready-ipynb" --keep "$nb" "$PROCESSED_IPYNB"
  if ! test -f "$CONV_PY" || test "$nb" -nt "$CONV_PY"; then
    ipython nbconvert "$PROCESSED_IPYNB" --to=python "--output=${CONV_BASE}"
  fi
  if ! test -f "$CONV_HTML" || test "$nb" -nt "$CONV_HTML"; then
    ipython nbconvert "$PROCESSED_IPYNB" --to=html "--output=${CONV_BASE}"
  fi

  CONV_DIR="cleared/$DIR"
  mkdir -p "$CONV_DIR"
  CONV_IPYNB="cleared/$nb"
  "$MYDIR/demo-ready-ipynb" "$nb" "$CONV_IPYNB"
done
function mkdir_and_cp()
{
  dn=$(dirname "$2")
  mkdir -p "$dn"
  cp "$1" "$2"

}
for i in [0-9]*/**/*~*ipynb~*.pyc~*\~(#q.)(#qN); do
  mkdir_and_cp $i cleared/$i
  mkdir_and_cp $i upload/$i
done
