#!/bin/bash
awk -F: '$1 ~ /^(root|disk|docker|shadow)$/ && $4 != "" {n = split($4, m, ","); for (i = 1; i <= n; i++) print m[i]":"$1}' "$1"
