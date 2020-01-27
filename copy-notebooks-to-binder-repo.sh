#! /bin/zsh

set -e
setopt -o EXTENDED_GLOB

REPODIR="$1"
if [[ "$REPODIR" = "" ]]; then
  echo "usage: $0 repo_dir"
  exit 1
fi
if ! [[ -d "$REPODIR/.git" ]]; then
  echo "repo_dir must have a .git directory, for safety"
  exit 1
fi

function with_echo()
{
  echo "$@"
  "$@"
}

with_echo rm -f $REPODIR/**/*.ipynb(#qN)

unset PYTHONWARNINGS

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

  if test -f "$DIR/.do-not-publish"; then
    continue
  fi

  CONV_DIR="$REPODIR/$DIR"
  mkdir -p "$CONV_DIR"
  CONV_BASE="upload/${nb%.ipynb}"

  PROCESSED_IPYNB="$REPODIR/$nb"
  if ! test -f "$PROCESSED_IPYNB" || test "$nb" -nt "$PROCESSED_IPYNB"; then
    with_echo "$MYDIR/prepare-ipynb" remove-marks "$nb" "$PROCESSED_IPYNB"
  fi
done
function mkdir_and_cp()
{
  dn=$(dirname "$2")
  mkdir -p "$dn"
  with_echo cp "$1" "$2"
}
for i in */**/*~*ipynb~*.pyc~*\~(#q.)(#qN); do
  DIR="$(dirname "$i")"
  if test -f "$DIR/.do-not-publish"; then
    continue
  fi

  if [[ $i == upload* ]]; then
    continue
  fi
  if [[ $i == ipython-demo-tools* ]]; then
    continue
  fi
  if [[ $i == cleared* ]]; then
    continue
  fi
  with_echo mkdir_and_cp $i "$REPODIR/$i"
done
