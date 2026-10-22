---
name: ship
description: Take MyHealthKit working-tree changes through the project's source-control workflow — create a branch off main, verify the build, split changes into Conventional Commits, and optionally push and open a pull request. Use when the user asks to commit, ship, create a branch, push, or open a PR for their changes.
argument-hint: [branch-name] [--push] [--pr]
---

# Ship Changes

Arguments: $ARGUMENTS

Follow the **Source control** rules in the repo's `CLAUDE.md` (branch names, commit format, files
that must never be committed).

## Steps

1. **Inspect** — Run `git status`, `git diff` and `git diff --cached`, and list untracked files.
   If there is nothing to commit, say so and stop.

2. **Safety check** — Make sure none of these are staged or about to be: `MyHealthKit/Secrets.xcconfig`,
   `xcuserdata/`, `DerivedData/`, `.claude/settings.local.json`, or anything that looks like an API
   key or token in the diff. If one is, stop and tell the user — don't commit it.

3. **Branch** — If on `main`, create a branch first: use the name from the arguments, otherwise
   derive one from the changes (`feature/…`, `fix/…`, `refactor/…`, `chore/…`, `docs/…`). Show the
   name. If already on a non-`main` branch, stay on it.

4. **Build** — Run the build command from `CLAUDE.md`. If it fails, stop and report the errors;
   don't commit a broken build.

5. **Plan the commits** — Group the changes into logical commits (one concern each: a feature, a
   refactor, a fix, tooling/docs). Show the user the plan — each commit's message and files — before
   committing. A file with changes for two concerns can only be split by hunk; if that isn't clean,
   put it in the commit it belongs to most and mention it.

6. **Commit** — For each group: stage exactly its files (`git add -- <paths>`; never `git add -A`
   or `git add .`), then commit with a Conventional Commit message:

   ```
   <type>(<scope>): <imperative summary, ≤ 72 chars>

   <why, if not obvious>

   <attribution trailer required by the session, if any>
   ```

   Use a heredoc for multi-line messages. After the last commit, `git status` must be clean
   (apart from intentionally ignored files).

7. **Push** — only if the user asked (`--push`, "push", "open a PR"): `git push -u origin <branch>`.
   Never push to `main`, never force-push.

8. **Pull request** — only if asked (`--pr`): needs the GitHub CLI (`gh`). If it's missing, give the
   compare URL `https://github.com/Liji-S/MyHealthKit/compare/main...<branch>` instead. PR body:
   summary, list of commits, how it was verified (build, tests, manual checks), and anything a
   reviewer should look at closely (e.g. EmergencySOS call-path changes).

9. **Report** — branch name, commits created (hash + message), and whether anything was pushed.
