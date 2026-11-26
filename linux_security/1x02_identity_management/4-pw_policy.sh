#!/bin/bash
dpkg -s "$1" >/dev/null 2>&1 || DEBIAN_FRONTEND=noninteractive apt-get install -y $1
if grep -q 'pam_pwquality.so' "$2"; then
    sed -i -E 's/^(password\s+\S+\s+pam_pwquality\.so).*/\1 retry=3 minlen=12 minclass=3/' "$2"
else
    sed -i -E '/^password\s+.*pam_unix\.so/i password\trequisite\t\t\tpam_pwquality.so retry=3 minlen=12 minclass=3' "$2"
fi
