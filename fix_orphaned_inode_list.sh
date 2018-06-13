#!/bin/bash

function cleanup() {
  if losetup $loopback &>/dev/null; then
        if [ "$verbose_mode" = true ]; then
        echo "### Running cleanup ###"
        fi
        losetup -d "$loopback"
  fi
}

verbose_mode=false

while getopts ":v" opt; do
  case "${opt}" in
    v) verbose_mode=true ;;
    *) usage ;;
  esac
done
shift $((OPTIND-1))

usage() { echo "Usage: $0 [-v] imagefile.img"; exit -1; }

if [ "$verbose_mode" = true ]; then
echo "### Mapping arguments ###"
fi

img="$1"

if [ "$verbose_mode" = true ]; then
echo "### Usage checks ###"
fi

if [[ -z "$img" ]]; then
  usage
fi
if [[ ! -f "$img" ]]; then
  echo "ERROR: $img is not a file..."
  exit -2
fi
if (( EUID != 0 )); then
  echo "ERROR: You need to be running as root."
  exit -3
fi

echo "#Check that what we need is installed"
for command in parted losetup tune2fs md5sum e2fsck resize2fs; do
  which $command 2>&1 >/dev/null
  if (( $? != 0 )); then
    echo "ERROR: $command is not installed."
    exit -4
  fi
done

if [ "$verbose_mode" = true ]; then
echo "### Setting cleanup at script exit ###"
fi
trap cleanup ERR EXIT

beforesize=$(ls -lh "$img" | cut -d ' ' -f 5)
parted_output=$(parted -ms "$img" unit B print | tail -n 1)
partnum=$(echo "$parted_output" | cut -d ':' -f 1)
partstart=$(echo "$parted_output" | cut -d ':' -f 2 | tr -d 'B')
loopback=$(losetup -f --show -o $partstart "$img")
tune2fs_output=$(tune2fs -l "$loopback")
currentsize=$(echo "$tune2fs_output" | grep '^Block count:' | tr -d ' ' | cut -d ':' -f 2)
blocksize=$(echo "$tune2fs_output" | grep '^Block size:' | tr -d ' ' | cut -d ':' -f 2)

fsck -y "$loopback"
