# Graph Report - repos_IranServerTunnel_IranserverTunel  (2026-09-05)

## Corpus Check
- 13 files · ~9,900 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 139 nodes · 138 edges · 12 communities (11 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Technical Debt & Future Improvements|Technical Debt & Future Improvements]]
- [[_COMMUNITY_Shahrzad Integration Guide|Shahrzad Integration Guide]]
- [[_COMMUNITY_📋 فهرست تغییرات لازم|📋 فهرست تغییرات لازم]]
- [[_COMMUNITY_Architecture|Architecture]]
- [[_COMMUNITY_English|English]]
- [[_COMMUNITY_Direct Commands|Direct Commands]]
- [[_COMMUNITY_README|README.md]]
- [[_COMMUNITY_Installation Guide|Installation Guide]]
- [[_COMMUNITY_Contributing|Contributing]]
- [[_COMMUNITY_API Keys Setup|API Keys Setup]]
- [[_COMMUNITY_Supported VLESS URL formats|Supported VLESS URL formats]]
- [[_COMMUNITY_install-xray.sh|install-xray.sh]]

## God Nodes (most connected - your core abstractions)
1. `📋 فهرست تغییرات لازم` - 17 edges
2. `Installation Guide` - 10 edges
3. `Shahrzad Integration Guide` - 8 edges
4. `Technical Debt & Future Improvements` - 7 edges
5. `Direct Commands` - 7 edges
6. `Contributing` - 6 edges
7. `IranserverTunel` - 6 edges
8. `English` - 6 edges
9. `📅 پیشنهاد ترتیب اجرا` - 6 edges
10. `API Keys Setup` - 6 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (12 total, 1 thin omitted)

### Community 0 - "Technical Debt & Future Improvements"
Cohesion: 0.10
Nodes (20): 🤝 Contributing to this file, 📊 Metrics برای ردیابی, 🔴 P1 — مهم، باید قبل از scale حل شوند, 🟡 P2 — مهم، بعد از launch, 🔵 P3 — بهبود تجربه, ✅ Resolved (تاریخچه), TD-001: aiohttp و NO_PROXY, TD-002: کانفیگ‌های VLESS با Reality یا gRPC پشتیبانی نمی‌شوند (+12 more)

### Community 1 - "Shahrzad Integration Guide"
Cohesion: 0.12
Nodes (16): Shahrzad Integration Guide, Sprint A (Foundation, ~۱ هفته), Sprint B (Tunnel Integration, ~۱ هفته), Sprint C (Region-specific Providers, ~۱ هفته), Sprint D (Iran-specific, ~۲ هفته), Sprint E (Optimization, post-launch), 🎯 اصول طراحی, 📐 معماری نهایی پیشنهادی (+8 more)

### Community 2 - "📋 فهرست تغییرات لازم"
Cohesion: 0.12
Nodes (17): 🔧 INT-001: Region-aware deployment config, 🔧 INT-002: Domain configuration per deployment, 🔧 INT-003: AI services proxy support (TUNNEL_PROXY), 🔧 INT-004: Direct hosts file (Iran-aware NO_PROXY), 🔧 INT-005: Payment provider feature flags, 🔧 INT-006: Messenger feature flags (Telegram vs Bale), 🔧 INT-007: Language feature flags, 🔧 INT-008: Storage backend per region (+9 more)

### Community 3 - "Architecture"
Cohesion: 0.12
Nodes (16): A tunnel fails 2 consecutive quick checks, A tunnel passes basic checks but fails deep tests, After 2 hours, Architecture, Components, Cron jobs, Failure modes & recovery, HAProxy (+8 more)

### Community 4 - "English"
Cohesion: 0.14
Nodes (14): Architecture, Disclaimer, English, Features, Iran-specific design (default), IranserverTunel, License, Project documentation (+6 more)

### Community 5 - "Direct Commands"
Cohesion: 0.15
Nodes (12): Adding tunnels, Command Reference, Direct Commands, Interactive Mode, Listing / Status, Logs, Maintenance, Pause / Resume (+4 more)

### Community 6 - "README.md"
Cohesion: 0.24
Nodes (5): [1.0.0] - 2026-04-30, Added, Changelog, Known issues, Tested

### Community 7 - "Installation Guide"
Cohesion: 0.20
Nodes (10): Installation Guide, Requirements, Step 1: Install Xray-core, Step 2: Install tunnel-mgr, Step 3: First-time setup, Step 4: Set up API keys (optional, for deep tests), Step 5: Add your first tunnel, Step 6: Verify (+2 more)

### Community 8 - "Contributing"
Cohesion: 0.29
Nodes (6): Before submitting, Code style, Contributing, Local development, Reporting issues, Testing checklist

### Community 9 - "API Keys Setup"
Cohesion: 0.29
Nodes (6): API Keys Setup, How keys are used, Important security notes, Template, What if I don't want deep tests?, Where to get keys

### Community 10 - "Supported VLESS URL formats"
Cohesion: 0.33
Nodes (5): Currently supported, Not yet supported, Supported VLESS URL formats, VLESS over TCP with HTTP camouflage, VLESS over WebSocket (with camouflage)

## Knowledge Gaps
- **104 isolated node(s):** `install-xray.sh script`, `Added`, `Tested`, `Known issues`, `Before submitting` (+99 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Shahrzad Integration Guide` connect `Shahrzad Integration Guide` to `📋 فهرست تغییرات لازم`?**
  _High betweenness centrality (0.367) - this node is a cross-community bridge._
- **Why does `Technical Debt & Future Improvements` connect `Technical Debt & Future Improvements` to `README.md`?**
  _High betweenness centrality (0.238) - this node is a cross-community bridge._
- **Why does `📋 فهرست تغییرات لازم` connect `📋 فهرست تغییرات لازم` to `Shahrzad Integration Guide`?**
  _High betweenness centrality (0.206) - this node is a cross-community bridge._
- **What connects `install-xray.sh script`, `Added`, `Tested` to the rest of the system?**
  _104 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Technical Debt & Future Improvements` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._
- **Should `Shahrzad Integration Guide` be split into smaller, more focused modules?**
  _Cohesion score 0.11764705882352941 - nodes in this community are weakly interconnected._
- **Should `📋 فهرست تغییرات لازم` be split into smaller, more focused modules?**
  _Cohesion score 0.11764705882352941 - nodes in this community are weakly interconnected._