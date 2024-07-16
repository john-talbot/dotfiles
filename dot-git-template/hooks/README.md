# Git Hooks

## CTags
Taken directly from [TPope's "Effortless Ctags with Git"](https://tbaggery.com/2011/08/08/effortless-ctags-with-git.html)
This hook script will regenerate a ctags file whenever a git change occurs (i.e. checkout, commit, merge, etc.)

Execute the following command to make Git use these as template hooks when creating a new repository.

```sh
git config --global init.templatedir '~/.git-template'
```

Simply re-initializing an existing repository will add these hooks in.
```sh
git init
```
