#!/usr/bin/env bash

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

set_secret_key() {
   if [ -f .env ]; then
       if grep -q '^SECRET_KEY=' .env; then
           echo "-> SECRET_KEY already exists in the .env file. Not generating a new key."
       fi
   else
        SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
        echo "SECRET_KEY=$SECRET_KEY" > .env
        echo "-> New SECRET_KEY has been set in the .env file."
   fi
}

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

echo "-------- downloading & install rathole to /usr/local/bin/ ----------"

if ! command -v unzip &> /dev/null; then
    echo "-> unzip is not installed. Installing..."
    sudo apt-get update -y && sudo apt-get install unzip -y &> /dev/null
fi

echo "-> Start downloading rathole"

# ----------- ratholde download logic ------------
download_url="https://github.com/rapiz1/rathole/releases/latest/download/rathole-x86_64-unknown-linux-gnu.zip"
download_filename="rathole.zip"

download_with_progress "$download_url" "$download_filename"

# -------------------------------------------------

echo "-> Extracting rathole"

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

sudo mv -f rathole /usr/local/bin/

sudo rm -f "$download_filename"  

sudo cp -f ratholes@.service /etc/systemd/system/

sudo mkdir -p /etc/rathole &> /dev/null

sudo systemctl daemon-reload

# --------------------- end logic for download rathole and install it to /usr/local/bin/ --------------------------



# # --------------------- logic for preapre to run server ----------------------------

echo
echo
echo "-------- preapre for running reversed proxy server  ----------"


sudo apt install python3-pip -y &> /dev/null

sudo apt install python3-requests -y &> /dev/null

sudo apt-get install -y python3-flask &> /dev/null

set_secret_key

export $(cat .env)

chmod +x Reversed_Server/run.py

./Reversed_Server/run.py



# echo "----------------------------------------------"
# echo
# echo
# echo "-------------------- starting rathole instance --------------"
# config_dir="/etc/rathole"

# for filename in "$config_dir"/*.toml; do
#   service_name="${filename##*/}"
#   service_name="${service_name%.*}"

#   sudo systemctl enable "ratholes@$service_name" --now &>/dev/null

#   echo "Started service: ratholes@$service_name"
# done

# echo "-> Showing all instance status"

# sudo systemctl list-units --type=service --no-pager | grep ratholes