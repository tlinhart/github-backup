#!/usr/bin/env bash

DIR=$(cd "$(dirname "$0")"; pwd -P)

TOKEN=YOUR_TOKEN

echo "Working directory ${DIR}"
find ${DIR} -mindepth 1 -maxdepth 1 -type d | \
    xargs -I % sh -c "echo 'Deleting directory %'; rm -rf %"

cd ${DIR} && \
    curl -s -H "Authorization: token ${TOKEN}" \
               'https://api.github.com/user/repos?per_page=100' | \
    jq -r -c '.[] | select(.fork == false)' | \
    while read repo; do
        full_name=$(echo "${repo}" | jq -r '.full_name')
        clone_url=$(echo "${repo}" | \
                    jq -r '.clone_url' | \
                    sed -E "s|(https?://)(.*)|\1${TOKEN}@\2|")
        has_wiki=$(echo "${repo}" | jq -r '.has_wiki')

        git clone ${clone_url} ${full_name}
        if [ "${has_wiki}" == "true" ]; then
            wiki_clone_url=$(echo "${clone_url}" | \
                             sed -E "s/(.*)(\.git|$)/\1.wiki\2/")
            git clone ${wiki_clone_url} "${full_name}.wiki"
        fi
    done
