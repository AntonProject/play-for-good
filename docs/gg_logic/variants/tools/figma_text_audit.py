#!/usr/bin/env python3
"""Text style audit: Figma frames vs FlutterFlow pages.

Figma side: REST API (not MCP), token FIGMA_TOKEN from the environment
(e.g. `set -a; source ~/.config/figma/env; set +a`). Read-only calls:
  GET /v1/files/:key?depth=2           (--list: pages and top-level frames)
  GET /v1/files/:key/nodes?ids=...     (visible TEXT nodes with styles)
FF side: a JSON dump of all widget classes (dsl/gg_dump_classes.dart).

Matching is by text content (static labels). Texts that exist on only one side
(dynamic values, names, numbers) are listed separately for a manual pass.
Compared: font size, weight, letter spacing (px), line height (multiplier),
italic. Theme styles of FF are resolved with the mobile typography.

  figma_text_audit.py --file KEY --list
  figma_text_audit.py --file KEY --frames 1:2,3:4 --ff-json classes.json \
      --ff-scope GoodGamesPage,gamesUserComp [--out report.md]
"""
import argparse, json, os, re, subprocess, sys

API = 'https://api.figma.com/v1'
THEME = {  # mobile typography of the FF theme: size, weight
    'DISPLAY_LARGE': (66, 600), 'DISPLAY_MEDIUM': (46, 600), 'DISPLAY_SMALL': (36, 700),
    'HEADLINE_LARGE': (34, 600), 'HEADLINE_MEDIUM': (30, 600), 'HEADLINE_SMALL': (26, 500),
    'TITLE_LARGE': (22, 600), 'TITLE_MEDIUM': (20, 600), 'TITLE_SMALL': (18, 500),
    'LABEL_LARGE': (18, 400), 'LABEL_MEDIUM': (16, 400), 'LABEL_SMALL': (14, 400),
    'BODY_LARGE': (18, 400), 'BODY_MEDIUM': (16, 400), 'BODY_SMALL': (12, 600),
}


def get(path):
    token = os.environ.get('FIGMA_TOKEN')
    if not token:
        sys.exit('FIGMA_TOKEN is not set (source ~/.config/figma/env)')
    # System curl (macOS keychain certificates); the header comes from stdin,
    # so the token is not visible in the process list.
    r = subprocess.run(['curl', '-sS', '--fail-with-body', '--max-time', '180', '-H', '@-', API + path],
                       input=f'X-Figma-Token: {token}\n', capture_output=True, text=True)
    if r.returncode != 0:
        sys.exit(f'Figma API error ({r.returncode}): {r.stdout[:300]} {r.stderr[:300]}')
    return json.loads(r.stdout)


def norm(s):
    return re.sub(r'\s+', ' ', str(s)).strip().lower()


def figma_texts(doc, frame_name):
    out = []

    def walk(n, visible):
        visible = visible and n.get('visible', True)
        if not visible:
            return
        if n.get('type') == 'TEXT':
            st = n.get('style', {})
            fs = st.get('fontSize')
            lh = None
            if st.get('lineHeightUnit') != 'INTRINSIC_%' and st.get('lineHeightPx') and fs:
                lh = round(st['lineHeightPx'] / fs, 2)
            out.append({
                'frame': frame_name, 'id': n['id'], 'text': n.get('characters', ''),
                'family': st.get('fontFamily'), 'fs': fs, 'fw': st.get('fontWeight'),
                'ls': round(st.get('letterSpacing', 0) or 0, 3), 'lh': lh,
                'italic': bool(st.get('italic')), 'case': st.get('textCase'),
            })
        for c in n.get('children', []):
            walk(c, visible)

    walk(doc, True)
    return out


def num(v):
    if not isinstance(v, dict):
        return None
    iv = v.get('inputValue')
    if isinstance(iv, (int, float)):
        return iv
    var = v.get('variable', {})
    code = (var.get('functionCall', {}).get('codeExpression', {}).get('expression')
            or var.get('baseVariable', {}).get('customCodeExpression', {}).get('code'))
    try:
        return float(code) if code is not None else None
    except ValueError:
        return None


