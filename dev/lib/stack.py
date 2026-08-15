#!/usr/bin/env python3

"""VSCodium patch-stack orchestration over the vendored Electron core."""

import argparse
import os
import shutil
import subprocess
import sys

# Pin the diff knobs so a user's git config cannot change the exported bytes.
for _i, (_k, _v) in enumerate((
    ("diff.algorithm", "myers"), ("diff.context", "3"), ("diff.indentHeuristic", "true"))):
    os.environ["GIT_CONFIG_KEY_%d" % _i] = _k
    os.environ["GIT_CONFIG_VALUE_%d" % _i] = _v
os.environ["GIT_CONFIG_COUNT"] = "3"

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import git as egit          # vendored Electron core
import patches as epatches  # vendored Electron core
from patches import PATCH_DIR_PREFIX, PATCH_FILENAME_PREFIX

BASE_REF = "refs/vscodium/base"
HEAD_REF = "refs/vscodium/head"
PATCH_TYPE_PREFIX = "Patch-Type: "
COMMITTER_NAME = "VSCodium"
COMMITTER_EMAIL = "scripts@vscodium.com"
GIT_CONFIG = [
    "-c", "user.name=" + COMMITTER_NAME,
    "-c", "user.email=" + COMMITTER_EMAIL,
    "-c", "commit.gpgsign=false",
    "-c", "core.hooksPath=/dev/null",
]


def _fail(message):
    sys.stderr.write(message.rstrip("\n") + "\n")
    sys.exit(1)


def _git(repo, *args, capture=True):
    cmd = ["git", "-C", repo, *args]
    if capture:
        return subprocess.check_output(cmd, text=True)
    subprocess.check_call(cmd)
    return None


def _git_c(repo, *args):
    subprocess.check_call(["git", "-C", repo, *GIT_CONFIG, *args])


def build_dirs(patches_root, quality, os_name):
    dirs = [patches_root]
    if quality == "insider":
        dirs.append(os.path.join(patches_root, "insider"))
    if os_name:
        dirs.append(os.path.join(patches_root, os_name))
    dirs.append(os.path.join(patches_root, "user"))
    return [d for d in dirs if os.path.isdir(d)]


def user_dir(patches_root):
    return os.path.join(patches_root, "user")


def _apply_json_removals(repo, patches_root):
    import json as _json
    for name in sorted(os.listdir(patches_root)):
        if not name.endswith(".json"):
            continue
        path = os.path.join(patches_root, name)
        with open(path, encoding="utf-8") as f:
            actions = _json.load(f)
        repo_abs = os.path.abspath(repo)
        removed = []
        for action in actions:
            if action.get("action") != "remove":
                _fail(f"{path}: unsupported action {action.get('action')!r}")
            for rel in action["paths"]:
                # Confine rm -rf to the repo: a crafted absolute/../ path must not escape vscode/.
                target = os.path.abspath(os.path.join(repo, rel))
                if os.path.isabs(rel) or os.path.relpath(target, repo_abs).split(os.sep)[0] == "..":
                    _fail(f"{path}: removal path escapes the repo: {rel}")
                if not os.path.exists(target):
                    _fail(f"{path}: path to remove does not exist: {rel}")
                if os.path.isdir(target) and not os.path.islink(target):
                    shutil.rmtree(target)
                else:
                    os.remove(target)
                removed.append(rel)
        _git(repo, "add", "-A", "--", *removed)
        subject = name[: -len(".json")]
        message = (
            f"{subject}\n\n"
            f"{PATCH_DIR_PREFIX}{patches_root}\n"
            f"{PATCH_FILENAME_PREFIX}{name}\n"
            f"{PATCH_TYPE_PREFIX}json\n"
        )
        _git_c(repo, "commit", "--no-verify", "-q", "-m", message)


