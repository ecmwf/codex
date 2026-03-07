# Adjust the blame history after applying the clang-format file

The following refs can be ignored by git blame if 'git blame' is called with
`--ignore-revs-file .git-blame-ignore-revs`

Alternatively configure git to always ignore refs stored in this file by calling
`git config blame.ignoreRevsFile .git-blame-ignore-revs`
or extend your git config manually with
```
[blame]
ignoreRevsFile = .git-blame-ignore-revs
```

# What to do:
- Reformat codebase with clang-format
- Take the commit hash of the format commit, aka <commit-hash>
- Create a `.git-blame-ignore-revs` file in the repository
- Save the <commit-hash> in that file

As a reference, see e.g. [FDB](https://github.com/ecmwf/fdb/blob/develop/.git-blame-ignore-revs)
