#stop all ratholes service
for s in `sudo systemctl list-units --type=service --no-pager | grep ratholes | cut -d '.' -f 1`; do sudo systemctl stop $s; done

Example cURL requests:

# POST /createtunnel
--- failed case

curl -X POST http://127.0.0.1:44444/createtunnel \
     -H "Content-Type: application/json" \
     -H "Authorization: your_secret_token" \
     -d '{"name": "exampleName"}'

--- ok case
curl -X POST http://139.99.89.45:44444/createtunnel -H "Content-Type: application/json" -H "Authorization: Y7KBRwUn1WQ8FA0BFweVma1vDIEcrQwxn5XYiOiB_Xo" -d '{"name": "hoang"}'

# GET /gettunnel
curl http://127.0.0.1:44444/gettunnel?id=6 \
     -H "Authorization: 3XNteweBpR2p3XScI3sYfJhZ_vc5ImI9yH1zim7OdW8"

Y7KBRwUn1WQ8FA0BFweVma1vDIEcrQwxn5XYiOiB_Xo