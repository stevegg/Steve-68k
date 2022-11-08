#!/usr/bin/env bash
set -e

export ROMDEVICE=SST39SF040

if [[ -z $ROMDEVICE ]]; then
  echo "ROMDEVICE not set; Please supply the ROM device type!"
else
  echo "Burning ROM device type $ROMDEVICE"

  read -p "Place EVEN ROM in burner"
  sudo minipro -p $ROMDEVICE -s -y -w _even.rom

  read -p "Place ODD ROM in burner"
  sudo minipro -p $ROMDEVICE -s -y -w _odd.rom
fi

