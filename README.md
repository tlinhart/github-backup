# GitHub backup

Simple Bash script to backup GitHub repositories locally. The script clones
both public and private repositories but excluding forks. It also tries to clone
wikis if available.

To use it, set `BACKUP_DIR` (default `backup`) and `GITHUB_TOKEN` environment
variables and run the script.

Dependencies:
- curl
- jq
- git
