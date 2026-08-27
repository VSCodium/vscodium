#!/usr/bin/env python3

import argparse
import glob
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from email.header import decode_header, make_header

for _i, (_k, _v) in enumerate((
    ("diff.algorithm", "myers"), ("diff.context", "3"), ("diff.indentHeuristic", "true"),
    ("format.encodeEmailHeaders", "false"))):
    os.environ["GIT_CONFIG_KEY_%d" % _i] = _k
    os.environ["GIT_CONFIG_VALUE_%d" % _i] = _v
os.environ["GIT_CONFIG_COUNT"] = "4"
sys.stdout.reconfigure(line_buffering=True)

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import git as egit
from patches import PATCH_DIR_PREFIX, PATCH_FILENAME_PREFIX

BASE_REF = "refs/vscodium/base"
HEAD_REF = "refs/vscodium/head"
COMMITTER_NAME = "VSCodium"
COMMITTER_EMAIL = "scripts@vscodium.com"
GIT_CONFIG = [
    "-c", "user.name=" + COMMITTER_NAME,
    "-c", "user.email=" + COMMITTER_EMAIL,
    "-c", "commit.gpgsign=false",
    "-c", "core.hooksPath=/dev/null",
    "-c", "gc.auto=0",
    "-c", "rerere.enabled=true",
]
PATCH_EXTENSIONS = (".patch", ".json")
TAG_RE = re.compile(r"^\[([A-Za-z0-9][\w.-]*(?:/[A-Za-z0-9][\w.-]*)*)\] ?")
SUBJECT_WIDTH = 78
REBASE_DIR = "vscodium-rebase"
CONFLICT_LABELS = {
    "UU": "both modified",
    "AA": "both added",
    "DU": "deleted by us",
    "UD": "deleted by them",
    "DD": "both deleted",
    "AU": "added by us",
    "UA": "added by them",
}
CONFLICT_NOTES = {
    "UU": "conflict markers; the failed hunks are in {rej}",
    "AA": "conflict markers; the patch's version is in {rej}",
    "DU": "gone upstream; the patch's hunks are in {rej}: port them, or git rm it (--skip if nothing is left)",
    "UD": "the patch deletes it, upstream changed it (git rm keeps it deleted)",
    "DD": "gone from both sides; git rm it (or --skip if nothing is left)",
    "AU": "the patch adds it, absent upstream; its version is in {rej}",
    "UA": "upstream added it too; the patch's version is in {rej}",
}


def _fail(message):
    sys.stderr.write(message.rstrip("\n") + "\n")
    sys.exit(1)


def _n(count, noun):
    if count == 1:
        return f"1 {noun}"
    return f"{count} {noun}" + ("es" if noun.endswith(("s", "x", "z", "ch", "sh")) else "s")


def _config_label(quality, os_name):
    return ", ".join(filter(None, (quality, os_name)))


def _applied_skipped(state):
    applied = [os.path.join(d, n) for d, n, how, *_ in state["done"] if how == "applied"]
    skipped = [os.path.join(d, n) for d, n, how, *_ in state["done"] if how == "skipped"]
    return applied, skipped


def _location(d, name):
    return f"{PATCH_DIR_PREFIX}{d}\n{PATCH_FILENAME_PREFIX}{name}\n"


def _git(repo, *args):
    return subprocess.check_output(["git", "-C", repo, *args], text=True)


def _git_c(repo, *args):
    subprocess.check_call(["git", "-C", repo, *GIT_CONFIG, *args])


def _git_ok(repo, *args):
    return subprocess.call(["git", "-C", repo, *args],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) == 0


def _rev(repo, ref):
    return subprocess.run(["git", "-C", repo, "rev-parse", "--verify", "-q", ref],
                          capture_output=True, text=True).stdout.strip()


_GIT_DIRS = {}


def _git_dir(repo):
    if repo not in _GIT_DIRS:
        _GIT_DIRS[repo] = _git(repo, "rev-parse", "--absolute-git-dir").strip()
    return _GIT_DIRS[repo]


_GIT_VERSION = None


def _git_version():
    global _GIT_VERSION
    if _GIT_VERSION is None:
        match = re.search(r"(\d+)\.(\d+)", subprocess.check_output(["git", "--version"], text=True))
        _GIT_VERSION = (int(match.group(1)), int(match.group(2))) if match else (0, 0)
    return _GIT_VERSION


def _require_base(repo):
    base = _rev(repo, BASE_REF)
    if not base:
        _fail(f"{repo}/ was not created by this tooling ({BASE_REF} is missing).\n"
              f"Move it aside and run ./dev/build.sh to make a fresh clone.")
    return base


def _mid_operation(repo):
    git_dir = _git_dir(repo)
    return any(os.path.isdir(os.path.join(git_dir, d)) for d in ("rebase-apply", "rebase-merge"))


def _stack_dirs_path(repo):
    return os.path.join(_git_dir(repo), "vscodium-stack-dirs")


def _read_stack_dirs(repo):
    try:
        with open(_stack_dirs_path(repo), encoding="utf-8") as f:
            return [ln.strip() for ln in f if ln.strip()]
    except OSError:
        return []


def _write_stack_dirs(repo, dirs):
    with open(_stack_dirs_path(repo), "w", encoding="utf-8") as f:
        f.write("".join(d + "\n" for d in dirs))


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


def config_from_dirs(patches_root, dirs):
    names = {os.path.relpath(d, patches_root) for d in dirs} - {".", "insider", "user"}
    quality = "insider" if os.path.join(patches_root, "insider") in dirs else "stable"
    return quality, names.pop() if names else ""


def rebase_hint(quality, os_name):
    env = [f"OS_NAME={os_name}"] if os_name else []
    if quality == "insider":
        env.insert(0, "VSCODE_QUALITY=insider")
    return " ".join(env + ["./dev/rebase.sh"])


def patch_order(d):
    manifest = os.path.join(d, ".patches")
    ondisk = sorted(f for f in os.listdir(d) if f.endswith(PATCH_EXTENSIONS))
    if not os.path.exists(manifest):
        return ondisk
    with open(manifest, encoding="utf-8") as f:
        listed = [ln.rstrip("\n") for ln in f]
    for name in listed:
        if (not name or name != name.strip() or os.path.basename(name) != name
                or not name.endswith(PATCH_EXTENSIONS)):
            _fail(f"{manifest} has an invalid entry: {name!r}; run ./dev/export.sh.")
        if not os.path.exists(os.path.join(d, name)):
            _fail(f"{manifest} lists a file not on disk: {name}\n"
                  f"Remove that line, or restore the file "
                  f"(git checkout -- {os.path.join(d, name)}).")
    unlisted = [f for f in ondisk if f not in listed]
    if unlisted:
        _fail(f"{d}: file(s) missing from .patches: {', '.join(unlisted)}.\n"
              f"Add them to {manifest} in apply order, or remove the file(s).")
    return listed


def stem(name):
    return name[:-len(".patch")] if name.endswith(".patch") else name


