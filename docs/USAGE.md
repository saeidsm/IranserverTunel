# Command Reference

## Interactive Mode

```bash
sudo tunnel-mgr            # opens TUI menu
sudo tunnel-mgr menu       # same as above
```

## Direct Commands

### Adding tunnels

```bash
sudo tunnel-mgr add                    # interactive prompt
sudo tunnel-mgr add mytunnel           # name pre-filled
```

### Listing / Status

```bash
sudo tunnel-mgr status                 # detailed pool view
sudo tunnel-mgr list                   # alias for status
```

### Testing

```bash
sudo tunnel-mgr test mytunnel          # deep test one tunnel
sudo tunnel-mgr test-all               # deep test all
sudo tunnel-mgr health                 # quick check (used by cron)
```

### Pause / Resume

```bash
sudo tunnel-mgr pause mytunnel         # pause for 2 hours
sudo tunnel-mgr pause mytunnel 4       # pause for 4 hours
sudo tunnel-mgr resume mytunnel        # resume now
```

### Removing

```bash
sudo tunnel-mgr remove mytunnel        # confirm prompt
```

### Maintenance

```bash
sudo tunnel-mgr reload                 # rebuild HAProxy config
```

## VLESS URL formats supported

```
vless://UUID@HOST:PORT?type=ws&host=CAMOUFLAGE_HOST&path=/PATH&security=none#NAME
vless://UUID@HOST:PORT?type=tcp&headerType=http&host=H1,H2&path=/PATH#NAME
```

## Logs

```
/home/ubuntu/v2ray/logs/access-NAME.log    # per-tunnel access log
/home/ubuntu/v2ray/logs/error-NAME.log     # per-tunnel error log
/home/ubuntu/v2ray/logs/health.log         # cron health checks
/home/ubuntu/v2ray/logs/deep-test.log      # cron deep tests
```

## State files

```
/home/ubuntu/v2ray/state/tunnels.json          # main state
/home/ubuntu/v2ray/state/haproxy.cfg.original  # original HAProxy config
/home/ubuntu/v2ray/test-results/NAME/          # deep test reports
```
