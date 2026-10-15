#!/usr/bin/env python3
"""Plan data defaults for texts (app screens, not admin).

Rule (owner, 14 Oct): a text showing a DB value that is missing
  * number  -> default 0
  * string / date -> the text is hidden (visible only if the value exists)
  * a default already present -> unchanged
Only values shown directly are handled: the text's own variable, or a direct
part of a string interpolation ("Game #{…}"). Values passed into functions are
left to the function (gg* functions never return null).

Input: classes.json (dsl/gg_dump_classes.dart) and the exported table classes
(lib/backend/supabase/database/tables) for field types.
Output: a JSON list of patch ops for dsl/gg_apply_text_defaults.dart:
  {"cls", "node", "op": "default", "path": [...], "value": "0"}
  {"cls", "node", "op": "hide_if_empty", "leaf": {...}}
"""
import glob, json, re, sys, collections

classes = json.load(open(sys.argv[1]))
tables_dir = sys.argv[2]
out = sys.argv[3]

ftype = collections.defaultdict(set)
for f in glob.glob(tables_dir + '/*.dart'):
    s = open(f).read()
    for m in re.finditer(r"get \w+ => getField<(\w+)>\('(\w+)'\)", s):
        ftype[m.group(2)].add(m.group(1))

DATA = {'POSTGRES_QUERY', 'LOCAL_STATE', 'WIDGET_CLASS_PARAMETER', 'GENERATOR_VARIABLE', 'ACTION_OUTPUTS'}


def param_type(cls, name):
    for p in (classes[cls].get('params') or {}).values():
        if p['identifier']['name'] == name:
            return p.get('dataType', {}).get('scalarType')
    return None


def kind(cls, v):
    ops = v.get('operations') or []
    s = json.dumps(ops)
    if 'numberFormat' in s:
        return 'num'
    m = re.search(r'"returnParameter": \{"dataType": \{"scalarType": "(\w+)"', s)
    if m:
        t = m.group(1)
        return 'num' if t in ('Integer', 'Double') else 'str' if t == 'String' else 'date' if t == 'DateTime' else None
    f = re.findall(r'"accessPostgresRowField": \{"fieldIdentifier": \{"name": "(\w+)"', s)
    if f:
        t = ftype.get(f[-1], set())
        if t and t <= {'int', 'double'}:
            return 'num'
        if t == {'String'}:
            return 'str'
        if t == {'DateTime'}:
            return 'date'
        return None
    if v.get('source') == 'WIDGET_CLASS_PARAMETER' and not ops:
        t = param_type(cls, v['baseVariable']['widgetClass']['paramIdentifier']['name'])
        return 'num' if t in ('Integer', 'Double') else 'str' if t == 'String' else 'date' if t == 'DateTime' else None
    return None


ops, skipped = [], collections.Counter()
for cls, w in classes.items():
    if 'admin' in cls.lower():
        continue

    def walk(n):
        if n['type'] in ('Text', 'RichTextSpan'):
            base = ['props', 'text'] if n['type'] == 'Text' else ['props', 'richTextSpan', 'text']
            t = n
            for k in base:
                t = (t or {}).get(k)
            tv = (t or {}).get('textValue', {})
            v = tv.get('variable')
            leaves = []
            if isinstance(v, dict):
                if v.get('source') in DATA:
                    leaves.append((base + ['textValue', 'variable'], v))
                elif 'stringInterpolation' in (v.get('functionCall') or {}):
                    for i, part in enumerate(v['functionCall']['values']):
                        pv = part.get('variable')
                        if isinstance(pv, dict) and pv.get('source') in DATA:
                            leaves.append((base + ['textValue', 'variable', 'functionCall', 'values', i, 'variable'], pv))
            for path, leaf in leaves:
                if 'defaultValue' in leaf:
                    skipped['has default'] += 1
                    continue
                k = kind(cls, leaf)
                if k == 'num':
                    ops.append({'cls': cls, 'node': n['key'], 'op': 'default', 'path': path, 'value': '0'})
                elif k in ('str', 'date'):
                    if n['type'] == 'RichTextSpan':
                        skipped['string in rich text span (no visibility)'] += 1
                        continue
                    ops.append({'cls': cls, 'node': n['key'], 'op': 'hide_if_empty', 'leaf': leaf, 'kind': k})
                else:
                    skipped['unknown type'] += 1
        for c in n.get('children', []):
            walk(c)

    walk(w['node'])

json.dump(ops, open(out, 'w'), indent=1)
by = collections.Counter((o['op'], o['cls']) for o in ops)
for (op, cls), c in sorted(by.items()):
    print(f'{op:14} {cls:28} {c}')
print('total', len(ops), 'skipped', dict(skipped))