def patch_order(d):
    """Apply order for a directory: its .patches manifest, which must list every
    .patch file present. A directory with no manifest falls back to lexical order."""
    manifest = os.path.join(d, ".patches")
    ondisk = sorted(f for f in os.listdir(d) if f.endswith(".patch"))
    if not os.path.exists(manifest):
        return ondisk
    with open(manifest, encoding="utf-8") as f:
        listed = [ln.rstrip("\n") for ln in f.readlines()]
    for name in listed:
        if not name or name != name.strip() or os.path.basename(name) != name or not name.endswith(".patch"):
            _fail(f"{d}/.patches has an invalid entry: {name!r}; run ./dev/export.sh.")
        if not os.path.exists(os.path.join(d, name)):
            _fail(f"{d}/.patches lists a file not on disk: {name}\n"
                  f"Remove that line from {os.path.join(d, '.patches')}, or restore the file "
                  f"(git checkout -- {os.path.join(d, name)}).")
    unlisted = [f for f in ondisk if f not in set(listed)]
    if unlisted:
        _fail(
            f"{d}: patch file(s) missing from .patches: {', '.join(unlisted)}.\n"
            f"Add them to {os.path.join(d, '.patches')} in apply order, or remove the file(s)."
        )
    return listed


def _is_mailbox(path):
    with open(path, "rb") as f:
        return f.readline().startswith(b"From ")


def _mid_operation(repo):
    """True while git is part-way through an am or rebase in the clone, when its
    commits do not represent patches/."""
    git_dir = _git(repo, "rev-parse", "--absolute-git-dir").strip()
    return any(os.path.isdir(os.path.join(git_dir, d))
               for d in ("rebase-apply", "rebase-merge"))


def _stack_dirs_path(repo):
    return os.path.join(_git(repo, "rev-parse", "--absolute-git-dir").strip(),
                        "vscodium-stack-dirs")


