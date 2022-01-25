#!/bin/bash

submodule_url_rewrite() {
    if [ -e ".gitmodules" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' $SED_COMMAND .gitmodules # MacOS sed works different
        else
            sed -i $SED_COMMAND .gitmodules
        fi
        git submodule sync
        git add .gitmodules
        git commit -m "${COMMIT_MESSAGE}"
        # We can update the submodules because they are now pointing at the correct place
        git submodule update --init --remote
        git submodule foreach "git pull origin ${BRANCH_NAME} && git checkout ${BRANCH_NAME}"
    fi
}

recurse_submodules() {
    submodule_url_rewrite
    for submodule in $(git config --file .gitmodules --get-regexp path | awk '{print $2}'); do
        cd $submodule
        recurse_submodules
        cd ..
    done
}

show_help() {
    echo "Usage:
    migrate-submodules.sh [options]

    Options:
    -s <submodule>
        sed command to rewrite .gitmodules submodule urls
        example: -s 's/bitbucket.org/github.com/g'
    -b <branch>
        branch where submodule migrations should be done
        example: -b 'master'
    -m <commit message>
        commit message for submodule migrations
        example: -m 'Migrate submodules to github'
    -h
        Show this help message and exit.
    -v
        Show verbose output."
}

OPTIND=1 # Reset in case getopts has been used previously in the shell.
while getopts ":hvs:b:m:" opt; do
    case "$opt" in
    s)
        SED_COMMAND=$OPTARG
        ;;
    b)
        BRANCH_NAME=$OPTARG
        ;;
    m)
        COMMIT_MESSAGE=$OPTARG
        ;;
    v)
        set -x
        ;;
    h)
        show_help
        exit 0
        ;;
    *)
        echo "Unknown options ${opt}"
        ;;
    esac
done

BRANCH_NAME=${BRANCH_NAME:="master"}
COMMIT_MESSAGE=${COMMIT_MESSAGE:="Migrated submodules"}
if [ -z "$SED_COMMAND" ]; then
    echo "No sed command supplied."
    show_help
    exit 1
fi

echo "Migrating submodules on branch '${BRANCH_NAME}' using sed command '${SED_COMMAND}'"
recurse_submodules
