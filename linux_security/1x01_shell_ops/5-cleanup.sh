#!/bin/bash
while IFS= read -r user || [ -n "$user" ]; do if id "$user" &>/dev/null; then usermod -L "$user"; echo "User $user locked"; else echo "User $user not found"; fi; done < "$1"
