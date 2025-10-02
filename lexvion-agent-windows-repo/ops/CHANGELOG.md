# Changelog

All notable changes to this project will be documented in this file.  
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] – 2025‑10‑02

### Added

- Initial release of the Lexvion Agent scaffold tailored for Windows environments.
- Strict JSON contract and planner rules defined in `prompts/system.md`.
- Minimal n8n workflow with webhook, validation, planner, gating, routing, tool execution, logging and response assembly.
- PowerShell smoke and acceptance tests in `n8n\tests`.
- Helper scripts for setup (`scripts/setup.ps1`), development (`scripts/dev.ps1`) and packaging (`scripts/pack.ps1`).
- GitHub Actions workflow for validation on Windows and Ubuntu runners.
- Operational runbook and guardrails in `prompts/runbook.md` and `specs/agent.yaml`.