# Lexvion Agent Scaffold (Windows)

This repository contains a Windows‑first implementation of the **Lexvion Agent** using
Agent Mode × n8n. It provides a strict JSON planning contract, human‑in‑the‑loop
approvals, audit logging, and a minimal n8n workflow. The repository is designed
to be production ready on Windows 11 and includes PowerShell scripts for
installation, testing and packaging.

## Contents

The top‑level structure is as follows:

| Path                        | Purpose                                        |
|-----------------------------|------------------------------------------------|
| `specs/agent.yaml`          | Configuration with placeholders for n8n base URL, log sheet and Notion DB. Defines allowed tools and allowlists. |
| `prompts/system.md`         | System prompt for the planner enforcing a strict JSON contract and safety rules. |
| `prompts/runbook.md`        | HITL runbook for operators: how to propose, approve and apply changes safely. |
| `n8n/workflow.json`         | Minimal n8n workflow implementing webhook → validation → planning → gating → routing → tool execution → logging → response. |
| `n8n/tests/*.ps1`           | PowerShell smoke and acceptance tests against the webhook endpoint. |
| `scripts/setup.ps1`         | Installs prerequisites via winget (jq, GitHub CLI) and sets execution policy. |
| `scripts/dev.ps1`           | Helper functions to set environment variables and start/stop a local n8n instance. |
| `scripts/pack.ps1`          | Packages the repository into `dist/lexvion-agent-windows-repo.zip`. |
| `.github/workflows/validate.yml` | GitHub Actions workflow to lint JSON and run smoke tests on Windows and Ubuntu. |
| `ops/`                      | Operational docs: build log, rollback guide and changelog. |

## Quickstart (Windows 11)

1. **Install prerequisites**. Open a PowerShell 7+ terminal and run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1
   ```
   This sets a permissive execution policy and installs `jq` and the GitHub CLI via winget if they are missing.

2. **Import the workflow** into n8n. Log into your n8n instance and import `n8n/workflow.json`. Create named credentials for OpenAI, Google and Notion; the workflow references them by name only. Do not hard‑code secrets.

3. **Prepare the log sheet**. Create a Google Sheet with a tab named `Logs` and columns:
   `timestamp`, `user`, `clientId`, `tool`, `status`, `tokens`, `latency`. Note the sheet ID.

4. **Set environment variables**. In your terminal:
   ```powershell
   $env:N8N_BASE = "https://<your-n8n-host>"
   $env:LOG_SHEET_ID = "<google-sheet-id>"
   $env:NOTION_DB_ID = "<notion-db-id>"
   ```

5. **Run smoke tests**. Verify the workflow behaves correctly:
   ```powershell
   .\n8n\tests\smoke.ps1
   ```
   All tests should report `PASS`. Use `n8n\tests\acceptance.ps1` for additional schema checks.

6. **Package the repository** (optional). To create a ZIP for distribution:
   ```powershell
   .\scripts\pack.ps1
   ```
   The archive will be written to the `dist` directory as `lexvion-agent-windows-repo.zip`.

## Upwork Packaging Notes

When delivering this project via Upwork or a similar platform:

- Ensure no secrets or API keys are included in the repository. All sensitive values
  should be provided via environment variables or n8n credentials.
- Run `scripts/pack.ps1` to produce `lexvion-agent-windows-repo.zip`. Upload this
  archive as the deliverable.
- Provide instructions in your submission on how to import the workflow, set
  environment variables and run tests.

## Development Tips

- Use `scripts/dev.ps1` to set `N8N_BASE`, start a local n8n instance (`Start-N8nLocal`) and display environment variables (`Show-Env`).
- Follow the runbook (`prompts/runbook.md`) when proposing changes. All modifications should be small, reversible and approved by a reviewer. Update `ops/build_log.md` and `ops/CHANGELOG.md` accordingly.
- CI checks in `.github/workflows/validate.yml` will lint JSON and execute the smoke tests on Windows and Ubuntu. Make sure these pass before opening a pull request.

## License

This project is licensed under the MIT License. See `LICENSE` for details.