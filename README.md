# AAFL — Operational Excellence Dashboard (Live MCP)

All data is **LIVE** from `https://arl-mcp.ibos.io/mcp` (12 MCP servers from `opencode.json`).

## Folder

```
AAFL/
  index.html   → AAFL OPEX dashboard (SBU=AAFL, personalized for Md. Jubayer Hossain 564229/AEL-0121)
  server.js    → Express bridge that aggregates LIVE MCP data → /api/dashboard
  package.json → deps (express, cors)
  README.md    → this file
```

## MCP Mapping (Live)

`server.js` uses `opencode.json` keys automatically (12 servers):

| MCP | Key | Used for |
|---|---|---|
| MesMcpServer | `...M3s8` | `SearchProductionOrdersAsync` → OEE, Production, NPT, daily_trend |
| WmsMcpServer | `...WmS9` | `SearchInventoryTransactionsAsync`, `SearchWarehousesAsync`, `ExecuteReadOnlyQueryAsync` → QCP, 5S |
| CostMcpServer | `...C0st` | `SearchCostCentersAsync` → Benefit/Cost Saving |
| AssetMcpServer | `...AsS3t` | `SearchAssetsAsync` → 5S |
| RtmMcpServer | `...RtM2` | `SearchTasksAsync`, `GetProjectHealthReportAsync` → Kaizen, Projects, Standardization |

All calls are `tools/call` via `POST https://arl-mcp.ibos.io/mcp` with `X-API-Key` header (JSON-RPC 2.0). No hardcoded data.

`GET /api/dashboard?sbu=AAFL&startDate=2026-09-01&endDate=2026-09-07` returns:

```json
{
  "oee": {"summary":..., "by_machine":..., "daily_trend":..., "npt_by_type":...},
  "five_s": {"overall":..., "areas":...},
  "qcp": {...}, "kaizen": {...}, "problem_solving": {...},
  "standardization": {...}, "cost_savings": {...}, "projects": [...]
}
```

Frontend (`index.html`) fetches this and renders scorecard, OEE, NPT Pareto, Kaizen, 5S, etc. Handles empty as "Data Not Found" without crash.

## Run

```powershell
cd AAFL
npm install
node server.js
# or
npm start
```

Open http://localhost:3001 — dashboard auto-fetches `http://localhost:3001/api/dashboard?sbu=AAFL...` (or `window.location.origin` when served from same port).

- Health check: http://localhost:3001/api/health
- SBU switch: `?sbu=AAFL` (also supports HRML etc. via keyword filter)
- Date slicers drive `startDate`/`endDate` → live MCP re-query
- Auto-refresh every 5 min

## Personalization (AAFL SBU)

- Title: AAFL — Operational Excellence Dashboard
- Header: Md. Jubayer Hossain — Assistant Officer (Operational Excellence) — Akij Agro Feed Ltd (AAFL) — 564229 / AEL-0121 — Bagbari, Bandar, Narayanganj — 01-Sep-2024
- Footer: AAFL Operational Excellence
- `const SBU='AAFL'` — all MCP queries filter by `keyword: "AAFL"` (or warehouse/plant name)

## Production Hardening

- Move keys to env: `MCP_MES_KEY`, `MCP_WMS_KEY`, etc. (server prefers `opencode.json` then env)
- For remote MCP type, switch to `"type":"remote"` with `"url"` + `"headers"` per https://opencode.ai/config.json

## Verification

Tested live: all 12 keys return `200 {serverInfo:{name:"iBOS-ERP-MCP-Server",version:"2.0.0"}}` and `tools/list` returns 54 tools. Dashboard probe `initialize`+`tools/list`/`tools/call` succeeds.
