#!/bin/bash
find $1 -type f -size +1M ! -name "*.gz" -newermt "2024-01-01" 2>/dev/null
