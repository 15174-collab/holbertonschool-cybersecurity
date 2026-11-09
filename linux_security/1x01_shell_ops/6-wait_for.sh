#!/bin/bash
until curl -s "http://$1" &>/dev/null; do echo "Waiting"; sleep 1; done; echo  "Service UP!"
