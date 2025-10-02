## Operator Runbook

This runbook outlines the human‑in‑the‑loop (HITL) process for maintaining and evolving the Lexvion Agent scaffold on Windows.

### Process Overview

1. **Inspect Current State**  
   - Open `specs/agent.yaml`, `n8n/workflow.json`, and `ops/build_log.md`.  
   - Summarize the current configuration, version and any recent changes.

2. **Plan a Change**  
   - Propose a **small, reversible** modification: update a prompt, adjust the allowlist, add a test, etc.  
   - Include the risk/impact analysis and a brief rollback plan.

3. **Prepare a Diff**  
   - Provide a unified diff showing the exact file changes.  
   - Wait for approval from the designated reviewer before proceeding.

4. **Apply the Change**  
   - After approval, edit the files locally or via a pull request.  
   - Import `n8n/workflow.json` into n8n if the workflow changed and wire up the credentials (OpenAI, Google, Notion) by name; never commit secrets.

5. **Test**  
   - Run `n8n\tests\smoke.ps1` using `$env:N8N_BASE` pointing at your n8n instance.  
   - Ensure all smoke tests pass on Windows.  
   - Optionally run `n8n\tests\acceptance.ps1` for deeper validation.

6. **Persist**  
   - Commit your changes with a descriptive message starting with `delta:`.  
   - Append an entry to `ops/build_log.md` summarizing the change, date and operator.  
   - Update `ops/CHANGELOG.md` following semantic versioning (major.minor.patch).

### Guardrails

- **No Secrets:** Never store API keys or tokens in git. Use named credentials in n8n.  
- **Strict Contracts:** Enforce the JSON contract defined in `specs/agent.yaml` and `prompts/system.md`.  
- **Allowlist Enforcement:** HTTP requests must target hosts in `http_allow_hosts`. Expand this list cautiously.  
- **HITL for Side‑Effects:** Planner outputs with `args.needsApproval=true` require the incoming request to include `"approve": true`; otherwise respond with `status:"REVIEW_REQUIRED"`.

Follow this runbook to ensure safe, auditable evolution of the agent. When in doubt, ask for clarification before committing a change.