# harpy

A Simple "nano-router" type Raspberry image

## Building

Using the `mk` script.

### subcommands

* prep : Prepare the build environment
* clean : deletes the build and src trees
* ovl [sd=/dev/sdx] : copy the overlay files to sdcard
* sdcard [sd=/dev/sdx] : Install image to sdcard
* inst [sd=/dev/sdx ] : Install image and copy overlays to sdcard
* cc : Call make
  Make targets:
  * nconfig : Configure image
  * linux-menuconfig : Configure kernel
  * busybox-menuconfig : Configure busybox

### workflow

1. `./mk prep`
   Prepares the build environment
2. `./mk nconfig`
   Initialises basic configuration.
3. `./mk`
   Builds the whole thing
4. `./mk sdcard sd=/dev/xxxx`
   Installs to SD card
5. Insert SD card into pi and run...

* * *

1. setup ethernet
3. setup wifi client
2. setup AP router
   - hostapd
   - nat (IP!)
     - static IP
	 - sysctl
	 - iptables
   - ap_ipcfg (configs static IP and dnsmasq)
   - dnsmasq (IP!)
4. user interface


* * *

# TODO

- Configure AP SSID and PSK
- TODO: udhcp script should kill dnsmasq (so it checks IPs again)

