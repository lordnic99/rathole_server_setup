#!/bin/env bash

download_with_progress() {
  local url="$1"
  local filename="$2"

  if [[ ! -f "$filename" ]]; then
    wget -qO "$filename" "$url" &> /dev/null
    if [[ $? -eq 0 ]]; then
      echo "Downloaded '$filename'"
    else
      echo "Error downloading '$filename'"
      exit 1
    fi
  else
    echo "'$filename' already exists. Skipping download."
  fi
}

echo "[INFO] Start downloading rathole"

# ----------- ratholde download logic ------------
download_url="https://github.com/rapiz1/rathole/releases/latest/download/rathole-x86_64-unknown-linux-gnu.zip"
download_filename="rathole.zip"

download_with_progress "$download_url" "$download_filename"

# -------------------------------------------------

echo "[INFO] Extracting rathole"

# -------------------------------------------------
if [[ "${download_filename}" =~ \.zip$ ]]; then
  unzip -q "$download_filename"
elif [[ "${download_filename}" =~ \.tar\.gz$ ]]; then
  tar -xf "$download_filename"
else
  echo "Unsupported archive format for '$download_filename'"
  exit 1
fi

# -------------------------------------------------


# extracted_filename="${download_filename%.*}"  # Remove extension
# chmod +x "./$extracted_filename"

# Move the executable to a system-wide location (use with caution)
# Consider using a user-specific directory (e.g., ~/.local/bin) instead
# sudo mv "./$extracted_filename" /usr/local/bin/

# Clean up (optional)
# rm -f "$download_filename"  # Uncomment to remove the downloaded archive

echo "Installation complete!"