def _is_mailbox(path):
    with open(path, "rb") as f:
        return f.readline().startswith(b"From ")


def _decode_subject(subject):
    if "=?" not in subject:
        return subject
    try:
        return str(make_header(decode_header(subject)))
    except (UnicodeDecodeError, ValueError):
        return subject


def _subject_span(lines):
    for i, line in enumerate(lines):
        if line.startswith("Subject: "):
            subject = line[len("Subject: "):].strip()
            j = i + 1
            while j < len(lines) and lines[j][:1] in (" ", "\t") and lines[j].strip():
                subject += " " + lines[j].strip()
                j += 1
            return i, j, _decode_subject(subject)
        if line.startswith(("diff -", "---", "\n", "\r\n")):
            break
    return None


def _fold_subject(subject):
    lines, line = [], "Subject:"
    for word in subject.split(" "):
        if line == "Subject:" or len(line) + 1 + len(word) <= SUBJECT_WIDTH:
            line += " " + word
        else:
            lines.append(line + "\n")
            line = " " + word
    lines.append(line + "\n")
    return lines


def _header_lines(lines):
    for line in lines:
        if line.startswith(("diff -", "---")):
            return
        yield line


def _trailer(lines, prefix):
    for line in _header_lines(lines):
        if line.startswith(prefix):
            return line[len(prefix):].strip()
    return None


def target_of(patch, patches_root):
    span = _subject_span(patch)
    subject = span[2] if span else ""
    tag = TAG_RE.match(subject)
    trailer_dir = _trailer(patch, PATCH_DIR_PREFIX)
    trailer_name = _trailer(patch, PATCH_FILENAME_PREFIX)
    if tag:
        parent, _, name = tag.group(1).rpartition("/")
        if not name.endswith(PATCH_EXTENSIONS):
            name += ".patch"
        if parent:
            dest = os.path.join(patches_root, *parent.split("/"))
        else:
            dest = trailer_dir or patches_root
        if not subject[tag.end():].strip():
            _fail(f"commit {subject!r} has no description after its [{tag.group(1)}] tag.")
    elif trailer_name:
        dest, name = trailer_dir or user_dir(patches_root), trailer_name
    else:
        dest, name = user_dir(patches_root), egit.munge_subject_to_filename(subject)
    patches_abs = os.path.abspath(patches_root)
    inside = os.path.relpath(os.path.abspath(dest), patches_abs).split(os.sep)[0] != ".."
    if os.path.isabs(dest) or not inside or not os.path.isdir(dest):
        _fail(f"no such patch directory for {subject!r}: {dest}")
    if os.path.basename(name) != name or name in (".", "..") or not re.match(r"^[\w.-]+$", name):
        _fail(f"refusing unsafe patch filename: {name!r}")
    return dest, name


def read_mailbox(d, name):
    with open(os.path.join(d, name), encoding="utf-8", newline="") as f:
        lines = f.readlines()
    span = _subject_span(lines)
    if not span:
        _fail(f"{os.path.join(d, name)}: no Subject: line.")
    i, j, subject = span
    if not subject.startswith(f"[{stem(name)}]"):
        subject = f"[{stem(name)}] {subject}"
    lines[i:j] = [f"Subject: {subject}\n"]
    out, located = [], False
    for line in lines:
        if not located and line.startswith(("diff -", "---")):
            out.append(_location(d, name))
            located = True
        out.append(line)
    return "".join(out)


def mailbox_content(patch):
    i, j, subject = _subject_span(patch)
    tag = TAG_RE.match(subject)
    if tag:
        subject = subject[tag.end():]
    lines = patch[:i] + _fold_subject(subject) + patch[j:]
    return egit.join_patch(lines)


def _json_paths(path):
    with open(path, encoding="utf-8") as f:
        actions = json.load(f)
    if not isinstance(actions, list):
        raise ValueError(f"{path}: expected a list of actions, got {type(actions).__name__}")
    paths = []
    for action in actions:
        if not isinstance(action, dict) or action.get("action") != "remove":
            raise ValueError(f"{path}: each action must be {{\"action\": \"remove\", \"paths\": [...]}}")
        rels = action.get("paths")
        if not isinstance(rels, list):
            raise ValueError(f"{path}: a remove action needs a \"paths\" list")
        for rel in rels:
            if not isinstance(rel, str) or os.path.isabs(rel) or os.path.normpath(rel).split(os.sep)[0] in (".", "..", ".git"):
                raise ValueError(f"{path}: invalid removal path: {rel!r}")
            if rel not in paths:
                paths.append(rel)
    return paths


def json_content(repo, sha, path):
    fields = _git(repo, "diff-tree", "--no-commit-id", "-r", "--name-status", "-z", sha).split("\0")
    deleted, other, i = set(), [], 0
    while i < len(fields) - 1:
        status, name = fields[i], fields[i + 1]
        i += 3 if status[:1] in "RC" else 2
        if status == "D":
            deleted.add(name)
        else:
            other.append(name)
    if other:
        _fail(f"{path} ({sha[:8]}) must only delete files; it also changes:\n"
              + "".join(f"  {p}\n" for p in other)
              + "Move those changes to a .patch commit.")
    trees = {}

    def files_under(d):
        if d not in trees:
            listed = _git(repo, "ls-tree", "-r", "--name-only", "-z", sha + "^", "--", d).split("\0")
            trees[d] = [f for f in listed if f.startswith(d + "/")]
        return trees[d]

    def holds(entry):
        if entry in deleted:
            return True
        files = files_under(entry)
        return bool(files) and all(f in deleted for f in files)

    def children(d):
        return {f[len(d) + 1:].split("/")[0] for f in files_under(d)}

    def covered_by(p):
        return files_under(p) or [p]

    try:
        previous = _json_paths(path)
    except (OSError, ValueError, KeyError):
        previous = []
    entries = [p for p in previous if holds(p)]
    covered = {f for p in entries for f in covered_by(p)}
    for f in sorted(deleted):
        if f in covered:
            continue
        parts = f.split("/")
        chosen = f
        for k in range(1, len(parts)):
            d = "/".join(parts[:k])
            if any(p == d or p.startswith(d + "/") for p in previous):
                continue
            if len(children(d)) > 1 and all(x in deleted for x in files_under(d)):
                chosen = d
                break
        entries.append(chosen)
        covered.update(covered_by(chosen))
    return json.dumps([{"action": "remove", "paths": entries}], indent=2) + "\n"


