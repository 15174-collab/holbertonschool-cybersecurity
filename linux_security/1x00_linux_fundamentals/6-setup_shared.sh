#!/bin/bash
mkdir -p "$1" && groupadd -f "$2" && chown :"$2" "$1" && chmod 3775 "$1"
