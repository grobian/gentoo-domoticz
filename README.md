# gentoo-domoticz
domoticz overlay for Gentoo

To use this overlay, add a file `domoticz.conf` to your `etc/portage/repos.conf` directory containing:
```
[domoticz]
location = /path/to/your/gentoo/overlays/domoticz
sync-type = https
sync-uri = https://github.com:grobian/gentoo-domoticz.git
auto-sync = no
```
or something like that.  You can also clone the repo manually of course.
Then you can emerge `domoticz-bin` which currently pulls in `libcurl-gnutls` in order to run the binary.

Please file an issue when you find any.
