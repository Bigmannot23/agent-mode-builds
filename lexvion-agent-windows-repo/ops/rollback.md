# Rollback Procedures

In the event that a change needs to be reverted, follow these steps:

1. **Identify the target state.** Determine the git commit hash or tag that represents the desired state.  
   Use `git log` or view the history in your Git hosting provider.

2. **Check out the commit locally.**
   ```
   git checkout <commitHash>
   ```
   To revert on a branch, you can use `git revert` to create a new commit that undoes the changes.

3. **Import workflow into n8n.** If the workflow has changed, re‑import the appropriate `n8n/workflow.json` into your n8n instance and reconnect credentials by name.  
   Ensure that no secrets are inadvertently changed.

4. **Re‑run tests.** Execute `n8n\tests\smoke.ps1` to verify the reverted state behaves as expected.

5. **Update the build log.** Append an entry to `ops/build_log.md` describing the rollback and the reason for it.

Always review the impact of reverting a change, especially if it involves schema updates or external side effects. If in doubt, consult a senior operator.