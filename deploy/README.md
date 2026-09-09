# Scheduled sync

`scripts/scheduled-sync.sh` refreshes the published skills from `~/.claude/skills/` every ~2 weeks. It runs the allowlist sync + scan, and only if the scan is clean and something changed, opens a **draft PR** against `main`. It never pushes to `main` on its own.

## Install (macOS, launchd)

```bash
cp deploy/com.dvnrsn.claude-skills-sync.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.dvnrsn.claude-skills-sync.plist
```

Run once now to check it works:

```bash
launchctl start com.dvnrsn.claude-skills-sync
cat /tmp/claude-skills-sync.log
```

Uninstall:

```bash
launchctl unload ~/Library/LaunchAgents/com.dvnrsn.claude-skills-sync.plist
rm ~/Library/LaunchAgents/com.dvnrsn.claude-skills-sync.plist
```

`StartInterval` fires 14 days after load and every 14 days after that (on wake if the Mac was asleep). Needs `gh` authenticated for the draft-PR step.
