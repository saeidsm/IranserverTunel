# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-04-30

### Added
- Initial release of `tunnel-mgr` script
- HAProxy load balancer with auto-failover
- VLESS over WebSocket support
- VLESS over TCP with HTTP header camouflage support
- Three input methods: VLESS URL, JSON file, paste JSON inline
- Automatic enrichment of JSON configs with Iranian routing rules
- Health monitoring (15-minute quick checks, 6-hour deep tests)
- Auto-pause failed tunnels (2 hours, then auto-resume)
- Capability detection (Gemini, FLUX, ElevenLabs)
- Interactive TUI menu (bash-based with colors)
- Bilingual documentation (English + Persian)
- TECH_DEBT.md tracking known limitations
- SHAHRZAD_INTEGRATION.md for backend integration plan

### Tested
- VLESS+WS via WebSocket camouflage (mkmovie style)
- VLESS+TCP+HTTP camouflage (freezen, liq style)
- Concurrent load (10 parallel requests, 0 failures)
- Real API calls to Gemini, FLUX, ElevenLabs from Iran

### Known issues
See [TECH_DEBT.md](TECH_DEBT.md).
