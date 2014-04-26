#!/bin/sh
# Make sure we are in the right place
cd $(dirname $0) || exit 1
rootdir=$(pwd)

#- Prepare working directories
prep() {
    [ ! -d build ] && mkdir -v build
    [ ! -d rpi-buildroot ] \
	&& git clone --depth 1 git://github.com/gamaral/rpi-buildroot.git

    [ ! -d dl ] && mkdir dl
    if [ ! -d src ] ; then
      cp -av rpi-buildroot src
      cp -abv local-src/* src
      #
      # Patch the Config.in to mach our stuff
      #
      cat >>src/package/Config.in <<-EOF
	menu "Local Target packages"
	source "package/hostapd-rtl8192cu/Config.in"
	endmenu
	EOF
      (
	cd src
	ln -s ../dl .
	ln -s ../build/images .

	make O=$rootdir/build raspberrypi-local_defconfig
	#make O=$rootdir/build nconfig
	#make O=$rootdir/build make
      )
    fi
}

clean() {
    local attic=$(mktemp -d -p .)
    [ -d build ] && mv build $attic
    [ -d src ] && mv src $attic
    rm -rf $attic
}

ovl() {
  (
    sd=/dev/sdb
    for arg in "$@"
    do
      eval $sd
    done
    sudo mount ${sd}2 /mnt && trap "set -x ; sudo umount /mnt" EXIT || exit
    # dR --preserve=all
    sudo cp -dRv --preserve=mode,timestamps,links local-src/board/raspberrypi/overlay/* /mnt
    sudo umount /mnt
    sudo mount ${sd}1 /mnt || exit
    grep -q '^cmdline=' /mnt/config.txt \
	&& sudo sed -i~ 's/^cmdline=/#cmdline=/' /mnt/config.txt
    sed -e 's/\#.*$//' < local-src/board/raspberrypi/cmdline.txt \
	| grep -v '^$' | ( tr '\n' ' ' ; echo '' ) \
	| sudo dd of="/mnt/cmdline.txt"
  )
}

sdcard() {
  (
    sd=/dev/sdb
    for arg in "$@"
    do
      eval $sd
    done
    cd src
    sudo board/raspberrypi/mksdcard $sd
  )
}

inst() {
  sdcard "$@"
  ovl "$@"
}

cc() {
  (
    cd src
    make O=$rootdir/build "$@"
  )
}

if ! type -t "$1" ; then
  cc "$@"
else
 "$@"
fi

