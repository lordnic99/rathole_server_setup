#!/usr/bin/env bash

read -p "How many tunnels you want to open (default is UDP): " TUNNEL_AMOUNT

download_with_progress() {
  local url="$1"
  local filename="$2"
  if [[ ! -f "$filename" ]]; then
    wget -qO "$filename" "$url" &> /dev/null
    if [[ $? -eq 0 ]]; then
      echo "-> Downloaded '$filename'"
    else
      echo "-> Error downloading '$filename'"
      exit 1
    fi
  else
    echo "-> '$filename' already exists. Skipping download."
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
  echo "-> Rathole extract ok!"
else
  echo "-> Unsupported archive format for '$download_filename'"
  exit 1
fi

# -------------------------------------------------

chmod +x ./rathole

# mv rathole /usr/local/bin/
rm -f "$download_filename"  

