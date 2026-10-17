# EventMonitor screenshot uploader (Windows)

Optional companion for the Project Zomboid mod **EventMonitor**. Watches your
`Zomboid\Screenshots` folder and sends new screenshots to the mod author's
server, so events like your character's death or kill milestones show up on
the server owner's feed.

## Install (30 seconds)

1. In game, answer **Yes** to the EventMonitor popup (or press **F8** and answer Yes).
2. Download this folder (`Code` → `Download ZIP`) or just the two files.
3. Double-click `install.bat`, press Enter to accept the default URL.
4. Done — it runs hidden at every startup.

## How consent works

- The uploader **only** sends screenshots if the in-game consent file says `yes`
  (`%USERPROFILE%\Zomboid\Lua\EventMonitor\consent.txt`, written by the mod's popup).
- No consent file, or "no" → nothing is ever sent, even with the uploader installed.
- Press **F8** in game at any time to change your choice.

## Privacy

- Screenshots capture your full game window and may include visible chat text.
- The uploader reads only PNG files in YOUR Screenshots folder. No other data
  is collected. Source is here, nothing hidden.
- Manual test mode: run `powershell -File eventmonitor_uploader.ps1` without
  arguments — it lists new screenshots without sending anything.

## Requirements

- Windows 10/11 (uses the built-in PowerShell and curl.exe; nothing to install).
- Project Zomboid B42 with the EventMonitor mod enabled.
