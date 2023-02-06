#!/bin/bash

MAX_SIZE=20000000
log_file=$1
BACKUP_FILE=$log_file.bak

file_size=$(wc -c < "$log_file")

# Rotate the file if its size exceeds the maximum size
if [ "$file_size" -gt "$MAX_SIZE" ]; then
  timestamp=$(date +"%Y%m%d-%H%M%S")

  # Backup the old file
  mv "$log_file" "$BACKUP_FILE"

  # Create a new empty file
  touch "$log_file"
fi
