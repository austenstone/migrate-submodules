# Migrate Submodules

This is a small script to migrate submodules recursively using [sed](https://man7.org/linux/man-pages/man1/sed.1p.html). 

You can run this script in any git repository and it will recursively itterate submodules and perform the following operations:
1. Preform the sed command provided via `-s` on .gitmodules
2. Synchronizes submodules' remote URL configuration setting to the value specified in .gitmodules
3. Updates(pulls) all submodules.
4. Commits the changes to the branch specified using the `-b` with the message provided via `-m`

#### NOTES
- You must have read/write permission on the repositories you are modifying
- This script will not import repositories for you and assumes all required repositories have already been imported to your target. This means if you are replacing the url of a submodule, the new URL must be pointing to a valid repository.

## Usage 🏃‍♂️
Clone your repo that contains submodules and cd inside:
```bash
git clone https://github.com/austenstone/main-test1.git
cd main-test1
```

Run the script. Example is migrating the url from `bitbucket.org` to `github.com`:
```bash
migrate-submodules.sh -s 's/bitbucket.org/github.com/g' -b 'master'
```

To push your changes to remote:
```bash
git submodule foreach --recursive git push origin master
git push origin master
```

You can automatically sync all branches with master by running the following command:
```bash
for BRANCH in `ls .git/refs/heads`; do git rebase master $BRANCH; done
git push --all origin
```

## Install ⬇️
```bash
cd /usr/local/bin
curl https://raw.githubusercontent.com/austenstone/migrate-submodules/main/migrate-submodules.sh > migrate-submodules.sh
chmod +x migrate-submodules.sh
```
Script tested on Ubuntu and MacOS.

## [main-test1](https://github.com/austenstone/main-test1) repo hierarchy
main-test1 is the root of a small set of repos and is used to test the functionality.
```mermaid
graph TD;
    main-test1-->child-test1;
    child-test1-->child-test1-child ;
    main-test1-->child-test2;
```

## Possible Improvements 🚧
- Use `set-url [--] <path> <newurl>` instead of sed.
- Sync all branches in the script
- Dynamically get the default branch using `git remote show origin | sed -n '/HEAD branch/s/.*: //p'`

## Inspiration ✨
- [Enteee/git-submodule-url-rewrite](https://github.com/Enteee/git-submodule-url-rewrite)
