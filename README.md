# Rathole Server Setup

Automated installer for a **rathole server** with a lightweight tunnel management API. This project helps you deploy rathole on Linux, create tunnel configurations through an HTTP API, store tunnel metadata, and manage tunnel instances with systemd.

## Features

- Automatically downloads the latest `rathole` release for Linux `x86_64`.
- Installs the `rathole` binary into `/usr/local/bin`.
- Installs the `ratholes@.service` systemd template for running multiple independent tunnel instances.
- Runs a Flask/Waitress API server on port `44444`.
- Creates dynamic UDP tunnels through the `/createtunnel` endpoint.
- Stores tunnel metadata including `remotePort`, `bindPort`, `token`, and `tunnelID`.
- Generates rathole configuration files under `/etc/rathole` and starts the matching systemd instance automatically.
- Provides an uninstall script to stop services and remove generated configuration.

## Architecture

```text
Client/API caller
      |
      | HTTP :44444 + Authorization SECRET_KEY
      v
Reversed_Server Flask API
      |
  | generates server_*.toml
      v
/etc/rathole/server_*.toml
      |
      | systemctl enable ratholes@server_* --now
      v
rathole server instance
```

When a new tunnel is created, the API will:

1. Select two available ports in the `49152-65535` range.
2. Generate a dedicated token for the tunnel.
3. Create a `server_<random>.toml` configuration file.
4. Move the configuration file into `/etc/rathole`.
5. Start the `ratholes@server_<random>` systemd service.
6. Return the connection details to the client.

## Requirements

- Ubuntu/Debian or another Linux distribution that uses `apt` and `systemd`.
- `root` access or a user with `sudo` privileges.
- Internet access for downloading `rathole` and installing packages.
- A server with a public IP address.
- Ports in the `49152-65535` range must be allowed by the firewall/security group if clients connect from outside the server.

The installer automatically installs packages such as `unzip`, `python3-pip`, `python3-requests`, `python3-flask`, `python3-sqlalchemy`, `python3-flask-sqlalchemy`, `python3-waitress`, and `mysql-server`.

> Note: the API currently uses a SQLite database file named `proxy_endpoint.db` in the service runtime directory. The installer still installs MySQL as part of the current project logic.

## Installation

```bash
git clone https://github.com/lordnic99/rathole_server_setup.git
cd rathole_server_setup
git submodule update --init --recursive
git submodule foreach --recursive git checkout master
git submodule foreach --recursive git pull
chmod +x rathole_server_setup.sh
./rathole_server_setup.sh
```

After the installer finishes, it prints output similar to:

```text
API SERVER: <public-ip>:44444
SECRET KEY: <generated-secret-key>
```

Save the `SECRET KEY`. It is required in the `Authorization` header for all API requests.

## Installed Components

| Component | Location |
| --- | --- |
| Rathole binary | `/usr/local/bin/rathole` |
| Rathole config | `/etc/rathole/*.toml` |
| Rathole systemd template | `/etc/systemd/system/ratholes@.service` |
| API server source | `/root/.reversed_server` |
| API systemd service | `/etc/systemd/system/Reversed_Server.service` |
| API secret file | `/root/.reversed_server/.env` |
| Used ports cache | `/root/.config/reversed_server/port_used.csv` |

## API

All requests require this header:

```http
Authorization: <SECRET_KEY>
```

### Create a Tunnel

```http
POST /createtunnel
Content-Type: application/json
Authorization: <SECRET_KEY>
```

Body:

```json
{
  "name": "exampleName"
}
```

Example:

```bash
curl -X POST http://<server-ip>:44444/createtunnel \
  -H "Content-Type: application/json" \
  -H "Authorization: <SECRET_KEY>" \
  -d '{"name":"exampleName"}'
```

Successful response:

```json
{
  "status": "OK",
  "serverIP": "<server-ip>",
  "remotePort": 49152,
  "bindPort": 49153,
  "token": "<tunnel-token>",
  "tunnelID": 1,
  "message": "Tunnel created OK"
}
```

Important response fields:

| Field | Description |
| --- | --- |
| `serverIP` | Server public IP address |
| `remotePort` | Rathole server port that the client connects to |
| `bindPort` | Public UDP port bound on the server |
| `token` | Tunnel-specific token used in the rathole client configuration |
| `tunnelID` | ID used to retrieve tunnel information later |

### Get Tunnel Information

```http
GET /gettunnel?id=<tunnelID>
Authorization: <SECRET_KEY>
```

Example:

```bash
curl "http://<server-ip>:44444/gettunnel?id=1" \
  -H "Authorization: <SECRET_KEY>"
```

Successful response:

```json
{
  "status": "OK",
  "serverIP": "<server-ip>",
  "remotePort": "49152",
  "bindPort": "49153",
  "token": "<tunnel-token>",
  "tunnelID": 1,
  "message": "Tunnel get request OK"
}
```

## Example Rathole Client Configuration

After creating a tunnel, use the values returned by the API to create the client configuration:

```toml
[client]
remote_addr = "<serverIP>:<remotePort>"
default_token = "<token>"

[client.services.exampleName]
type = "udp"
local_addr = "127.0.0.1:<local-udp-port>"
```

Where:

- `<serverIP>` is the server public IP address.
- `<remotePort>` is the port the client connects to on the rathole server.
- `<token>` is the tunnel-specific token.
- `<local-udp-port>` is the local UDP port that the client wants to expose through the server.

## Service Management

Check the API server status:

```bash
sudo systemctl status Reversed_Server
```

Follow API server logs:

```bash
sudo journalctl -u Reversed_Server -f
```

List running rathole tunnel services:

```bash
sudo systemctl list-units --type=service --no-pager | grep ratholes
```

Check a specific tunnel service:

```bash
sudo systemctl status ratholes@server_<config-id>
```

Restart the API server:

```bash
sudo systemctl restart Reversed_Server
```

## Uninstall

```bash
chmod +x uninstall.sh
./uninstall.sh
```

The uninstall script stops `Reversed_Server`, stops `ratholes@*` services, removes service files, and deletes generated configuration files under `/etc/rathole`.

## Project Structure

```text
.
├── README.md
├── my.cnf
├── rathole_server_setup.sh
├── ratholes@.service
├── Reversed_Server.service
├── support_tools.sh
├── uninstall.sh
└── Reversed_Server/
    ├── instance_deploy.py
    ├── run.py
    ├── server_conf_generator.py
    └── server_start.sh
```

  ## Security and Operations Notes

  - Do not commit `.env` files or secret keys to the repository.
  - Restrict port `44444` to trusted IP addresses if the API does not need to be publicly accessible.
  - Configure firewall/security group rules for tunnel ports according to your actual deployment needs.
  - `SECRET_KEY` protects the tunnel management API. If it is leaked, rotate the key in `/root/.reversed_server/.env` and restart the service.
  - Each tunnel uses its own token in the rathole client configuration.

## Troubleshooting

Check the rathole binary:

```bash
which rathole
rathole --version
```

Check whether the API is listening on port `44444`:

```bash
sudo ss -lntp | grep 44444
```

Inspect logs when tunnel creation fails:

```bash
sudo journalctl -u Reversed_Server -n 100 --no-pager
```

Check whether tunnel configuration files were created:

```bash
sudo ls -la /etc/rathole
```

If a tunnel cannot be reached from the Internet, check the server firewall, cloud security group, and the `remotePort`/`bindPort` values returned by the API.
