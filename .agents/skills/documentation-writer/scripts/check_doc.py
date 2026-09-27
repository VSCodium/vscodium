#!/usr/bin/env python3
"""
check_doc.py — documentation-writer 的交付前自检。

用法：
  python3 check_doc.py DOC [DOC ...] [--repo-root DIR] [--base DIR ...]

检查项：
  错误（退出码 1）：
    - 行内代码和 Markdown 链接里引用的本地路径不存在，或行号超出文件长度
    - 残留的模板占位符（取自 assets/templates/ 里的占位符）
    - 疑似凭据（带 token 的 URL、常见密钥前缀、私钥头）
  提示（不影响退出码）：
    - AI 腔词汇、破折号密度、标题里的 emoji、[XXX] 这类疑似未填的大写占位
    - 不确定性标记和图的数量统计

路径解析顺序：文档所在目录及其各级父目录（直到仓库根）、仓库根、--base 指定的目录。
"""

import argparse
import re
import subprocess
import sys
from pathlib import Path

MARKERS = ["[TODO]", "[ASK USER]", "[INFERRED]", "[UNVERIFIED]"]

FILE_EXTS = {
    "ts", "tsx", "js", "jsx", "mjs", "cjs", "json", "jsonc", "md", "mdx", "py", "go", "rs",
    "java", "kt", "kts", "rb", "php", "cs", "fs", "swift", "c", "h", "cpp", "hpp", "yaml",
    "yml", "toml", "sql", "sh", "bash", "zsh", "html", "css", "scss", "less", "vue", "svelte",
    "xml", "gradle", "lock", "txt", "cfg", "ini", "proto", "graphql", "gql", "prisma", "png",
    "jpg", "jpeg", "gif", "svg", "webp", "pdf", "csv", "env", "example", "tf", "hcl", "mod",
    "sum", "dart", "ex", "exs", "lua", "r", "scala", "http",
}
BARE_NAMES = {"Dockerfile", "Makefile", "justfile", "Justfile", "Procfile", "LICENSE",
              "Gemfile", "Rakefile", "Containerfile", "CODEOWNERS"}

LINE_SUFFIX = re.compile(r"(?:#L(\d+)(?:-L?(\d+))?|:L?(\d+)(?:-L?(\d+))?)$")
BAD_PATH_CHARS = set(" \t*<>{}=(),'\"|?$`;")

