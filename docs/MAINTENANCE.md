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

Review the upstream diff before merging anything. Push only reviewed code to `dev/personal-edition`; its CI build runs automatically. Inspect build logs/artifacts before promoting any change to the fork's default branch. Retain the known-good commit and use a reviewed revert commit if a regression appears.

## Dependency policy

Preserve `Package.resolved` in source control. Review package release notes and diffs before updating package pins. Several dependencies currently resolve from mutable branches; record the resolved revisions and move to audited version/revision pins when feasible.

## Scheduled checks

There is no automatic upstream polling workflow. Upstream comparison is currently a manual operation so updates are not merged without review. Standard macOS runners are free on public repositories; this workflow runs only for pushes to the development branch or an explicit manual dispatch.