def _apply_json(repo, d, name, lenient, span=None):
    path = os.path.join(d, name)
    try:
        paths = _json_paths(path)
    except ValueError as exc:
        _fail(str(exc))
    present = lambda rel: bool(_git(repo, "ls-files", "-z", "--", rel))
    renamed = {}
    if span and not all(present(rel) for rel in paths):
        fields = _git(repo, "diff", "-M", "--name-status", "--diff-filter=R", "-z", *span).split("\0")
        renamed = {fields[i + 1]: fields[i + 2] for i in range(0, len(fields) - 2, 3)}
    removed, missing = [], []
    for rel in paths:
        if not present(rel):
            if rel in renamed and present(renamed[rel]):
                print(f"  {rel} was renamed upstream to {renamed[rel]}; removing that instead")
                rel = renamed[rel]
            else:
                missing.append(rel)
                continue
        _git(repo, "rm", "-r", "-q", "--", rel)
        target = _tree_path(repo, rel)
        if os.path.isdir(target) and not os.path.islink(target):
            shutil.rmtree(target)
        removed.append(rel)
    if missing and not lenient:
        return "path(s) to remove do not exist:\n" + "".join(f"  {m}\n" for m in missing), missing
    if removed:
        message = f"[{name}] remove {_n(len(removed), 'path')}\n\n{_location(d, name)}"
        _git_c(repo, "commit", "--no-verify", "-q", "-m", message)
    return None, missing


