#!/bin/bash


find "${1:-/usr/bin}" -perm -4000 -type f -ls 2>/dev/null
