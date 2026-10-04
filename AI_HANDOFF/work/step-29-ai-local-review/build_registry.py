# Step 29 — build per-lesson AI Local registry (md + json)
import glob, io, json, os, re, sys

sys.stdout.reconfigure(encoding='utf-8')
ROOT = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(os.path.dirname(ROOT)))
DOCS = os.path.join(REPO, 'web', 'src', 'content', 'docs')
SECS = os.path.join(ROOT, 'sections')

# canonical evidence-based gates (02-classification-rules.md)
GATES = {'m05/03','m10/04','m12/03','m14/07','m19/06','m22/05','m25/05','m26/06','m28/06','m29/07'}

# DELTA/INTEGRATION per recorded wave mappings; INTEGRATION = connects
# previously-taught parts (wiring, DI, screen<->VM, synthesis/regression).
INTEGRATION = {
 'm02/04','m04/03','m06/02','m07/03','m08/03','m09/03','m11/02','m12/01',
 'm13/02','m14/06','m16/04','m16/05','m17/03','m17/05','m18/04','m19/05',
 'm20/03','m20/04','m20/05','m21/04','m21/05','m22/04','m23/02','m23/05',
 'm24/02','m24/04','m24/05','m25/04','m26/05','m27/04','m27/05','m27/06',
 'm28/05','m29/04','m29/05','m29/06'}

rows = []
for path in sorted(glob.glob(os.path.join(DOCS, 'm*', '0*.md'))):
    rel = os.path.relpath(path, DOCS).replace(os.sep, '/')
    m = rel.split('/')[0]
    n = rel.split('/')[1][:2]
    lid = f'{m}/{n}'
    text = io.open(path, encoding='utf-8').read()
    seg = text[text.rindex('AI Local'):]
    nr = ('không thay đổi project' in seg or 'không cần AI kiểm tra' in seg
          or 'Không cần review project' in seg)
    has_prompt = 'Bạn là Project Alignment Reviewer' in seg
    cps = re.findall(r'\*\*(\d+)/(\d+)\*\*', seg)
    cp = f'{cps[-1][0]}/{cps[-1][1]}' if cps else None
    if nr:
        typ = 'NO_REVIEW'
    elif lid in GATES:
        typ = 'MILESTONE_GATE'
    elif lid in INTEGRATION:
        typ = 'INTEGRATION'
    else:
        typ = 'DELTA'
    slug = os.path.basename(rel)[:-3]
    sec = os.path.join(SECS, m, slug + '.md')
    rows.append({
        'lesson': lid, 'slug': slug, 'type': typ,
        'checkpoint_tests': cp, 'prompt': has_prompt,
        'section_file': os.path.relpath(sec, REPO).replace(os.sep, '/'),
        'section_exists': os.path.isfile(sec), 'applied': True,
    })

counts = {}
for r in rows:
    counts[r['type']] = counts.get(r['type'], 0) + 1

out_json = os.path.join(ROOT, 'registry.json')
with io.open(out_json, 'w', encoding='utf-8') as f:
    json.dump({'total': len(rows), 'by_type': counts, 'lessons': rows},
              f, ensure_ascii=False, indent=1)

lines = ['# Step 29 · AI Local — per-lesson registry', '',
 f'- TOTAL = {len(rows)}',
 f'- NO_REVIEW = {counts.get("NO_REVIEW",0)}'
 f' · DELTA = {counts.get("DELTA",0)}'
 f' · INTEGRATION = {counts.get("INTEGRATION",0)}'
 f' · MILESTONE_GATE = {counts.get("MILESTONE_GATE",0)}',
 '',
 '| lesson | type | checkpoint | section | applied |', '|---|---|---|---|---|']
for r in rows:
    lines.append(f"| {r['lesson']} {r['slug']} | {r['type']} | "
                 f"{r['checkpoint_tests'] or '—'} | "
                 f"`{os.path.basename(r['section_file'])}` | "
                 f"{'yes' if r['applied'] else 'NO'} |")
with io.open(os.path.join(ROOT, 'registry.md'), 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines) + '\n')

print('total:', len(rows), counts)
print('missing section files:', [r['lesson'] for r in rows if not r['section_exists']])
print('no-review without prompt check:',
      [r['lesson'] for r in rows if r['type'] == 'NO_REVIEW' and r['prompt']])
print('review without fence:',
      [r['lesson'] for r in rows if r['type'] != 'NO_REVIEW' and not r['prompt']])