def _abandon_stack(repo):
    """A half-imported clone reproduces no patch set: drop the tip and the reuse
    fingerprint so the next build re-imports instead of shipping a truncated stack."""
    subprocess.call(["git", "-C", repo, "update-ref", "-d", HEAD_REF],
                    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    git_dir = _git(repo, "rev-parse", "--absolute-git-dir").strip()
    for name in ("vscodium-patches-hash", "vscodium-stack-dirs"):
        try:
            os.remove(os.path.join(git_dir, name))
        except OSError:
            pass


def _am_one(repo, d, name):
    try:
        egit.am(repo=repo, patch_data=epatches.read_patch(d, name), threeway=True,
                committer_name=COMMITTER_NAME, committer_email=COMMITTER_EMAIL)
    except Exception as exc:
        subprocess.call(["git", "-C", repo, "am", "--abort"],
                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        _fail(f"failed to apply {os.path.join(d, name)}: {exc}\n"
              f"Fix that patch file, then re-run the build.")


def _apply_plain(repo, d, name):
    path = os.path.abspath(os.path.join(d, name))
    # --index stages exactly what the diff touches, renames included.
    try:
        subprocess.check_call(["git", "-C", repo, "apply", "--index",
                               "--ignore-whitespace", path])
    except subprocess.CalledProcessError as exc:
        _fail(f"failed to apply {os.path.join(d, name)}: {exc}")
    message = (
        f"{name[: -len('.patch')]}\n\n"
        f"{PATCH_DIR_PREFIX}{d}\n"
        f"{PATCH_FILENAME_PREFIX}{name}\n"
    )
    _git_c(repo, "commit", "--no-verify", "-q", "-m", message)


def import_stack(repo, patches_root, quality=None, os_name=None, dirs=None):
    # Leftover am/rebase state would wedge the import; --quit clears it without moving HEAD.
    for op in (["am", "--abort"], ["rebase", "--quit"]):
        subprocess.call(["git", "-C", repo, *op],
                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    _require_base(repo)
    # Drop the tip before touching anything: a kill -9 mid-import must not leave a ref
    # claiming patches/ reproduces a stack that is only half applied.
    subprocess.call(["git", "-C", repo, "update-ref", "-d", HEAD_REF],
                    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    _git_c(repo, "reset", "-q", "--hard", BASE_REF)
    try:
        _apply_json_removals(repo, patches_root)
        if dirs is None:
            dirs = build_dirs(patches_root, quality, os_name)
        for d in dirs:
            for name in patch_order(d):
                if _is_mailbox(os.path.join(d, name)):
                    _am_one(repo, d, name)
                else:
                    _apply_plain(repo, d, name)
    except BaseException:
        _abandon_stack(repo)
        raise
    egit.update_ref(repo=repo, ref=HEAD_REF, newvalue="HEAD")
    with open(_stack_dirs_path(repo), "w", encoding="utf-8") as f:
        f.write("".join(d + "\n" for d in dirs))
    n = egit.get_commit_count(repo, BASE_REF + "..HEAD")
    print(f"imported {n} commits ({BASE_REF}..HEAD)")


def _trailer(patch_lines, prefix):
    for line in patch_lines:
        if line.startswith(prefix):
            return line[len(prefix):].rstrip("\n")
    return None


def _require_base(repo):
    base = subprocess.run(["git", "-C", repo, "rev-parse", "--verify", "-q", BASE_REF],
                          capture_output=True, text=True).stdout.strip()
    if not base:
        _fail(f"{repo}/ was not created by this tooling ({BASE_REF} is missing).\n"
              f"Move it aside and run ./dev/build.sh to make a fresh clone.")
    return base


def export_stack(repo, patches_root, dry_run=False, verify=True,
                 quality=None, os_name=None):
    base = _require_base(repo)
    # format-patch silently drops a merge's delta; require a linear stack.
    merges = _git(repo, "rev-list", "--merges", base + "..HEAD").strip()
    if merges:
        _fail("the patch stack must be linear; found merge commit(s):\n" + merges)
    # Only a fully imported stack may rewrite patches/; a truncated one would erase it.
    tip = subprocess.run(["git", "-C", repo, "rev-parse", "--verify", "-q", HEAD_REF],
                         capture_output=True, text=True).stdout.strip()
    if not tip or _mid_operation(repo):
        _fail("vscode/ does not hold a fully imported patch stack; refusing to rewrite "
              "patches/.\nFinish or abort the rebase/am in vscode/, or run ./dev/build.sh "
              "to re-import.")

    patches = egit.split_patches(egit.format_patch(repo, base + "..HEAD"))

    patches_abs = os.path.abspath(patches_root)
    groups = {}
    json_count = 0
    for patch in patches:
        if _trailer(patch, PATCH_TYPE_PREFIX) == "json":
            json_count += 1
            continue
        dest = _trailer(patch, PATCH_DIR_PREFIX) or user_dir(patches_root)
        # Confine the write to patches_root: a crafted trailer must not escape it.
        if os.path.isabs(dest) or os.path.relpath(os.path.abspath(dest), patches_abs).split(os.sep)[0] == "..":
            _fail(f"refusing Patch-Dir outside {patches_root}: {dest!r}")
        filename = egit.get_file_name(patch)
        if not filename or os.path.basename(filename) != filename or filename in (".", ".."):
            _fail(f"refusing unsafe patch filename: {filename!r}")
        # git am rejects a diff-less mailbox, so such a commit could never be re-imported.
        if any(line.startswith("GIT binary patch") or
               (line.startswith("Binary files") and " differ" in line) for line in patch):
            subject = next((l[len("Subject: "):].strip() for l in patch
                            if l.startswith("Subject: ")), filename)
            _fail(f"refusing to export a commit that changes a binary file: {subject!r}\n"
                  f"git am cannot re-apply it. Put binary assets in src/<quality>/ instead.")
        if not any(line.startswith("diff --git") for line in patch):
            subject = next((l[len("Subject: "):].strip() for l in patch
                            if l.startswith("Subject: ")), filename)
            _fail(f"refusing to export a commit with no changes: {subject!r}\n"
                  f"Drop it (git rebase) and re-run ./dev/export.sh.")
        groups.setdefault(dest, []).append((filename, patch))

    written = sum(len(v) for v in groups.values())
    if written + json_count != len(patches):
        _fail(f"no-drop check failed: {len(patches)} commits, "
              f"{written} written + {json_count} json")

    # Subjects can repeat; the filename is incidental, order comes from .patches.
    for dest, items in groups.items():
        seen = {}
        for i, (filename, patch) in enumerate(items):
            if filename in seen:
                stem = filename[: -len(".patch")]
                n = seen[filename] + 1
                while f"{stem}-{n}.patch" in seen:
                    n += 1
                seen[filename] = n
                filename = f"{stem}-{n}.patch"
                items[i] = (filename, patch)
                sys.stderr.write(f"{dest}: duplicate subject, writing {filename}\n")
            seen.setdefault(filename, 1)

    # Reconcile the dirs the import applied, never the ambient environment: a stale
    # VSCODE_QUALITY/OS_NAME would wipe another platform's patches.
    try:
        with open(_stack_dirs_path(repo), encoding="utf-8") as f:
            imported_dirs = [ln.strip() for ln in f if ln.strip()]
    except OSError:
        imported_dirs = []
    for d in imported_dirs:
        if os.path.isdir(d):
            groups.setdefault(d, [])

    if dry_run:
        bad = []
        for dest, items in groups.items():
            for filename, patch in items:
                path = os.path.join(dest, filename)
                formatted = egit.join_patch(patch)
                try:
                    with open(path, "rb") as f:
                        existing = f.read().decode("utf-8")
                except FileNotFoundError:
                    existing = None
                if formatted != existing:
                    bad.append(os.path.join(dest, filename))
            manifest = [f for f, _ in items]
            for f in os.listdir(dest):
                if f.endswith(".patch") and f not in manifest:
                    bad.append(os.path.join(dest, f) + " (stale)")
        if bad:
            sys.stderr.write("drift: patches not up to date:\n  " + "\n  ".join(bad) + "\n")
            sys.exit(1)
        print("export: no drift")
        return

    # Snapshot patches/ so a failed self-verify can restore it exactly.
    tip_before = subprocess.run(["git", "-C", repo, "rev-parse", "--verify", "-q", HEAD_REF],
                                capture_output=True, text=True).stdout.strip()
    before = {}
    for dest in groups:
        for f in os.listdir(dest):
            if f.endswith(".patch") or f == ".patches":
                with open(os.path.join(dest, f), "rb") as fh:
                    before[os.path.join(dest, f)] = fh.read()

    # patches/ mirrors the commits, so dropping a commit removes its patch.
    for dest, items in groups.items():
        owned = {f for f, _ in items}
        dropped = [f for f in sorted(os.listdir(dest))
                   if f.endswith(".patch") and f not in owned]
        if dropped:
            sys.stderr.write(
                f"{dest}: removing patch file(s) no commit in this clone produces:\n"
                + "".join(f"  {o}\n" for o in dropped)
                + "Import them first (./dev/build.sh) if they should be kept.\n")
        for f in os.listdir(dest):
            if f.endswith(".patch"):
                os.remove(os.path.join(dest, f))
        manifest = os.path.join(dest, ".patches")
        if not items:
            if os.path.exists(manifest):
                os.remove(manifest)
            continue
        with open(manifest, "w", newline="\n", encoding="utf-8") as pl:
            for filename, patch in items:
                with open(os.path.join(dest, filename), "wb") as f:
                    f.write(egit.join_patch(patch).encode("utf-8"))
                pl.write(filename + "\n")
    # Name what changed on disk: a patch file that arrived via git pull is rewritten
    # from this clone's commits, and that must not happen silently.
    rewritten = []
    for path, blob in before.items():
        try:
            with open(path, "rb") as fh:
                if fh.read() != blob:
                    rewritten.append(path)
        except OSError:
            rewritten.append(path)
    if rewritten:
        sys.stderr.write("rewrote from this clone's commits:\n"
                         + "".join(f"  {p}\n" for p in sorted(rewritten)))

    egit.update_ref(repo=repo, ref=HEAD_REF, newvalue="HEAD")
    try:
        os.remove(os.path.join(_git(repo, "rev-parse", "--absolute-git-dir").strip(),
                               "vscodium-patches-hash"))
    except OSError:
        pass
    print(f"exported {written} patches across {len(groups)} directories")

    if verify:
        if _git(repo, "status", "--porcelain").strip():
            print("working tree not clean; skipping round-trip self-verify to preserve your "
                  "changes (the no-drop check already passed)")
        else:
            _verify_roundtrip(repo, patches_root, list(groups.keys()), before, tip_before)


def _verify_roundtrip(repo, patches_root, present_dirs, before=None, tip_before=None):
    want_tree = _git(repo, "rev-parse", "HEAD^{tree}").strip()
    want_head = _git(repo, "rev-parse", "HEAD").strip()
    egit.update_ref(repo=repo, ref="refs/vscodium/pre-verify", newvalue=want_head)

    def restore():
        # Restore patches/ and the tip so a failure leaves nothing half-rewritten.
        subprocess.call(["git", "-C", repo, "am", "--abort"], stderr=subprocess.DEVNULL)
        _git_c(repo, "reset", "-q", "--hard", "refs/vscodium/pre-verify")
        for d in present_dirs:
            for f in os.listdir(d):
                if f.endswith(".patch") or f == ".patches":
                    os.remove(os.path.join(d, f))
        for path, blob in (before or {}).items():
            with open(path, "wb") as fh:
                fh.write(blob)
        if tip_before:
            egit.update_ref(repo=repo, ref=HEAD_REF, newvalue=tip_before)
        else:
            subprocess.call(["git", "-C", repo, "update-ref", "-d", HEAD_REF],
                            stderr=subprocess.DEVNULL)

    try:
        # _fail raises SystemExit, which `except Exception` would miss.
        try:
            import_stack(repo, patches_root, dirs=present_dirs)
        except BaseException as exc:
            restore()
            _fail(f"SELF-VERIFY FAILED: re-import errored ({exc}).\n"
                  f"vscode/ and patches/ were restored; nothing was written.")
        got_tree = _git(repo, "rev-parse", "HEAD^{tree}").strip()
        if got_tree != want_tree:
            restore()
            _fail("SELF-VERIFY FAILED: re-import does not reproduce HEAD.\n"
                  "vscode/ and patches/ were restored; nothing was written.")
        print("self-verify: re-import reproduces HEAD exactly (no drop)")
    finally:
        subprocess.call(["git", "-C", repo, "update-ref", "-d", "refs/vscodium/pre-verify"],
                        stderr=subprocess.DEVNULL)


def main(argv):
    parser = argparse.ArgumentParser(description="VSCodium patch-stack import/export")
    parser.add_argument("command", choices=["import", "export"])
    parser.add_argument("--repo", default="vscode")
    parser.add_argument("--patches", default="patches")
    parser.add_argument("--quality", default=os.environ.get("VSCODE_QUALITY", ""))
    parser.add_argument("--os", dest="os_name", default=os.environ.get("OS_NAME", ""))
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--no-verify", action="store_true")
    args = parser.parse_args(argv)

    if args.command == "import":
        import_stack(args.repo, args.patches, args.quality, args.os_name)
    else:
        export_stack(args.repo, args.patches,
                     dry_run=args.dry_run, verify=not args.no_verify,
                     quality=args.quality, os_name=args.os_name)


if __name__ == "__main__":
    main(sys.argv[1:])
