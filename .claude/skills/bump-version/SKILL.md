---
name: bump-version
description: Bump $VERSION in every .pm under lib/, update the POD =head1 VERSION prose in lib/Template.pm, and regenerate README.md via pod2markdown. Use when the maintainer is cutting a release. Takes the new version (e.g. /bump-version 3.104) and optionally --date YYYY-MM-DD (defaults to today).
---

# bump-version

End-to-end version bump for a Template Toolkit release:

1. Rewrites `our $VERSION = '...'` in every `.pm` file under `lib/`.
2. Rewrites the `=head1 VERSION` prose line in `lib/Template.pm`
   (`Template Toolkit version X.YYY, released on Month D YYYY.`).
3. Regenerates `README.md` by running `pod2markdown lib/Template.pm > README.md`.

## How to invoke

The user will typically say "bump version to X.Y" or invoke as `/bump-version X.Y`.

```bash
perl .claude/skills/bump-version/bump_version.pl <new-version>
perl .claude/skills/bump-version/bump_version.pl --date 2026-06-01 3.104
perl .claude/skills/bump-version/bump_version.pl --dry-run 3.104
```

Flags:

- `--dry-run` / `-n` — preview every change without writing files or running pod2markdown.
- `--date YYYY-MM-DD` — release date used in the POD prose line. Defaults to today.

## Argument format

- Version must match `/^\d+\.\d+(_\d+)?$/` (e.g. `3.104`, `3.104_01`).
- Date must be `YYYY-MM-DD`. The script formats it for the POD as `Month D YYYY`
  (e.g. `2026-06-01` → `June 1 2026`).

## Behavior notes

- Files without a `$VERSION` declaration (e.g. `lib/Template/Stash/XS.pm`, which
  delegates to `$Template::VERSION` via XSLoader) are reported as skipped.
- Files already at the target version are reported as unchanged, not rewritten.
- Existing whitespace and quote style around `$VERSION = '...'` are preserved.
- `pod2markdown` must be on `$PATH`. If it fails, the script reports the failure
  but leaves the `.pm` changes in place (rerun pod2markdown manually to recover).

## Out of scope

`Changes`, `RELEASE`, and `META*` files are maintainer/build-tool controlled and
intentionally not touched. See CLAUDE.md.