def _run_am(repo, mailbox, config=()):
    proc = subprocess.run(
        ["git", "-C", repo, *GIT_CONFIG, *config, "am", "--keep", "--3way", "--keep-cr"],
        input=mailbox.encode("utf-8"), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if proc.returncode == 0:
        return None
    lines = proc.stdout.decode("utf-8", "replace").splitlines()
    return "".join(ln + "\n" for ln in lines if not ln.startswith("hint:"))


def _plain_message(d, name):
    return f"[{stem(name)}] {stem(name)}\n\n{_location(d, name)}"


def _apply_plain(repo, d, name):
    path = os.path.abspath(os.path.join(d, name))
    proc = subprocess.run(["git", "-C", repo, "apply", "--index", "--ignore-whitespace", path],
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if proc.returncode != 0:
        return proc.stdout.decode("utf-8", "replace")
    _git_c(repo, "commit", "--no-verify", "-q", "-m", _plain_message(d, name))
    return None


def apply_step(repo, d, name, lenient=False, config=(), span=None):
    if name.endswith(".json"):
        return _apply_json(repo, d, name, lenient, span)
    if _is_mailbox(os.path.join(d, name)):
        return _run_am(repo, read_mailbox(d, name), config), []
    return _apply_plain(repo, d, name), []


def _abandon_stack(repo):
    _git_ok(repo, "update-ref", "-d", HEAD_REF)
    _git_c(repo, "reset", "-q", "--hard", BASE_REF)
    try:
        os.remove(os.path.join(_git_dir(repo), "vscodium-patches-hash"))
    except OSError:
        pass


def _require_no_rebase(repo):
    state = read_state(repo)
    if not state:
        return
    if os.environ.get("VSCODIUM_FORCE_RESET") == "1":
        _restore_from_state(repo, state)
        return
    _fail("A rebase is in progress in vscode/ (./dev/rebase.sh --status).\n"
          "Finish it with ./dev/rebase.sh --continue, or drop it with ./dev/rebase.sh --abort.")


def import_stack(repo, patches_root, quality=None, os_name=None, dirs=None):
    _require_base(repo)
    _require_no_rebase(repo)
    for op in (["am", "--abort"], ["rebase", "--quit"]):
        _git_ok(repo, *op)
    _git_ok(repo, "update-ref", "-d", HEAD_REF)
    _git_c(repo, "reset", "-q", "--hard", BASE_REF)
    if dirs is None:
        dirs = build_dirs(patches_root, quality, os_name)
    _write_stack_dirs(repo, dirs)
    try:
        for d in dirs:
            for name in patch_order(d):
                label = os.path.join(d, name)
                print(f"applying {label}")
                error, _ = apply_step(repo, d, name)
                if error:
                    _git_ok(repo, "am", "--abort")
                    _fail(f"failed to apply {label}:\n{error}"
                          f"Fix that file, or run `{rebase_hint(quality, os_name)}` to update the stack.")
    except BaseException:
        _abandon_stack(repo)
        raise
    egit.update_ref(repo=repo, ref=HEAD_REF, newvalue="HEAD")
    n = egit.get_commit_count(repo, BASE_REF + "..HEAD")
    print(f"imported {_n(n, 'commit')} ({BASE_REF}..HEAD)")


def _stack_patches(repo, base):
    shas = _git(repo, "rev-list", "--reverse", base + "..HEAD").split()
    patches = egit.split_patches(egit.format_patch(repo, base + "..HEAD"))
    if len(shas) != len(patches):
        empty = [s for s in shas if not _git(repo, "diff-tree", "--no-commit-id", "-r", "--name-only", s).strip()]
        _fail("refusing to export commit(s) with no changes:\n"
              + "".join(f"  {_git(repo, 'log', '-1', '--format=%h %s', s)}" for s in empty)
              + "Drop them (git rebase) and re-run ./dev/export.sh.")
    return list(zip(shas, patches))


def _has_binary(patch):
    return any(line.startswith("GIT binary patch")
               or (line.startswith("Binary files") and " differ" in line) for line in patch)


def _pending(state):
    pending = {}
    for d, name in state["todo"] if state else []:
        pending.setdefault(d, []).append(name)
    return pending


def export_stack(repo, patches_root, dry_run=False, verify=True):
    base = _require_base(repo)
    state = read_state(repo)
    merges = _git(repo, "rev-list", "--merges", base + "..HEAD").strip()
    if merges:
        _fail("the patch stack must be linear; found merge commit(s):\n" + merges)
    if not state and (not _rev(repo, HEAD_REF) or _mid_operation(repo)):
        _fail("vscode/ does not hold a fully imported patch stack; refusing to rewrite patches/.\n"
              "Finish or abort the am/rebase in vscode/, or run ./dev/build.sh to re-import.")

    groups = {}
    order_seq = []
    for sha, patch in _stack_patches(repo, base):
        dest, name = target_of(patch, patches_root)
        if name.endswith(".patch") and _has_binary(patch):
            _fail(f"refusing to export {os.path.join(dest, name)} ({sha[:8]}): it changes a binary file.\n"
                  f"git am cannot re-apply it. Put binary assets in src/<quality>/ instead.")
        order_seq.append((dest, name))
        groups.setdefault(dest, []).append([name, patch, sha])
    for dest, items in groups.items():
        seen = set()
        for item in items:
            name = item[0]
            if name in seen:
                root, ext = os.path.splitext(name)
                n = 2
                while f"{root}-{n}{ext}" in seen:
                    n += 1
                item[0] = f"{root}-{n}{ext}"
                sys.stderr.write(f"{dest}: duplicate name, writing {item[0]}\n")
            seen.add(item[0])
    imported = [d for d in _read_stack_dirs(repo) if os.path.isdir(d)]
    for dest in groups:
        if imported and dest not in imported:
            quality, os_name = config_from_dirs(patches_root, imported)
            _fail(f"{groups[dest][0][0]} targets {dest}, which this clone did not import "
                  f"({_config_label(quality, os_name)}).\n"
                  f"Export it from a clone built for that directory, or tag the commit [user/...].")
    order = -1
    for dest, name in order_seq:
        rank = imported.index(dest) if dest in imported else order
        if rank < order:
            print(f"note: {os.path.join(dest, name)} is applied before {', '.join(imported[rank + 1:])} "
                  f"but sits above their commits; if the re-import fails, move it down "
                  f"(git rebase -i {BASE_REF}) or tag it [user/{stem(name)}].")
        order = max(order, rank)
    for d in imported:
        groups.setdefault(d, [])
    pending = _pending(state)

    contents = {}
    for dest, items in groups.items():
        for name, patch, sha in items:
            path = os.path.join(dest, name)
            contents[path] = json_content(repo, sha, path) if name.endswith(".json") else mailbox_content(patch)

    def on_disk(dest):
        return sorted(f for f in os.listdir(dest) if f.endswith(PATCH_EXTENSIONS))

    if dry_run:
        bad = []
        for dest, items in groups.items():
            names = [name for name, _, _ in items] + pending.get(dest, [])
            for name, _, _ in items:
                path = os.path.join(dest, name)
                try:
                    with open(path, "rb") as f:
                        existing = f.read().decode("utf-8")
                except FileNotFoundError:
                    existing = None
                if contents[path] != existing:
                    bad.append(path)
            bad += [os.path.join(dest, f) + " (stale)" for f in on_disk(dest) if f not in names]
            manifest = os.path.join(dest, ".patches")
            try:
                with open(manifest, encoding="utf-8") as f:
                    listed = f.read()
            except FileNotFoundError:
                listed = None
            wanted = "".join(n + "\n" for n in names) if names else None
            if listed != wanted:
                bad.append(manifest)
        if bad:
            sys.stderr.write("drift: patches not up to date:\n  " + "\n  ".join(bad) + "\n")
            sys.exit(1)
        print("export: no drift")
        return

    tip_before = _rev(repo, HEAD_REF)
    before = {}
    for dest in groups:
        for f in os.listdir(dest):
            if f.endswith(PATCH_EXTENSIONS) or f == ".patches":
                with open(os.path.join(dest, f), "rb") as fh:
                    before[os.path.join(dest, f)] = fh.read()

    written = 0
    for dest, items in groups.items():
        keep = pending.get(dest, [])
        owned = {name for name, _, _ in items} | set(keep)
        dropped = [f for f in on_disk(dest) if f not in owned]
        if dropped:
            sys.stderr.write(
                f"{dest}: removing patch file(s) that no commit in this clone produces "
                f"(dropped, skipped, or never imported):\n"
                + "".join(f"  {o}\n" for o in dropped))
        for f in on_disk(dest):
            if f not in keep:
                os.remove(os.path.join(dest, f))
        manifest = os.path.join(dest, ".patches")
        if not items and not keep:
            if os.path.exists(manifest):
                os.remove(manifest)
            continue
        for name, _, _ in items:
            with open(os.path.join(dest, name), "wb") as f:
                f.write(contents[os.path.join(dest, name)].encode("utf-8"))
            written += 1
        with open(manifest, "w", newline="\n", encoding="utf-8") as pl:
            pl.write("".join(name + "\n" for name in [name for name, _, _ in items] + keep))
    rewritten = []
    for path, blob in before.items():
        try:
            with open(path, "rb") as fh:
                if fh.read() != blob:
                    rewritten.append(path)
        except OSError:
            pass
    if rewritten:
        sys.stderr.write("rewrote from this clone's commits:\n"
                         + "".join(f"  {p}\n" for p in sorted(rewritten)))

    if not state:
        egit.update_ref(repo=repo, ref=HEAD_REF, newvalue="HEAD")
    try:
        os.remove(os.path.join(_git_dir(repo), "vscodium-patches-hash"))
    except OSError:
        pass
    print(f"exported {_n(written, 'patch')}")

    if state:
        left = sum(len(v) for v in pending.values())
        print(f"rebase in progress: {_n(left, 'pending patch')} left untouched; "
              f"./dev/rebase.sh --continue applies them")
    elif verify and _git(repo, "status", "--porcelain").strip():
        print("working tree not clean; skipping round-trip self-verify to preserve your changes")
    elif verify:
        ordered = sorted(groups.keys(), key=lambda d: imported.index(d) if d in imported else len(imported))
        _verify_roundtrip(repo, patches_root, ordered, before, tip_before)


def _verify_roundtrip(repo, patches_root, present_dirs, before, tip_before):
    want_tree = _git(repo, "rev-parse", "HEAD^{tree}").strip()
    want_head = _git(repo, "rev-parse", "HEAD").strip()
    egit.update_ref(repo=repo, ref="refs/vscodium/pre-verify", newvalue=want_head)

    def restore():
        _git_ok(repo, "am", "--abort")
        _git_c(repo, "reset", "-q", "--hard", "refs/vscodium/pre-verify")
        for d in present_dirs:
            for f in os.listdir(d):
                if f.endswith(PATCH_EXTENSIONS) or f == ".patches":
                    os.remove(os.path.join(d, f))
        for path, blob in before.items():
            with open(path, "wb") as fh:
                fh.write(blob)
        if tip_before:
            egit.update_ref(repo=repo, ref=HEAD_REF, newvalue=tip_before)
        else:
            _git_ok(repo, "update-ref", "-d", HEAD_REF)

    try:
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
        print("self-verify: re-import reproduces HEAD exactly (no drop); ./dev/verify.sh checks the tree itself")
    finally:
        _git_ok(repo, "update-ref", "-d", "refs/vscodium/pre-verify")


def _state_path(repo):
    return os.path.join(_git_dir(repo), REBASE_DIR, "state.json")


def read_state(repo):
    try:
        with open(_state_path(repo), encoding="utf-8") as f:
            return json.load(f)
    except OSError:
        return None


def _write_state(repo, state):
    path = _state_path(repo)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path + ".tmp", "w", encoding="utf-8") as f:
        json.dump(state, f, indent=2)
    os.replace(path + ".tmp", path)


def _drop_state(repo):
    shutil.rmtree(os.path.dirname(_state_path(repo)), ignore_errors=True)


def _backup_root(repo):
    return os.path.join(_git_dir(repo), REBASE_DIR, "backup")


def _snapshot_patches(repo, dirs):
    root = _backup_root(repo)
    shutil.rmtree(root, ignore_errors=True)
    for d in dirs:
        dest = os.path.join(root, d)
        os.makedirs(dest, exist_ok=True)
        for f in os.listdir(d):
            if f.endswith(PATCH_EXTENSIONS) or f == ".patches":
                shutil.copyfile(os.path.join(d, f), os.path.join(dest, f))


def _restore_patches(repo, dirs):
    root = _backup_root(repo)
    if not os.path.isdir(root):
        return
    for d in dirs:
        if os.path.isdir(d):
            for f in os.listdir(d):
                if f.endswith(PATCH_EXTENSIONS) or f == ".patches":
                    os.remove(os.path.join(d, f))
        else:
            os.makedirs(d, exist_ok=True)
        saved = os.path.join(root, d)
        if os.path.isdir(saved):
            for f in os.listdir(saved):
                if f.endswith(PATCH_EXTENSIONS) or f == ".patches":
                    shutil.copyfile(os.path.join(saved, f), os.path.join(d, f))


def _require_state(repo):
    state = read_state(repo)
    if not state:
        _fail("No rebase in progress.")
    return state


def _restore_from_state(repo, state):
    _git_ok(repo, "am", "--abort")
    _remove_rejects(repo, state)
    _git_c(repo, "reset", "-q", "--hard", state["old_head"])
    egit.update_ref(repo=repo, ref=BASE_REF, newvalue=state["old_base"])
    if state["old_tip"]:
        egit.update_ref(repo=repo, ref=HEAD_REF, newvalue=state["old_tip"])
    else:
        _git_ok(repo, "update-ref", "-d", HEAD_REF)
    _write_stack_dirs(repo, state["old_dirs"])
    _restore_patches(repo, state.get("dirs", state["old_dirs"]))
    _drop_state(repo)


def _exclude_rejects(repo):
    exclude = os.path.join(_git_dir(repo), "info", "exclude")
    os.makedirs(os.path.dirname(exclude), exist_ok=True)
    try:
        with open(exclude, encoding="utf-8") as f:
            if "*.rej\n" in f.readlines():
                return
    except OSError:
        pass
    with open(exclude, "a", encoding="utf-8") as f:
        f.write("*.rej\n")


def _tree_path(repo, path):
    return os.path.join(repo, *path.split("/"))


def _remove_rejects(repo, state):
    for path in state["rej"]:
        try:
            os.remove(_tree_path(repo, path + ".rej"))
        except OSError:
            pass
    state["rej"] = []


def _conflicts(repo):
    fields = _git(repo, "status", "--porcelain", "-z").split("\0")
    entries, i = [], 0
    while i < len(fields) and fields[i]:
        code, path = fields[i][:2], fields[i][3:]
        i += 2 if "R" in code or "C" in code else 1
        if code in CONFLICT_LABELS:
            entries.append((code, path))
    return entries


def _diff_sections(text):
    sections = {}
    for chunk in re.split(r"(?m)^(?=diff --git )", text)[1:]:
        for line in chunk.splitlines():
            if line.startswith("@@"):
                break
            for prefix in ("--- a/", "+++ b/"):
                if line.startswith(prefix):
                    sections[line[len(prefix):]] = chunk
    return sections


def _patch_sections(d, name):
    with open(os.path.join(d, name), encoding="utf-8", newline="") as f:
        return _diff_sections(f.read())


def _reject_hunks(repo, path, section):
    ours = subprocess.run(["git", "-C", repo, "show", "HEAD:" + path], capture_output=True).stdout
    tmp = os.path.realpath(tempfile.mkdtemp())
    try:
        target = os.path.join(tmp, "work", *path.split("/"))
        os.makedirs(os.path.dirname(target), exist_ok=True)
        with open(target, "wb") as f:
            f.write(ours)
        subprocess.run(["git", "apply", "--reject", "--ignore-whitespace", "-C1"],
                       input=section.encode("utf-8"), cwd=os.path.join(tmp, "work"),
                       env={**os.environ, "GIT_CEILING_DIRECTORIES": tmp},
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        try:
            with open(target + ".rej", "rb") as f:
                return f.read()
        except OSError:
            return None
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def _write_reject(repo, path, data):
    target = _tree_path(repo, path + ".rej")
    os.makedirs(os.path.dirname(target), exist_ok=True)
    with open(target, "wb") as f:
        f.write(data)


def _rejects_for_conflicts(repo, d, name):
    sections = _patch_sections(d, name)
    written = []
    for code, path in _conflicts(repo):
        section = sections.get(path)
        if not section:
            continue
        data = (_reject_hunks(repo, path, section) if code == "UU" else None) or section.encode("utf-8")
        _write_reject(repo, path, data)
        written.append(path)
    return written


def _apply_with_rejects(repo, d, name):
    sections = _patch_sections(d, name)
    proc = subprocess.run(["git", "-C", repo, "apply", "--reject", "--ignore-whitespace",
                           os.path.abspath(os.path.join(d, name))], capture_output=True, text=True)
    failed = set(re.findall(r"^error: (.+?): ", proc.stderr, re.M)) & set(sections)
    written = []
    for path, section in sections.items():
        gone = not os.path.lexists(_tree_path(repo, path)) and "\n+++ /dev/null" not in section
        if os.path.exists(_tree_path(repo, path + ".rej")):
            written.append(path)
        elif path in failed or gone:
            _write_reject(repo, path, section.encode("utf-8"))
            written.append(path)
    _git(repo, "add", "-A")
    return written


def _conflict_rows(repo, state):
    if state["mode"] == "3way":
        rejects = set(state["rej"])
        remaining = set(_names(subprocess.check_output(
            ["git", "-C", repo, *GIT_CONFIG, "rerere", "remaining"], text=True)))
        for code, path in _conflicts(repo):
            if code == "UU" and path not in remaining:
                note = "rerere replayed your earlier resolution; review it, then git add"
            else:
                note = CONFLICT_NOTES[code].format(rej=path + ".rej") if path in rejects or code == "UD" else ""
            yield CONFLICT_LABELS[code], path, note
        return
    for path in state["rej"]:
        if not os.path.exists(_tree_path(repo, path + ".rej")):
            continue
        if os.path.lexists(_tree_path(repo, path)):
            yield "rejected hunks", path, f"apply {path}.rej by hand, then delete it"
        else:
            yield "gone upstream", path, f"the patch's hunks are in {path}.rej; port or delete them"


def _print_rows(repo, state):
    for label, path, note in _conflict_rows(repo, state):
        print(f"  {label:16}{path}")
        if note:
            print(f"  {'':16}{note}")


def _report_conflict(repo, state, label, error):
    print(f"\n{label} did not apply cleanly:")
    sys.stdout.write("".join(f"  {ln}\n" for ln in error.splitlines()))
    if state["mode"] == "reject":
        print("  (no 3-way merge: the upstream this patch was made against is not in this clone)")
    print()
    _print_rows(repo, state)
    applied = len(_applied_skipped(state)[0])
    left = len(state["todo"]) - 1
    print("\nResolve and `git add` (or `git rm`) each file, then:  ./dev/rebase.sh --continue  (not git am)")
    print("  ./dev/rebase.sh --skip [<patch>]    drop this patch (or a pending one)")
    print("  ./dev/rebase.sh --abort             put vscode/ back as it was")
    print(f"  ./dev/export.sh                     save the {_n(applied, 'patch')} rebased so far ({left} left)")


def _rebase_config():
    style = "zdiff3" if _git_version() >= (2, 35) else "diff3"
    return ["-c", "merge.conflictStyle=" + style]


def _matches(wanted, d, name):
    return wanted in (name, stem(name), os.path.join(d, name))


def _step_done(state, how):
    d, name = state["current"]
    state["done"].append([d, name, how, state["step_head"]])
    state["todo"].pop(0)
    state["current"] = None
    state["step_head"] = None


def _skip_pending(state, wanted):
    for i, (d, name) in enumerate(state["todo"]):
        if _matches(wanted, d, name):
            state["done"].append([d, name, "skipped", None])
            state["todo"].pop(i)
            print(f"skipped {os.path.join(d, name)}")
            return
    _fail(f"{wanted} is not among the pending patches (./dev/rebase.sh --status).")


def _rebase_run(repo, state, until=None):
    if until and not any(_matches(until, d, name) for d, name in state["todo"]):
        _fail(f"{until} is not among the pending patches (./dev/rebase.sh --status).")
    if until:
        state["until"] = until
    until = state.get("until")
    while state["todo"]:
        d, name = state["todo"][0]
        label = os.path.join(d, name)
        state["current"] = [d, name]
        state["step_head"] = _rev(repo, "HEAD")
        _write_state(repo, state)
        try:
            error, missing = apply_step(repo, d, name, lenient=True, config=_rebase_config(),
                                        span=(state["old_base"], state["onto"]))
        except KeyboardInterrupt:
            _git_ok(repo, "am", "--abort")
            if _rev(repo, "HEAD") != state["step_head"]:
                _step_done(state, "applied")
            else:
                _git_c(repo, "reset", "-q", "--hard", state["step_head"])
                state["current"] = None
            _write_state(repo, state)
            print("\nPaused; ./dev/rebase.sh --continue resumes.")
            sys.exit(1)
        if error:
            if _conflicts(repo):
                state["mode"] = "3way"
                state["rej"] = _rejects_for_conflicts(repo, d, name)
            else:
                state["mode"] = "reject"
                state["rej"] = _apply_with_rejects(repo, d, name)
            _write_state(repo, state)
            _report_conflict(repo, state, label, error)
            sys.exit(1)
        if _rev(repo, "HEAD") == state["step_head"]:
            _step_done(state, "skipped")
            print(f"skipped {label} (none of its paths exist upstream)")
        else:
            _step_done(state, "applied")
            if missing:
                state.setdefault("notes", []).append(f"{label}: no longer upstream, dropped: {', '.join(missing)}")
            print(f"applied {label}" + (f" ({_n(len(missing), 'path')} no longer upstream, dropped: "
                                       f"{', '.join(missing)})" if missing else ""))
        _write_state(repo, state)
        if until and _matches(until, d, name):
            state["until"] = None
            _write_state(repo, state)
            print(f"\nStopped after {label}; ./dev/rebase.sh --continue resumes.")
            return
    _rebase_finish(repo, state)


def _check_variants(repo, patches_root):
    found, broken = 0, []
    for sub in ("*/client", "*/reh", "*/reh/*"):
        for f in sorted(glob.glob(os.path.join(patches_root, sub, "*.patch"))):
            found += 1
            if not _git_ok(repo, "apply", "--check", "--ignore-whitespace", os.path.abspath(f)):
                broken.append(f)
    if found:
        print(f"variant patches (applied by packaging, not the stack): {found - len(broken)} of {found} "
              f"would apply to this tree" + (f"; broken: {', '.join(broken)}" if broken else ""))


def rebase_redo(repo):
    state = _require_state(repo)
    if state["current"]:
        _fail(f"{os.path.join(*state['current'])} is still in progress; finish it (--continue), --skip it, or --abort before --redo.")
    last = state["done"][-1] if state["done"] else None
    if not last or len(last) < 4 or not last[3]:
        _fail("Nothing to redo (./dev/rebase.sh --status).")
    d, name, _how, start = state["done"].pop()
    _git_c(repo, "reset", "-q", "--hard", start)
    state["todo"].insert(0, [d, name])
    _write_state(repo, state)
    print(f"undid {os.path.join(d, name)}; applying it again")
    _rebase_run(repo, state)


def _rebase_finish(repo, state):
    _drop_state(repo)
    applied, skipped = _applied_skipped(state)
    print(f"\nRebased {_n(len(applied), 'patch')} onto {state['onto'][:8]}."
          + (f" Skipped {len(skipped)}: {', '.join(skipped)}." if skipped else ""))
    for note in state.get("notes", []):
        print(f"  {note}")
    _check_variants(repo, _read_stack_dirs(repo)[0])
    print("Next: ./dev/export.sh    (writes the rebased patches; skipped ones are removed)")
    print("      ./dev/verify.sh    (finds imports the rebased stack broke)")
    pin = os.path.join("upstream", state["quality"] + ".json")
    try:
        with open(pin, encoding="utf-8") as f:
            pinned = json.load(f)["commit"]
    except (OSError, ValueError, KeyError):
        pinned = None
    if pinned != state["onto"]:
        print(f"Then point {pin} at {state['onto']} so a fresh clone builds against it.")


def rebase_start(repo, patches_root, onto, quality, os_name, until):
    base = _require_base(repo)
    if read_state(repo):
        _fail("A rebase is already in progress (./dev/rebase.sh --status).")
    imported = _read_stack_dirs(repo)
    derived_quality, derived_os = config_from_dirs(patches_root, imported)
    quality = quality or derived_quality
    os_name = os_name or derived_os
    dirs = build_dirs(patches_root, quality, os_name)
    if not onto and _rev(repo, HEAD_REF):
        with open(os.path.join("upstream", quality + ".json"), encoding="utf-8") as f:
            onto = json.load(f)["commit"]
    if onto and not _rev(repo, onto + "^{commit}"):
        subprocess.check_call(["git", "-C", repo, "fetch", "--depth", "1", "origin", onto])
        onto = "FETCH_HEAD"
    onto = _rev(repo, (onto or base) + "^{commit}")
    todo = [[d, name] for d in dirs for name in patch_order(d)]
    if until and not any(_matches(until, d, name) for d, name in todo):
        _fail(f"{until} is not among the patches to apply.")
    state = {
        "onto": onto, "old_base": base, "old_head": _rev(repo, "HEAD"), "old_tip": _rev(repo, HEAD_REF),
        "old_dirs": imported, "dirs": dirs, "quality": quality, "os_name": os_name,
        "todo": todo, "done": [], "current": None, "step_head": None, "mode": "3way", "rej": [], "until": until,
    }
    _write_state(repo, state)
    _write_stack_dirs(repo, dirs)
    _snapshot_patches(repo, dirs)
    _exclude_rejects(repo)
    egit.update_ref(repo=repo, ref=BASE_REF, newvalue=onto)
    _git_c(repo, "reset", "-q", "--hard", onto)
    config = _config_label(quality, os_name)
    if onto == base:
        print(f"Re-applying {_n(len(todo), 'patch')} ({config}) onto {onto[:8]}")
    else:
        print(f"Rebasing {_n(len(todo), 'patch')} ({config}): {base[:8]} -> {onto[:8]}")
    _rebase_run(repo, state, until)


def _names(output):
    return [p for p in output.split("\n") if p]


def _subject(repo):
    return _git(repo, "log", "-1", "--format=%s", "HEAD").strip()


def _head_is(repo, name):
    tag = TAG_RE.match(_subject(repo))
    return bool(tag) and tag.group(1).rpartition("/")[2] in (name, stem(name))


def _note_resolution(repo, d, name, label):
    if name.endswith(".json"):
        return
    wanted = set(_patch_sections(d, name))
    got = set(_names(_git(repo, "diff-tree", "--no-commit-id", "-r", "--name-only", "HEAD")))
    if wanted - got:
        _git_ok(repo, "rerere", "forget", "--", *sorted(wanted - got))
        print(f"note: {label} changes {_n(len(wanted), 'file')} but this commit changes {len(got)}; "
              f"untouched: {', '.join(sorted(wanted - got))} (not remembered for rerere; --redo re-applies it)")


def _finish_step(repo, state, label, am):
    d, name = state["current"]
    if state["mode"] == "3way":
        unmerged = _names(_git(repo, "diff", "--name-only", "--diff-filter=U"))
        if unmerged:
            _fail(f"{label} still has unresolved files:\n" + "".join(f"  {p}\n" for p in unmerged)
                  + "Resolve and `git add` them, then re-run ./dev/rebase.sh --continue.")
    else:
        left = [p for p in state["rej"] if os.path.exists(_tree_path(repo, p + ".rej"))]
        if left:
            _fail(f"{label} still has rejected hunks:\n" + "".join(f"  {p}.rej\n" for p in left)
                  + "Apply them by hand, delete the .rej files and `git add` the files, "
                  "then re-run ./dev/rebase.sh --continue.")
    unstaged = _names(_git(repo, "diff", "--name-only"))
    if unstaged:
        _fail("unstaged changes in vscode/:\n" + "".join(f"  {p}\n" for p in unstaged)
              + "`git add` them (or discard them), then re-run ./dev/rebase.sh --continue.")
    if _git_ok(repo, "diff", "--cached", "--quiet"):
        _fail(f"nothing is staged for {label}.\n"
              f"If the patch is no longer needed: ./dev/rebase.sh --skip")
    if am:
        _git_c(repo, "am", "--continue")
    else:
        _git_c(repo, "commit", "--no-verify", "-q", "-m", _plain_message(d, name))


def rebase_continue(repo, until=None, skip=None):
    state = _require_state(repo)
    until = until or state.get("until")
    current = state["current"]
    if skip and not (current and _matches(skip, *current)):
        _skip_pending(state, skip)
        _write_state(repo, state)
        if current:
            print(f"still stopped on {os.path.join(*current)}; resolve it, then ./dev/rebase.sh --continue")
            return
        skip = None
    if current:
        d, name = current
        label = os.path.join(d, name)
        am = os.path.isdir(os.path.join(_git_dir(repo), "rebase-apply"))
        moved = _rev(repo, "HEAD") != state["step_head"]
        plain = name.endswith(".patch") and not _is_mailbox(os.path.join(d, name))
        if skip is not None:
            _git_ok(repo, "am", "--skip")
            _git_c(repo, "reset", "-q", "--hard", state["step_head"])
            _remove_rejects(repo, state)
            _step_done(state, "skipped")
            print(f"skipped {label}")
        elif am and moved:
            _fail(f"{label} was committed by hand while git am was still running.\n"
                  f"Run `git -C vscode reset --soft {state['step_head'][:8]}`, then "
                  f"./dev/rebase.sh --continue, so the commit keeps the patch's name and note.")
        elif am or (plain and not moved):
            _finish_step(repo, state, label, am)
            _remove_rejects(repo, state)
            _step_done(state, "applied")
            print(f"applied {label}")
            _note_resolution(repo, d, name, label)
        elif moved and _head_is(repo, name):
            _remove_rejects(repo, state)
            _step_done(state, "applied")
            print(f"applied {label}")
            _note_resolution(repo, d, name, label)
        elif moved:
            _fail(f"HEAD moved to {_rev(repo, 'HEAD')[:8]} \"{_subject(repo)}\", which is not {label}'s commit.\n"
                  f"If that commit is your resolution of this patch, tag its subject [{stem(name)}] "
                  f"(git -C vscode commit --amend); otherwise put vscode/ back with "
                  f"`git -C vscode reset --hard {state['step_head'][:8]}`. Then ./dev/rebase.sh --continue.")
        elif _git(repo, "status", "--porcelain", "--untracked-files=no").strip():
            _fail(f"{label}: the previous `git am` was ended by hand and vscode/ has uncommitted "
                  f"changes.\nCommit them onto this patch, or discard them "
                  f"(git -C vscode reset --hard), then ./dev/rebase.sh --continue; or --skip / --abort.")
        else:
            _git_c(repo, "reset", "-q", "--hard", state["step_head"])
            _remove_rejects(repo, state)
            state["current"] = None
        if state["current"] is None and until and _matches(until, d, name):
            state["until"] = None
        _write_state(repo, state)
        if state["current"] is None and until and _matches(until, d, name):
            print(f"\nStopped after {label}; ./dev/rebase.sh --continue resumes.")
            return
    elif skip is not None:
        if not state["todo"]:
            _fail("Nothing left to skip (./dev/rebase.sh --status).")
        _skip_pending(state, os.path.join(*state["todo"][0]))
        _write_state(repo, state)
    _rebase_run(repo, state, until)


def rebase_abort(repo, force):
    state = _require_state(repo)
    unsaved = egit.get_commit_count(repo, state["onto"] + "..HEAD")
    if unsaved and not force:
        _fail(f"--abort would discard {_n(unsaved, 'rebased commit')} and any patches "
              f"./dev/export.sh wrote during the rebase.\n"
              f"Run ./dev/rebase.sh --abort -f to discard them.")
    _restore_from_state(repo, state)
    print(f"vscode/ is back on {state['old_head'][:8]} (base {state['old_base'][:8]}) with its "
          f"{_n(len(state['todo']) + len(state['done']), 'patch')}.")
    if os.path.isdir(os.path.join(_git_dir(repo), "rr-cache")):
        print("rerere still remembers the conflicts you resolved; `git -C vscode rerere clear` forgets them.")


def rebase_status(repo):
    state = _require_state(repo)
    applied, skipped = _applied_skipped(state)
    pending = state["todo"][1:] if state["current"] else state["todo"]
    config = _config_label(state["quality"], state["os_name"])
    print(f"Rebasing onto {state['onto'][:8]} ({config}): "
          f"{len(applied)} applied, {len(skipped)} skipped, {len(pending)} pending")
    if state.get("until"):
        print(f"  stops after {state['until']}")
    commits = egit.get_commit_count(repo, state["onto"] + "..HEAD")
    if commits != len(applied) + (1 if state["current"] and _head_is(repo, state["current"][1]) else 0):
        print(f"  note: {_n(commits, 'commit')} on the stack for {_n(len(applied), 'applied patch')}; "
              f"./dev/export.sh writes untagged ones as user patches")
    if state["current"]:
        print(f"  stopped on {os.path.join(*state['current'])}:")
        _print_rows(repo, state)
    for d, name in pending[:5]:
        print(f"  pending  {os.path.join(d, name)}")
    if len(pending) > 5:
        print(f"  ... {len(pending) - 5} more")
    print("./dev/rebase.sh --continue | --skip [<patch>] | --redo | --abort;  ./dev/export.sh saves the rebased ones")


NODE_BUILTINS = {
    "assert", "async_hooks", "buffer", "child_process", "cluster", "console", "constants", "crypto", "dgram",
    "diagnostics_channel", "dns", "domain", "events", "fs", "http", "http2", "https", "inspector", "module",
    "net", "os", "path", "perf_hooks", "process", "punycode", "querystring", "readline", "repl", "stream",
    "string_decoder", "sys", "timers", "tls", "trace_events", "tty", "url", "util", "v8", "vm", "wasi",
    "worker_threads", "zlib",
}
IMPORT_RE = re.compile(
    r"""^\s*(?:import|export)\b[^;'"]*?\bfrom\s*(['"])([^'"\n]+)\1|^\s*import\s*(['"])([^'"\n]+)\3"""
    r"""|\bimport\(\s*(['"])([^'"\n]+)\5\s*\)|\brequire\(\s*(['"])([^'"\n]+)\7\s*\)""", re.M)
RESOLVE_SUFFIXES = ("", ".ts", ".tsx", ".d.ts", ".js", ".mjs", ".cjs", ".json", "/index.ts", "/index.js", "/index.d.ts")


def _scan_imports(root, files):
    declared = {}

    def packages(directory):
        if directory not in declared:
            names = set(packages(os.path.dirname(directory))) if directory else set()
            for pj in (os.path.join(directory, "package.json"),) + (("remote/package.json",) if not directory else ()):
                if os.path.isfile(os.path.join(root, pj)):
                    with open(os.path.join(root, pj), encoding="utf-8") as f:
                        data = json.load(f)
                    for key in ("dependencies", "devDependencies", "optionalDependencies", "peerDependencies"):
                        names.update(data.get(key, {}))
            declared[directory] = names
        return declared[directory]

    dangling, bare = set(), set()
    for path in files:
        with open(os.path.join(root, path), encoding="utf-8", errors="replace") as f:
            text = f.read()
        for m in IMPORT_RE.finditer(text):
            spec = m.group(2) or m.group(4) or m.group(6) or m.group(8)
            if spec.startswith("."):
                base = os.path.normpath(os.path.join(os.path.dirname(path), spec))
                stems = (base, re.sub(r"\.js$", "", base)) if base.endswith(".js") else (base,)
                if not any(os.path.lexists(os.path.join(root, b + suffix)) for b in stems for suffix in RESOLVE_SUFFIXES):
                    dangling.add(f"{path}: imports {spec}, which does not exist")
            elif not spec.startswith(("/", "node:", "vs/")):
                bare.add((path, "/".join(spec.split("/")[:2 if spec.startswith("@") else 1])))
    return dangling, bare, packages


def _source_files(listing):
    return [p for p in listing.split("\0") if p.endswith((".ts", ".tsx", ".js", ".mjs", ".cjs")) and "/node_modules/" not in p]


def verify_tree(repo):
    base = _require_base(repo)
    files = _source_files(_git(repo, "ls-files", "-z", "--", "src", "extensions"))
    dangling, bare, declared = _scan_imports(repo, files)
    tmp = tempfile.mkdtemp()
    try:
        with subprocess.Popen(["git", "-C", repo, "archive", base, "src", "extensions", "package.json", "remote/package.json"],
                              stdout=subprocess.PIPE) as archive:
            subprocess.check_call(["tar", "-x", "-C", tmp], stdin=archive.stdout)
        upstream, _bare, declared_upstream = _scan_imports(
            tmp, _source_files(_git(repo, "ls-tree", "-r", "-z", "--name-only", base, "--", "src", "extensions")))
        problems = dangling - upstream
        for path, pkg in bare:
            if pkg not in declared(os.path.dirname(path)) and pkg in declared_upstream(os.path.dirname(path)):
                problems.add(f"{path}: imports {pkg}, which the patch stack removed from package.json")
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    for line in sorted(problems):
        print(line)
    if problems:
        _fail(f"{_n(len(problems), 'import')} broken by the patch stack (upstream's own {len(dangling & upstream)} left alone); "
              "fix the patch that removed the target, or extend the removal to the importer.")
    print(f"verify: {_n(len(files), 'file')}; no import broken by the patch stack "
          f"({_n(len(dangling & upstream), 'pre-existing upstream problem')} ignored)")


def main(argv):
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--repo", default="vscode")
    common.add_argument("--patches", default="patches")
    common.add_argument("--quality", default=os.environ.get("VSCODE_QUALITY", ""))
    common.add_argument("--os", dest="os_name", default=os.environ.get("OS_NAME", ""))
    parser = argparse.ArgumentParser(description="VSCodium patch stack: import, export, rebase")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("import", parents=[common])
    sub.add_parser("verify", parents=[common])
    p = sub.add_parser("export", parents=[common])
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--no-verify", action="store_true")
    p = sub.add_parser("rebase", parents=[common])
    p.add_argument("onto", nargs="?", help="commit or tag to replay the patches onto "
                                            "(default: upstream/<quality>.json)")
    p.add_argument("--continue", dest="cont", action="store_true", help="go on after resolving a conflict")
    p.add_argument("--skip", nargs="?", const="", metavar="PATCH",
                   help="drop the current patch (or the named pending one) and go on")
    p.add_argument("--redo", action="store_true", help="undo the last applied patch and apply it again")
    p.add_argument("--abort", action="store_true", help="restore vscode/ as it was before the rebase")
    p.add_argument("--status", action="store_true")
    p.add_argument("--until", metavar="PATCH", help="stop after this patch")
    p.add_argument("-f", "--force", action="store_true", help="with --abort: discard unexported patches")
    args = parser.parse_args(argv)

    if args.command == "import":
        import_stack(args.repo, args.patches, args.quality, args.os_name)
    elif args.command == "verify":
        verify_tree(args.repo)
    elif args.command == "export":
        export_stack(args.repo, args.patches, dry_run=args.dry_run, verify=not args.no_verify)
    elif args.status:
        rebase_status(args.repo)
    elif args.abort:
        rebase_abort(args.repo, args.force or os.environ.get("VSCODIUM_FORCE_RESET") == "1")
    elif args.redo:
        rebase_redo(args.repo)
    elif args.cont or args.skip is not None:
        rebase_continue(args.repo, args.until, skip=args.skip)
    else:
        rebase_start(args.repo, args.patches, args.onto, args.quality, args.os_name, args.until)


if __name__ == "__main__":
    try:
        main(sys.argv[1:])
    except KeyboardInterrupt:
        sys.exit(130)
    except BrokenPipeError:
        try:
            os.dup2(os.open(os.devnull, os.O_WRONLY), sys.stdout.fileno())
        except OSError:
            pass
        sys.exit(0)
