#!/usr/bin/env bash
set -e

export ROMDEVICE=SST39SF040

if [[ -z $ROMDEVICE ]]; then
  echo "ROMDEVICE not set; Please supply the ROM device type!"
else
  echo "Burning ROM device type $ROMDEVICE"

  read -p "Place EVEN ROM in burner"
  minipro -p $ROMDEVICE -s -w RoscoUARTTest_even.rom

  read -p "Place ODD ROM in burner"
  minipro -p $ROMDEVICE -s -w RoscoUARTTest_odd.rom
fi

