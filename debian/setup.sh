#! /bin/bash

(crontab -l 2>/dev/null; echo "@reboot /etc/init.d/resize") | crontab - || true
rm -f /srv/*
poweroff
