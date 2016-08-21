#! /bin/zsh

set -e
setopt -o EXTENDED_GLOB

function with_echo()
{
  echo "$@"
  "$@"
}

unset PYTHONWARNINGS

mkdir -p upload

ME=$(readlink -f "$0")
DIR=$(dirname "$ME")
MYDIR=$(cd "$DIR" && pwd)

for nb in */**/*.ipynb; do
  if [[ $nb == upload* ]]; then
    continue
  fi
  if [[ $nb == cleared* ]]; then
    continue
  fi
  DIR="$(dirname "$nb")"

  CONV_DIR="upload/$DIR"
  mkdir -p "$CONV_DIR"
  CONV_BASE="upload/${nb%.ipynb}"
  CONV_PY="${CONV_BASE}.py"
  CONV_HTML="${CONV_BASE}.html"

  PROCESSED_IPYNB="${CONV_BASE}.ipynb"
  with_echo "$MYDIR/prepare-ipynb" remove-marks "$nb" "$PROCESSED_IPYNB"
  if ! test -f "$CONV_PY" || test "$nb" -nt "$CONV_PY"; then
    with_echo python -m nbconvert "$PROCESSED_IPYNB" --to=python
  fi
  if ! test -f "$CONV_HTML" || test "$nb" -nt "$CONV_HTML"; then
    with_echo python -m nbconvert "$PROCESSED_IPYNB" --to=html
  fi

  CONV_DIR="cleared/$DIR"
  mkdir -p "$CONV_DIR"
  CONV_IPYNB="cleared/$nb"
  with_echo "$MYDIR/prepare-ipynb" clear-output clear-marked-inputs "$nb" "$CONV_IPYNB"
done
function mkdir_and_cp()
{
  dn=$(dirname "$2")
  mkdir -p "$dn"
  with_echo cp "$1" "$2"
}
for i in [0-9]*/**/*~*ipynb~*.pyc~*\~(#q.)(#qN); do
  with_echo mkdir_and_cp $i cleared/$i
  with_echo mkdir_and_cp $i upload/$i
done
