#stop all ratholes service
for s in `sudo systemctl list-units --type=service --no-pager | grep ratholes | cut -d '.' -f 1`; do sudo systemctl stop $s; done

Example cURL requests:

# POST /createtunnel
--- failed case

curl -X POST http://127.0.0.1:45642/createtunnel \
     -H "Content-Type: application/json" \
     -H "Authorization: your_secret_token" \
     -d '{"name": "exampleName"}'

--- ok case
curl -X POST http://127.0.0.1:45642/createtunnel \
     -H "Content-Type: application/json" \
     -H "Authorization: 3KCGC3QjUzskyJLOxzWG4pOmg6oeyL-J34hyqg9n3wA" \
     -d '{"name": "exampleName"}'

# GET /gettunnel
curl http://127.0.0.1:45642/gettunnel?name=exampleName \
     -H "Authorization: 3KCGC3QjUzskyJLOxzWG4pOmg6oeyL-J34hyqg9n3wA"

