#!/usr/bin/env python3

import socket
import sys
import string
import random
from requests import get
import os

TUNNLE_CONFIG_AMOUNT = sys.argv[1]

os.chdir(os.path.join(os.getcwd(), "tunnel_config"))

def check_available_ports(start_port, end_port):
    available_ports = []
    for port in range(start_port, end_port + 1):
        try:
            if len(available_ports) == int(TUNNLE_CONFIG_AMOUNT):
                return available_ports
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                result = s.bind(("localhost", port))
                available_ports.append(port)
        except OSError:
            pass

    return None

def generate_token(length=32):
  characters = string.ascii_letters
  return ''.join(random.choice(characters) for _ in range(length))

def generate_server_config(token, server_port, tunnel_name, config_name):
    SERVER_CONF_TEMPLATE = f'''[server]
bind_addr = "0.0.0.0:{server_port}"
default_token = "{token}"

[server.services.{tunnel_name}]
type = "udp"
bind_addr = "0.0.0.0:55555"
'''
    
    with open(f"{config_name}.toml", "w") as f:
        f.write(SERVER_CONF_TEMPLATE)
        
def generate_client_config(token, remote_addr, tunnel_name, config_name):
    CLIENT_CONF_TEMPLATE = f'''[client]
remote_addr = "{remote_addr}"
default_token = "{token}"

[client.services.{tunnel_name}]
type = "udp"
local_addr = "127.0.0.1:55555"
'''
    with open(f"{config_name}.toml", "w") as f:
        f.write(CLIENT_CONF_TEMPLATE)

if __name__ == "__main__":
    start_port = 49152
    end_port = 65535
    
    print("-> Getting available port for setup")
    available_ports = check_available_ports(start_port, end_port)

    server_ip = get('https://api.ipify.org').content.decode('utf8')
    print(f"-> Public IP found: {server_ip}")

    if available_ports:
        print("-> All available port ready, generating config")
        i = 0
        for port in available_ports:
            i = i + 1
            token = generate_token()
            generate_server_config(token, port, f"udp{i}", f"server_udp{i}")
            generate_client_config(token, f"{server_ip}:{port}", f"udp{i}", f"client_udp{i}")
            print(f"-> Config {i} ok!")
    else:
        print(f"No available ports found in the range {start_port} to {end_port}.")