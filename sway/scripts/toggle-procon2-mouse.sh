#!/bin/sh
set -eu

service=procon2-mouse.service

if systemctl --user is-active --quiet "$service"; then
  systemctl --user stop "$service"
else
  systemctl --user start "$service"
fi
