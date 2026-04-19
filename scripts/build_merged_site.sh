#!/usr/bin/env bash
set -euo pipefail

ROOT_SRC="skyes-over-london-linked-website-package (1) (1) (1) (1)"
SKYESOL_SRC="skyesol-main (1) (1) (1) (1) (1)/skyesol-main"
SOLE_SRC="SOLEnterprises.org-main (2) (1) (1) (1) (1)/SOLEnterprises.org-main"

MERGED_DIR="skyes-over-london-linked-website-package-with-skyesol-and-solenterprises"
ZIP_NAME="skyes-over-london-linked-website-package-with-skyesol-and-solenterprises.zip"

rm -rf "$MERGED_DIR" "$ZIP_NAME"
cp -a "$ROOT_SRC" "$MERGED_DIR"
cp -a "$SKYESOL_SRC" "$MERGED_DIR/skyesol"
cp -a "$SOLE_SRC" "$MERGED_DIR/solenterprises"

python3 - <<'PY'
from pathlib import Path

merged = Path('skyes-over-london-linked-website-package-with-skyesol-and-solenterprises')

# 1) Root homepage: add direct links to all nested sites.
root_index = merged / 'index.html'
text = root_index.read_text(encoding='utf-8')
old_nav = '<a class="site-bridge" href="skyehands/index.html">Open SkyeHands Site</a>'
new_nav = (
    '<a class="site-bridge" href="skyehands/index.html">Open SkyeHands Site</a>\n'
    '      <a class="site-bridge" href="skyesol/index.html">Open SkyeSol Site</a>\n'
    '      <a class="site-bridge" href="solenterprises/index.html">Open SOLEnterprises Site</a>'
)
if old_nav in text:
    text = text.replace(old_nav, new_nav, 1)

hero_old = (
    '<div class="hero-actions">\n'
    '          <a class="bridge-btn primary" href="skyehands/index.html">Enter SkyeHands Site</a>\n'
    '        </div>'
)
hero_new = (
    '<div class="hero-actions">\n'
    '          <a class="bridge-btn primary" href="skyehands/index.html">Enter SkyeHands Site</a>\n'
    '          <a class="bridge-btn" href="skyesol/index.html">Enter SkyeSol Site</a>\n'
    '          <a class="bridge-btn" href="solenterprises/index.html">Enter SOLEnterprises Site</a>\n'
    '        </div>'
)
if hero_old in text:
    text = text.replace(hero_old, hero_new, 1)

root_index.write_text(text, encoding='utf-8')

# 2) SkyeHands: add cross-links to SkyeSol and SOLEnterprises
skh_index = merged / 'skyehands' / 'index.html'
text = skh_index.read_text(encoding='utf-8')
menu_anchor = '<a class="ni site-return" href="../index.html">← Main Ecosystem Site</a>'
menu_links = (
    '<a class="ni site-return" href="../index.html">← Main Ecosystem Site</a>\n'
    '      <a class="ni site-return" href="../skyesol/index.html">↗ SkyeSol Site</a>\n'
    '      <a class="ni site-return" href="../solenterprises/index.html">↗ SOLEnterprises Site</a>'
)
if menu_anchor in text:
    text = text.replace(menu_anchor, menu_links, 1)

cta_anchor = '<a class="ncta site-home-link" href="../index.html">Main Ecosystem Site ↗</a>'
cta_links = (
    '<a class="ncta site-home-link" href="../index.html">Main Ecosystem Site ↗</a>\n'
    '    <a class="ncta site-home-link" href="../skyesol/index.html">SkyeSol ↗</a>\n'
    '    <a class="ncta site-home-link" href="../solenterprises/index.html">SOLEnterprises ↗</a>'
)
if cta_anchor in text:
    text = text.replace(cta_anchor, cta_links, 1)

skh_index.write_text(text, encoding='utf-8')

# 3) SkyeSol: fix base path and add bridge nav links.
skyesol_index = merged / 'skyesol' / 'index.html'
text = skyesol_index.read_text(encoding='utf-8')
text = text.replace('<base href="/">', '<base href="./">', 1)

bridge_css = '''\n<style id="cross-site-bridge-style">\n.cross-site-bridge{position:fixed;left:16px;bottom:16px;z-index:100010;display:flex;gap:8px;flex-wrap:wrap;max-width:min(94vw,900px)}\n.cross-site-bridge a{display:inline-flex;align-items:center;justify-content:center;padding:8px 12px;border-radius:999px;border:1px solid rgba(255,255,255,.22);background:rgba(5,8,22,.82);color:#f5cf86;text-decoration:none;font:600 11px/1.1 system-ui,-apple-system,Segoe UI,sans-serif;letter-spacing:.08em;text-transform:uppercase}\n.cross-site-bridge a:hover{color:#fff;border-color:rgba(245,207,134,.5)}\n</style>\n'''
bridge_html = '''\n<div class="cross-site-bridge" aria-label="Cross-site navigation">\n  <a href="../index.html">Main Site</a>\n  <a href="../skyehands/index.html">SkyeHands</a>\n  <a href="./index.html">SkyeSol</a>\n  <a href="../solenterprises/index.html">SOLEnterprises</a>\n</div>\n'''
if 'id="cross-site-bridge-style"' not in text:
    text = text.replace('</head>', f'{bridge_css}</head>', 1)
if 'class="cross-site-bridge"' not in text:
    text = text.replace('</body>', f'{bridge_html}</body>', 1)

skyesol_index.write_text(text, encoding='utf-8')

# 4) SOLEnterprises: add bridge nav links.
sole_index = merged / 'solenterprises' / 'index.html'
text = sole_index.read_text(encoding='utf-8')
if 'id="cross-site-bridge-style"' not in text:
    text = text.replace(
        '</head>',
        bridge_css + '</head>',
        1
    )
if 'class="cross-site-bridge"' not in text:
    text = text.replace('</body>', f'{bridge_html}</body>', 1)
sole_index.write_text(text, encoding='utf-8')
PY

zip -rq "$ZIP_NAME" "$MERGED_DIR"

echo "Built: $MERGED_DIR"
echo "Built: $ZIP_NAME"