AI_WORDS_ZH = [
    "赋能", "助力", "打造", "一站式", "全方位", "多维度", "无缝", "强大的", "极致", "卓越",
    "业界领先", "革命性", "颠覆", "重塑", "引领", "里程碑", "至关重要", "不可或缺",
    "保驾护航", "坚实的基础", "旨在", "致力于", "扮演着", "发挥着", "深入探讨", "全面解析",
    "一文读懂", "值得注意的是", "需要指出的是", "众所周知", "不难发现", "综上所述",
    "总而言之", "未来可期", "拭目以待", "显著提升", "极大地", "闭环", "抓手", "底层逻辑",
    "只需", "轻松", "希望对你有帮助", "在当今", "随着.{0,12}的快速发展",
]
AI_WORDS_EN = [
    "delve", "leverage", "leveraging", "harness", "seamless", "seamlessly", "robust",
    "cutting-edge", "state-of-the-art", "groundbreaking", "revolutionize", "tapestry",
    "testament", "paradigm shift", "myriad", "plethora", "streamline", "empower",
    "game-changer", "it's worth noting", "it is important to note", "in today's",
    "furthermore", "moreover", "in conclusion", "i hope this helps", "simply", "effortlessly",
]
CREDENTIAL_PATTERNS = [
    (re.compile(r"https?://[^/\s:@]+:[^/\s@]+@"), "URL 里带用户名密码"),
    (re.compile(r"https?://[A-Za-z0-9_\-]{20,}@"), "URL 里带 token"),
    (re.compile(r"\bghp_[A-Za-z0-9]{20,}"), "GitHub token"),
    (re.compile(r"\bgithub_pat_[A-Za-z0-9_]{20,}"), "GitHub token"),
    (re.compile(r"\bglpat-[A-Za-z0-9_\-]{16,}"), "GitLab token"),
    (re.compile(r"\bsk-[A-Za-z0-9]{20,}"), "API 密钥"),
    (re.compile(r"\bAKIA[0-9A-Z]{16}\b"), "AWS access key"),
    (re.compile(r"\bxox[baprs]-[A-Za-z0-9\-]{10,}"), "Slack token"),
    (re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----"), "私钥"),
]
EMOJI = re.compile("[\U0001F300-\U0001FAFF☀-➿⭐✅❌]")
UPPER_PLACEHOLDER = re.compile(r"\[([A-Z][A-Z0-9_]{2,}(?: [A-Z0-9_]+)*)\](?!\()")


def repo_files(root: Path):
    try:
        out = subprocess.run(["git", "ls-files"], cwd=root, capture_output=True, text=True, check=True).stdout
        return set(out.splitlines())
    except Exception:
        return None


def template_placeholders(skill_dir: Path):
    tokens = set()
    for t in (skill_dir / "assets" / "templates").glob("*.md"):
        for m in re.finditer(r"\[([^\]\n]+)\](?!\()", t.read_text(encoding="utf-8")):
            tok = "[" + m.group(1) + "]"
            if tok not in MARKERS and not tok.startswith("[ASK USER]"):
                tokens.add(tok)
    return tokens


def split_code(text: str):
    """返回 (正文行列表, 每行是否在代码块内)。"""
    lines, in_fence, flags = text.splitlines(), False, []
    for line in lines:
        if line.lstrip().startswith(("```", "~~~")):
            flags.append(True)
            in_fence = not in_fence
            continue
        flags.append(in_fence)
    return lines, flags


def looks_like_path(tok: str, bases):
    if not tok or tok.startswith(("http:", "https:", "mailto:", "/", "@", "~", "-", "#", "node:")):
        return False
    if any(c in BAD_PATH_CHARS for c in tok) or ":" in tok:
        return False
    if tok in BARE_NAMES or tok.endswith("/"):
        return True
    name = tok.rstrip("/").split("/")[-1]
    if "." in name and name.rsplit(".", 1)[-1].lower() in FILE_EXTS:
        return True
    if "/" in tok:
        first = tok.split("/")[0]
        return any((b / first).exists() for b in bases)
    return False


def resolve(tok: str, bases, files, root: Path):
    for b in bases:
        p = b / tok
        if p.exists():
            return p
    if "/" not in tok.rstrip("/") and files is not None:
        for f in files:
            if f == tok or f.endswith("/" + tok):
                return root / f
    return None


def line_count(p: Path):
    try:
        with p.open("rb") as fh:
            return sum(1 for _ in fh)
    except Exception:
        return None


def check(doc: Path, root: Path, extra_bases, files, placeholders):
    errors, warns, info = [], [], {}
    text = doc.read_text(encoding="utf-8")
    lines, in_code = split_code(text)

    bases, d = [], doc.parent.resolve()
    while True:
        bases.append(d)
        if d == root or d.parent == d:
            break
        d = d.parent
    if root not in bases:
        bases.append(root)
    bases += extra_bases

    seen = set()
    for i, line in enumerate(lines, 1):
        if in_code[i - 1]:
            continue
        cands = [(m.group(1), False) for m in re.finditer(r"`([^`\n]+)`", line)]
        cands += [(m.group(1), True) for m in re.finditer(r"!?\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)", line)]
        for raw, is_link in cands:
            tok = raw.strip()
            if is_link:
                if tok.startswith(("http:", "https:", "mailto:", "#")):
                    continue
                if "#" in tok and not re.search(r"#L\d+", tok):
                    tok = tok.split("#", 1)[0]
            m = LINE_SUFFIX.search(tok)
            lo = hi = None
            if m:
                nums = [int(x) for x in m.groups() if x]
                lo, hi = nums[0], nums[-1]
                tok = tok[: m.start()]
            if (tok, lo, hi) in seen:
                continue
            seen.add((tok, lo, hi))
            if is_link:
                target = (doc.parent / tok)
                if not target.exists():
                    errors.append(f"{doc}:{i} 链接目标不存在：{raw}")
                continue
            if not looks_like_path(tok, bases):
                continue
            p = resolve(tok, bases, files, root)
            if p is None:
                errors.append(f"{doc}:{i} 引用的路径不存在：{raw}")
            elif hi and p.is_file():
                n = line_count(p)
                if n is not None and hi > n:
                    errors.append(f"{doc}:{i} 行号超出范围：{raw}（文件共 {n} 行）")

        bare = re.sub(r"`[^`]*`", "", line)
        for tok in placeholders:
            if tok in bare:
                errors.append(f"{doc}:{i} 残留模板占位符：{tok}")
        for m in UPPER_PLACEHOLDER.finditer(bare):
            tok = "[" + m.group(1) + "]"
            # 只作提示：[DEPRECATED]、[WIP] 这类是正常用法，模板占位符已在上面精确匹配
            if tok not in MARKERS and tok not in placeholders:
                warns.append(f"{doc}:{i} 疑似未填占位符：{tok}")

    for i, line in enumerate(lines, 1):
        for pat, label in CREDENTIAL_PATTERNS:
            if pat.search(line):
                errors.append(f"{doc}:{i} 疑似凭据（{label}）")

    prose = [(i, l) for i, l in enumerate(lines, 1) if not in_code[i - 1]]
    prose_text = "\n".join(re.sub(r"`[^`]*`", "", l) for _, l in prose)
    hits = []
    for w in AI_WORDS_ZH:
        n = len(re.findall(w, prose_text))
        if n:
            hits.append(f"{w}×{n}")
    low = prose_text.lower()
    for w in AI_WORDS_EN:
        n = len(re.findall(r"\b" + re.escape(w) + r"\b", low))
        if n:
            hits.append(f"{w}×{n}")
    if hits:
        warns.append(f"{doc} AI 腔词汇：" + "，".join(hits))

    paragraphs = len([b for b in re.split(r"\n\s*\n", prose_text) if b.strip()])
    dashes = prose_text.count("——") + prose_text.replace("——", "").count("—")
    if paragraphs and dashes * 3 > paragraphs:
        warns.append(f"{doc} 破折号偏多：{dashes} 处 / {paragraphs} 段（参考上限约每 3 段 1 处）")

    for i, l in prose:
        if l.lstrip().startswith("#") and EMOJI.search(l):
            warns.append(f"{doc}:{i} 标题里有 emoji：{l.strip()}")

    info["标记"] = {m: text.count(m) for m in MARKERS if text.count(m)}
    info["Mermaid 图"] = len(re.findall(r"^\s*```mermaid", text, re.M))
    info["HTML 图链接"] = len(re.findall(r"\]\([^)]+\.html\)", text))
    return errors, warns, info


def main():
    ap = argparse.ArgumentParser(description="documentation-writer 交付前自检")
    ap.add_argument("docs", nargs="+")
    ap.add_argument("--repo-root", help="仓库根目录，默认取 git 根或当前目录")
    ap.add_argument("--base", action="append", default=[], help="额外的路径解析基准目录，可重复")
    args = ap.parse_args()

    if args.repo_root:
        root = Path(args.repo_root).resolve()
    else:
        try:
            root = Path(subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True,
                                       text=True, check=True).stdout.strip()).resolve()
        except Exception:
            root = Path.cwd().resolve()
    extra = [Path(b).resolve() for b in args.base]
    files = repo_files(root)
    placeholders = template_placeholders(Path(__file__).resolve().parent.parent)

    total_err = 0
    for d in args.docs:
        doc = Path(d)
        if not doc.is_file():
            print(f"跳过：{d} 不是文件")
            continue
        errors, warns, info = check(doc, root, extra, files, placeholders)
        total_err += len(errors)
        print(f"== {doc}")
        for e in errors:
            print(f"  [错误] {e}")
        for w in warns:
            print(f"  [提示] {w}")
        print(f"  [统计] {info}")
    print(f"\n共 {total_err} 个错误" if total_err else "\n没有错误")
    sys.exit(1 if total_err else 0)


if __name__ == "__main__":
    main()
