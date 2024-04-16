#!/usr/bin/env bash

read -p "How many tunnels you want to open (default is UDP): " TUNNEL_AMOUNT
read -p "Session name: " SESSION_NAME

echo
echo
echo "-------- downloading & install rathole to /usr/local/bin/ ----------"

sleep 2

check_and_install_unzip() {
  if ! command -v unzip &> /dev/null; then
    echo "-> unzip is not installed. Installing..."

    if [[ $(lsb_release -is) == "Ubuntu" || $(lsb_release -is) == "Debian" ]]; then
      sudo apt-get update && sudo apt-get install unzip -y
    elif [[ $(cat /etc/os-release | grep -w ID=centos) ]]; then
      sudo yum install unzip -y 
    elif [[ $(cat /etc/os-release | grep -w ID=fedora) ]]; then
      sudo dnf install unzip -y
    else
      echo "-> Unsupported operating system. Please install unzip manually."
      return 1
    fi

    echo "-> unzip installed successfully."
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

echo "-> Start downloading rathole"

# ----------- ratholde download logic ------------
download_url="https://github.com/rapiz1/rathole/releases/latest/download/rathole-x86_64-unknown-linux-gnu.zip"
download_filename="rathole.zip"

download_with_progress "$download_url" "$download_filename"

# -------------------------------------------------

echo "-> Extracting rathole"
check_and_install_unzip

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

mv -f rathole /usr/local/bin/

rm -f "$download_filename"  

# --------------------- end logic for download rathole and install it to /usr/local/bin/ --------------------------


# --------------------- logic for generate rathole server conf file ----------------------------

echo
echo
echo "-------- preapre rathole config on /etc/rathole/  ----------"
echo "-> Prepare config for ${TUNNEL_AMOUNT} tunnels"

mkdir tunnel_config &> /dev/null

sudo apt install python3-pip &> /dev/null

pip3 install requests &> /dev/null

./server_conf_generator.py ${TUNNEL_AMOUNT} ${SESSION_NAME}

sudo cp -f ratholes@.service /etc/systemd/system/

sudo mkdir -p /etc/rathole &> /dev/null

sudo systemctl daemon-reload

sudo mv -f tunnel_config/server* /etc/rathole/

echo "----------------------------------------------"
echo
echo
echo "-------------------- starting rathole instance --------------"
config_dir="/etc/rathole"

for filename in "$config_dir"/*.toml; do
  service_name="${filename##*/}"
  service_name="${service_name%.*}"

  sudo systemctl enable "ratholes@$service_name" --now &>/dev/null

  echo "Started service: ratholes@$service_name"
done

echo "-> Showing all instance status"

sudo systemctl list-units --type=service --no-pager | grep ratholes