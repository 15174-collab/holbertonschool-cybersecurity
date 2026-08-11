#!/bin/bash
mkdir -p $1 && groupadd -f developers
chown root:developers $1 && chmod 3775 $1
