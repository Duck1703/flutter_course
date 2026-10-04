# Step 29 — validation: coverage / duplicates / placeholders / contract
import glob, io, os, re, sys

sys.stdout.reconfigure(encoding='utf-8')
ROOT = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(os.path.dirname(ROOT)))
DOCS = os.path.join(REPO, 'web', 'src', 'content', 'docs')

fail = []
files = sorted(glob.glob(os.path.join(DOCS, 'm*', '0*.md')))

# 1. coverage + duplicate heading
for path in files:
    rel = os.path.relpath(path, DOCS)
    text = io.open(path, encoding='utf-8').read()
    n = text.count('## 🤖 AI Local')
    if n == 0:
        fail.append(f'MISSING_SECTION {rel}')
    elif n > 1:
        fail.append(f'DUPLICATE_SECTION x{n} {rel}')
    seg = text[text.rindex('## 🤖 AI Local'):]
    # 2. placeholders / template leftovers — strip quoted spans first so
    #    rules *about* placeholders (e.g. `"TODO migrate"` honesty check)
    #    are not flagged as placeholders themselves
    scan = re.sub(r'"[^"\n]*"', '', seg)
    for pat in ('TODO', 'FIXME', 'XXX', '<ĐIỀN', 'PLACEHOLDER', '{{', '}}'):
        if pat in scan:
            fail.append(f'PLACEHOLDER[{pat}] {rel}')
    # 3. truncated fence: every ```text must close inside the segment
    if seg.count('```') % 2 != 0:
        fail.append(f'UNCLOSED_FENCE {rel}')
    # 4. prompt contract tail
    has_prompt = 'Bạn là Project Alignment Reviewer' in seg
    nr = ('không thay đổi project' in seg or 'không cần AI kiểm tra' in seg
          or 'Không cần review project' in seg)
    if has_prompt:
        if 'FILES_MODIFIED_BY_REVIEW: NONE' not in seg:
            fail.append(f'MISSING_OUTPUT_TAIL {rel}')
        for key in ('PROJECT_ALIGNMENT:', 'COURSE_POSITION:',
                    'READY_FOR_NEXT_LESSON:', 'EXPECTED STATE', 'EVIDENCE:'):
            if key not in seg:
                fail.append(f'MISSING_KEY[{key}] {rel}')
        if 'KHÔNG SỬA' not in seg:
            fail.append(f'MISSING_READONLY_CONTRACT {rel}')
    elif not nr:
        fail.append(f'NO_PROMPT_AND_NOT_MARKED_NOREVIEW {rel}')
    # 5. section must be the last content block (nothing but whitespace/
    #    blank lines after the closing fence)
    tail = seg.rstrip()
    if has_prompt and not tail.rstrip().endswith('```'):
        fail.append(f'TRAILING_CONTENT_AFTER_FENCE {rel}')

# 6. prompt id locked to lesson id
for path in files:
    rel = os.path.relpath(path, DOCS).replace(os.sep, '/')
    lid = rel.split('/')[0] + '/' + rel.split('/')[1][:2]
    text = io.open(path, encoding='utf-8').read()
    seg = text[text.rindex('## 🤖 AI Local'):]
    m = re.search(r'LESSON: (m\d\d/\d\d)', seg)
    if m and m.group(1) != lid:
        fail.append(f'LESSON_ID_MISMATCH {rel} says {m.group(1)}')

print(f'files={len(files)} failures={len(fail)}')
for x in fail:
    print(' ', x)
sys.exit(1 if fail else 0)
