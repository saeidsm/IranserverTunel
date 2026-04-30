# Supported VLESS URL formats

## VLESS over WebSocket (with camouflage)

```
vless://UUID@SERVER:PORT?type=ws&host=CAMOUFLAGE.example.com&path=/somepath&security=none#TUNNEL_NAME
```

Example (sanitized):
```
vless://00000000-0000-0000-0000-000000000000@example.com:443?type=ws&host=fake-host.com&path=/index.html&security=none#mytunnel
```

## VLESS over TCP with HTTP camouflage

```
vless://UUID@SERVER:PORT?type=tcp&headerType=http&host=CAMOUFLAGE1.com,CAMOUFLAGE2.com&path=/&security=none#TUNNEL_NAME
```

Example:
```
vless://00000000-0000-0000-0000-000000000000@example.com:4200?type=tcp&headerType=http&host=fake1.com,fake2.com#mytunnel
```

## Currently supported

- `type=ws` — WebSocket (with optional `host` for camouflage)
- `type=tcp` — Plain TCP, optionally with `headerType=http` for HTTP camouflage

## Not yet supported

- `type=grpc` — gRPC
- `type=kcp` — mKCP
- `security=reality` — VLESS+Reality
- `security=tls` with custom SNI

For these, use Method 2 (JSON file) or Method 3 (paste JSON) when adding a tunnel.
