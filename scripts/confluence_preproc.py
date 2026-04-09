#!/usr/bin/env python3
"""
confluence_preproc.py — Pre-process Confluence storage-format HTML into standard
HTML suitable for conversion to CommonMark via pandoc.

Usage:
    curl ... | python3 confluence_preproc.py | pandoc --from=html --to=commonmark

Called automatically by confluence_publish.sh --pull. Not normally invoked directly.

Transformations applied (in order):
    ac:structured-macro name="code"              → <pre><code class="language-X">
    ac:structured-macro name="info|note|warning|tip" → <blockquote>
    ac:structured-macro name="expand"            → unwrapped rich-text body
    Remaining ac:structured-macro elements       → stripped (content discarded)
    CDATA sections                               → HTML-escaped inline text
    ac:* and ri:* namespace tags                 → stripped (inner text kept)
"""

import re
import sys
import html as htmlmod
import base64


def convert_code_macro(m: re.Match) -> str:
    """Convert a Confluence code macro to an HTML <pre><code> block."""
    block = m.group(0)
    lang_m  = re.search(r'ac:name=["\']?language["\']?[^>]*>\s*(.*?)\s*</ac:parameter>', block, re.DOTALL)
    cdata_m = re.search(r'<!\[CDATA\[(.*?)\]\]>', block, re.DOTALL)
    body_m  = re.search(r'<ac:plain-text-body>(.*?)</ac:plain-text-body>', block, re.DOTALL)
    lang = lang_m.group(1).strip() if lang_m else ""
    body = cdata_m.group(1) if cdata_m else (body_m.group(1).strip() if body_m else "")
    return '<pre><code class="language-{}">{}</code></pre>'.format(lang, htmlmod.escape(body))


def convert_panel(m: re.Match) -> str:
    """Convert info/note/warning/tip macros to <blockquote> elements."""
    block = m.group(0)
    nm = re.search(r'ac:name=["\']?(\w+)["\']?', block)
    bm = re.search(r'<ac:rich-text-body>(.*?)</ac:rich-text-body>', block, re.DOTALL)
    name = nm.group(1).upper() if nm else "NOTE"
    body = bm.group(1).strip() if bm else ""
    return "<blockquote><p><strong>{}:</strong></p>\n{}\n</blockquote>".format(name, body)


def unwrap_expand(m: re.Match) -> str:
    """Unwrap expand/collapsible macros — keep the body content."""
    block = m.group(0)
    bm = re.search(r'<ac:rich-text-body>(.*?)</ac:rich-text-body>', block, re.DOTALL)
    return bm.group(1).strip() if bm else ""


def recover_plantuml(m: re.Match) -> str:
    """Recover a plantuml fenced block from the base64 source stashed on publish."""
    try:
        src = base64.b64decode(m.group(1)).decode("utf-8")
    except Exception:
        return m.group(0)  # leave untouched if decoding fails
    return '<pre><code class="language-plantuml">{}</code></pre>'.format(htmlmod.escape(src))


def preprocess(text: str) -> str:
    # PlantUML round-trip: recover source from the HTML comment stashed during publish.
    # Pattern: <!-- plantuml_src_b64: BASE64 --><p><img ...></p>  (whitespace-tolerant)
    text = re.sub(
        r'<!-- plantuml_src_b64: ([A-Za-z0-9+/=]+) -->\s*<p><img[^>]*/></p>',
        recover_plantuml, text)

    # Code macros first — extract CDATA before the global CDATA sweep
    text = re.sub(
        r'<ac:structured-macro\s+ac:name=["\']?code["\']?[^>]*>.*?</ac:structured-macro>',
        convert_code_macro, text, flags=re.DOTALL)

    # Info / note / warning / tip panels
    text = re.sub(
        r'<ac:structured-macro\s+ac:name=["\']?(?:info|warning|note|tip)["\']?[^>]*>'
        r'.*?</ac:structured-macro>',
        convert_panel, text, flags=re.DOTALL)

    # Expand / collapsible sections — unwrap the body
    text = re.sub(
        r'<ac:structured-macro\s+ac:name=["\']?expand["\']?[^>]*>.*?</ac:structured-macro>',
        unwrap_expand, text, flags=re.DOTALL)

    # Drop any remaining structured macros (TOC, status, Jira, etc.)
    text = re.sub(
        r'<ac:structured-macro[^>]*>.*?</ac:structured-macro>', "", text, flags=re.DOTALL)

    # Remaining CDATA sections (outside macros) → HTML-escaped text
    text = re.sub(
        r'<!\[CDATA\[(.*?)\]\]>',
        lambda m: htmlmod.escape(m.group(1)), text, flags=re.DOTALL)

    # Strip ac: and ri: namespace tags, keeping any inner text content
    text = re.sub(r'</?ac:[^>]+/?>', "", text)
    text = re.sub(r'</?ri:[^>]+/?>', "", text)

    return text


if __name__ == "__main__":
    print(preprocess(sys.stdin.read()))
