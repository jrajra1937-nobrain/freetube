# Upstream maintenance

## Baseline and update policy

Upstream is `https://github.com/leshkodev/freetube`; local `origin/main` was `8fc6d3b7be9571e3ffcb179de3d1de2dfe7012e7` at audit time. The current checkout retains that upstream remote. Do not push personal work to the upstream owner's repository.

Keep a personal fork/branch for customization. Fetch upstream changes, inspect the commit range and file diffs, then integrate reviewed changes on a separate update branch. Do not automatically merge unreviewed upstream commits into the personal main branch.

```sh
git fetch origin --tags
git log --oneline --decorate HEAD..origin/main
git diff --stat HEAD...origin/main
git diff --find-renames HEAD...origin/main
```

After manually resolving and reviewing the diff, run the manual iOS workflow, inspect artifact logs, and merge only when the build is green and the changes are understood. Retain the known-good commit and revert with a normal reviewed revert commit if a regression appears.

## Dependency policy

Preserve `Package.resolved` in source control. Review package release notes and diffs before updating package pins. Several dependencies currently resolve from mutable branches; record the resolved revisions and move to audited version/revision pins when feasible.

## Scheduled checks

There is no automatic upstream polling workflow. This avoids spending Actions minutes unexpectedly and avoids merging changes without review. Upstream comparison is currently a manual operation.