def ff_texts(classes, scope):
    out = []
    for cls in scope:
        w = classes.get(cls)
        if not w:
            print(f'! FF class {cls} not found', file=sys.stderr)
            continue

        def walk(n):
            p = n.get('props', {})
            t = None
            if n['type'] == 'Text':
                t = p.get('text')
            elif n['type'] == 'Button':
                t = p.get('button', {}).get('text')
            elif n['type'] == 'RichTextSpan':
                t = p.get('richTextSpan', {}).get('text')
            if t:
                tv = t.get('textValue', {})
                text = tv.get('inputValue') if 'inputValue' in tv else None
                base = THEME.get(t.get('themeStyle', 'BODY_MEDIUM'), (None, None))
                fw = (t.get('fontWeightValue') or {}).get('inputValue')
                fw = int(fw[1:]) if isinstance(fw, str) and fw.startswith('w') else base[1]
                out.append({
                    'cls': cls, 'key': n['key'], 'text': text,
                    'expr': None if text is not None else json.dumps(tv)[:80],
                    'fs': num(t.get('fontSizeValue')) or base[0], 'fw': fw,
                    'ls': num(t.get('letterSpacingValue')), 'lh': num(t.get('heightValue')),
                    'italic': bool((t.get('italicValue') or {}).get('inputValue')),
                    'family': t.get('fontFamily') or 'DM Sans (theme)',
                })
            for c in n.get('children', []):
                walk(c)

        walk(w['node'])
    return out


def close(a, b, tol):
    if a is None and b is None:
        return True
    if a is None or b is None:
        return False
    return abs(float(a) - float(b)) <= tol


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--file', required=True)
    ap.add_argument('--list', action='store_true')
    ap.add_argument('--frames')
    ap.add_argument('--ff-json')
    ap.add_argument('--ff-scope')
    ap.add_argument('--out')
    a = ap.parse_args()

    if a.list:
        doc = get(f'/files/{a.file}?depth=2')['document']
        for page in doc.get('children', []):
            print(f"# {page['id']}  {page['name']}")
            for f in page.get('children', []):
                print(f"   {f['id']:>14}  {f['type']:<8} {f['name']}")
        return

    ids = a.frames.replace('-', ':')
    nodes = get(f'/files/{a.file}/nodes?ids={ids}')['nodes']
    fig = []
    for nid, data in nodes.items():
        if not data:
            print(f'! frame {nid} not found', file=sys.stderr)
            continue
        fig += figma_texts(data['document'], data['document']['name'])
    classes = json.load(open(a.ff_json))
    ff = ff_texts(classes, a.ff_scope.split(','))

    by_text = {}
    for t in ff:
        if t['text'] is not None:
            by_text.setdefault(norm(t['text']), []).append(t)
    rows, unmatched_fig, matched_ff = [], [], set()
    for f in fig:
        cands = by_text.get(norm(f['text']))
        if not cands:
            unmatched_fig.append(f)
            continue
        for t in cands:
            matched_ff.add(t['key'])
            diffs = []
            if not close(f['fs'], t['fs'], 0.01):
                diffs.append(f"size {t['fs']} → {f['fs']}")
            if f['fw'] and t['fw'] and int(f['fw']) != int(t['fw']):
                diffs.append(f"weight {t['fw']} → {f['fw']}")
            if not close(f['ls'] or 0, t['ls'] or 0, 0.03):
                diffs.append(f"ls {t['ls']} → {f['ls']}")
            if f['lh'] is not None and not close(f['lh'], t['lh'] or 0, 0.05):
                diffs.append(f"lh {t['lh']} → {f['lh']}")
            if f['italic'] != t['italic']:
                diffs.append(f"italic {t['italic']} → {f['italic']}")
            rows.append((f, t, diffs))

    lines = ['| Текст | FF узел | Figma | Расхождения |', '|---|---|---|---|']
    for f, t, diffs in rows:
        if diffs:
            fig_style = f"{f['family']} {f['fw']} {f['fs']}, ls {f['ls']}, lh {f['lh']}"
            lines.append(f"| {f['text'][:40]} | {t['cls']}/{t['key']} | {fig_style} | {'; '.join(diffs)} |")
    ok = sum(1 for r in rows if not r[2])
    lines.append(f'\nСовпадают: {ok}, с расхождениями: {len(rows) - ok}.')
    lines.append('\n## Только в Figma (динамические или нет в FF)')
    seen = set()
    for f in unmatched_fig:
        k = (f['text'][:40], f['fs'], f['fw'])
        if k in seen:
            continue
        seen.add(k)
        lines.append(f"- {f['frame'][:30]} · «{f['text'][:40]}» — {f['family']} {f['fw']} {f['fs']}, ls {f['ls']}, lh {f['lh']}")
    lines.append('\n## Только в FF (динамические тексты)')
    for t in ff:
        if t['key'] not in matched_ff:
            label = repr(t['text'])[:40] if t['text'] is not None else t['expr']
            lines.append(f"- {t['cls']}/{t['key']} {label} — {t['fw']} {t['fs']}, ls {t['ls']}, lh {t['lh']}")
    report = '\n'.join(lines)
    if a.out:
        open(a.out, 'w').write(report)
    print(report)


if __name__ == '__main__':
    main()
