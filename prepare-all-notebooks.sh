#! /usr/bin/env zsh

set -e
setopt -o EXTENDED_GLOB

function with_echo()
{
  echo "$@"
  "$@"
}

function mkdir_and_cp()
{
  dn=$(dirname "$2")
  mkdir -p "$dn"
  with_echo cp "$1" "$2"
}

unset PYTHONWARNINGS

ME=$(readlink -f "$0")
DIR=$(dirname "$ME")
MYDIR=$(cd "$DIR" && pwd)

if [[ "$1" = "" ]]; then
  INPUTDIR="$(pwd)"
else
  INPUTDIR="$1"
fi

if [[ "$2" = "" ]]; then
  OUTPUTDIR="$(pwd)"
else
  OUTPUTDIR="$2"
fi

for nb in $INPUTDIR/*/**/*.ipynb; do
  if [[ $nb == upload* ]]; then
    continue
  fi
  if [[ $nb == cleared* ]]; then
    continue
  fi

  DIR="$(dirname "$nb")"
  BN="$(basename "$nb")"
  RELDIR="$(realpath --relative-to="$INPUTDIR" "$DIR")"

  CONV_DIR="$OUTPUTDIR/upload/$RELDIR"
  CONV_BASE="$CONV_DIR/${BN%.ipynb}"
  CONV_PY="${CONV_BASE}.py"
  CONV_HTML="${CONV_BASE}.html"
  PROCESSED_IPYNB="${CONV_BASE}.ipynb"

  if test -f "$DIR/.do-not-publish"; then
    continue
  fi

  mkdir -p "$CONV_DIR"

  if ! test -f "$PROCESSED_IPYNB" || test "$nb" -nt "$PROCESSED_IPYNB"; then
    with_echo "$MYDIR/prepare-ipynb" remove-marks "$nb" "$PROCESSED_IPYNB"
  fi
  if ! test -f "$CONV_PY" || test "$nb" -nt "$CONV_PY"; then
    with_echo python -m nbconvert "$PROCESSED_IPYNB" --to=python
  fi
  if ! test -f "$CONV_HTML" || test "$nb" -nt "$CONV_HTML"; then
    with_echo python -m nbconvert "$PROCESSED_IPYNB" --to=html
  fi

  CONV_DIR="$OUTPUTDIR/cleared/$RELDIR"
  mkdir -p "$CONV_DIR"
  CONV_IPYNB="$CONV_DIR/$BN"
  with_echo "$MYDIR/prepare-ipynb" clear-output clear-marked-inputs "$nb" "$CONV_IPYNB"
done

for i in $INPUTDIR/*/**/*~*ipynb~*.log~*.pyc~*\~(#q.)(#qN); do
  DIR="$(dirname "$i")"
  RELNAME="$(realpath --relative-to="$INPUTDIR" "$i")"
  if test -f "$DIR/.do-not-publish"; then
    continue
  fi

  if [[ "$RELNAME" == upload* ]]; then
    continue
  fi
  if [[ "$RELNAME" == ipython-demo-tools* ]]; then
    continue
  fi
  if [[ "$RELNAME" == cleared* ]]; then
    continue
  fi
  with_echo mkdir_and_cp "$i" "$OUTPUTDIR/cleared/$RELNAME"
  with_echo mkdir_and_cp "$i" "$OUTPUTDIR/upload/$RELNAME"
done
