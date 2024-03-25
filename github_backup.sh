#!/usr/bin/env bash

SCRIPT_DIR=$(
  cd "$(dirname "$0")"
  pwd -P
)

DIR=${BACKUP_DIR:-${SCRIPT_DIR}/backup}
TOKEN=${GITHUB_TOKEN:-your-github-token}

echo "Working directory ${DIR}"
mkdir -p ${DIR}
find ${DIR} -mindepth 1 -maxdepth 1 -type d \
  | xargs -I % sh -c "echo 'Deleting directory %'; rm -rf %"

all_repos=""
page=1
while true; do
  repos=$(curl -s -H "Authorization: token ${TOKEN}" \
    "https://api.github.com/user/repos?per_page=100&page=${page}" \
    | jq -r -c '.[]')
  if [ -n "${repos}" ]; then
    all_repos="${all_repos}"$'\n'"${repos}"
    page=$((page + 1))
  else
    break
  fi
done
filtered_repos=$(echo "${all_repos}" \
  | jq -r -c '. | select(.fork == false)')

ok_count=0
failed_count=0

cd ${DIR}
while read repo; do
  full_name=$(echo "${repo}" | jq -r '.full_name')
  clone_url=$(echo "${repo}" \
    | jq -r '.clone_url' \
    | sed -E "s|(https?://)(.*)|\1${TOKEN}@\2|")
  has_wiki=$(echo "${repo}" | jq -r '.has_wiki')

  echo -n "Cloning ${full_name} ... "
  git clone ${clone_url} ${full_name} > /dev/null 2>&1
  if [ $? == 0 ]; then
    echo "OK"
    ok_count=$((ok_count + 1))
  else
    echo "Failed"
    failed_count=$((failed_count + 1))
  fi

  if [ "${has_wiki}" == "true" ]; then
    wiki_clone_url=$(echo "${clone_url}" \
      | sed -E "s/(.*)(\.git|$)/\1.wiki\2/")

    echo -n "Cloning ${full_name}.wiki ... "
    git clone ${wiki_clone_url} "${full_name}.wiki" > /dev/null 2>&1
    if [ $? == 0 ]; then
      echo "OK"
      ok_count=$((ok_count + 1))
    else
      echo "Failed"
      failed_count=$((failed_count + 1))
    fi
  fi
done <<< ${filtered_repos}

echo "OK: ${ok_count} | Failed: ${failed_count}"
