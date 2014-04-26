#!/bin/sh
#
# WIFI Utilities
#
wifi_data=/tmp/wifi_client.txt
wifi_persist=/etc/harpy/wifi_client.txt
wifi=wlan0
wcli() {
  wpa_cli -i$wifi "$@"
}

wifi_connect() {
  local ssid="$1"
  local psk="$2"

  local netid=$(wcli add_network) || return 1
  echo $netid
  wcli set_network $netid ssid "\"$ssid\"" || return 1
  wcli set_network $netid psk "\"$psk\"" || return 1
  wcli enable_network $netid || return 1
  return 0
}

wifi_get_psk() {
  local file="$1"
  local ssid_in="$2"
  [ -f "$file" ] || return
  (
    while read ssid_fh
    do
      read psk
      if [ x"$ssid_fh" = x"$ssid_in" ] ; then
	echo "$psk"
	break
      fi
    done
  ) < "$file"
}

wifi_put_psk() {
  local file="$1"
  local ssid_in="$2"
  local psk_in="$3"
  if [ -f "$file" ] ; then
    cdata=$(cat "$file")
  else
    cdata=""
    >"$file"
  fi
  ndata=$(
    exec < "$file"
    write=yes
    while read ssid_fh
    do
      read psk_fh
      if [ x"$ssid_fh" = x"$ssid_in" ] ; then
	write=no
	psk_fh="$psk_in"
      fi
      [ -z "$ssid_fh" ] && continue
      echo "$ssid_fh"
      echo "$psk_fh"
    done
    if [ $write = yes ] ; then
      echo "$ssid_in"
      echo "$psk_in"
    fi
  )
  [ x"$cdata" = x"$ndata" ] && return
  echo "$ndata" > "$file"
}

wifi_del_psk() {
  local file="$1"
  local ssid_in="$2"
  if [ -f "$file" ] ; then
    cdata=$(cat "$file")
  else
    cdata=""
    >"$file"
  fi
  ndata=$(
    exec < "$file"

    while read ssid_fh
    do
      read psk_fh
      [ x"$ssid_fh" = x"$ssid_in" ] && continue
      [ -z "$ssid_fh" ] && continue
      echo "$ssid_fh"
      echo "$psk_fh"
    done
  )
  [ x"$cdata" = x"$ndata" ] && return
  echo "$ndata" > "$file"
}
