## Release Preflight Checklist
- [ ] Set N8N_BASE, LOG_SHEET_ID, NOTION_DB_ID, ALLOWED_HOSTS (README/specs placeholders updated)
- [ ] Import `n8n/workflow.json` and set credentials by name (OpenAI/Google/Notion)
- [ ] Run `n8n/tests/smoke.ps1` and `n8n/tests/acceptance.ps1`
- [ ] Confirm gated write returns `REVIEW_REQUIRED`; approved write appends a row
- [ ] Confirm HTTP allowlist denies non-HTTPS or unknown hosts (see acceptance tests)
- [ ] Package with `scripts/pack.ps1` (ensures CRLF in ZIP)

## Demo Scripts
- **Gated write**: POST with `needsApproval` → expect `REVIEW_REQUIRED`
- **Approved write**: resend with `"approve": true` → appended row
- **Allowlist denial**: force a planner path to `http.request` with an unapproved host → expect error envelope
