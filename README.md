# Install
git clone https://github.com/lordnic99/rathole_server_setup.git
cd rathole_server_setup
git submodule --init update
git submodule foreach --recursive git checkout master
git submodule foreach --recursive git pull
./rathole_server_setup.sh
