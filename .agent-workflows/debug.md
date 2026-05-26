---
description: debug pinchtab connection and state
---
1. Check Pinchtab Health
// turbo
```powershell
Invoke-RestMethod -Uri http://localhost:9867/health
```

2. List Active Tabs
```powershell
Invoke-RestMethod -Uri http://localhost:9867/tabs
```

3. Capture Interactive Snapshot (Efficient)
```powershell
Invoke-RestMethod -Uri "http://localhost:9867/snapshot?filter=interactive&format=compact"
```
