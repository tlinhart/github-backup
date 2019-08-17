# GitHub backup

Simple Bash script to backup GitHub repositories into the current directory. The script clones both public and private repositories but excluding forks. It also tries to clone wikis if available.

To use it, change the `TOKEN` variable in the script and run it.

Dependencies:
- curl
- jq
- git
