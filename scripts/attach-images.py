import difflib
import json
import os
import re
import shutil
import sys
import unicodedata

# Usage: python3 scripts/attach-images.py [path-to-avtotestu-v3-checkout]
#
# Our question bank (sherzod-prostaleev/avtotestuz) ships without images
# (gitignored at the source). Hoffenuz/avtotestu-v3.0.0 is an independent
# transcription of the same official YHQ exam bank that DOES include
# question images. This script matches our questions to theirs by
# normalized Russian question text + answer-option overlap, and for
# matches above a confidence threshold copies the image locally and
# records the local path in public/data/questions.json (and mirrors it
# into mobile/assets/images/questions/ for the Flutter app).
#
# Matching is conservative: a candidate is only accepted when the
# question text matches (exact after normalization, or >=0.85 fuzzy
# ratio) AND at least half of our answer options textually overlap with
# theirs. Anything below that is left without an image rather than risk
# showing the wrong photo for a question.

REPO_ROOT = sys.argv[1] if len(sys.argv) > 1 else "../avtotestu-v3.0.0"
THEIR_ALL = os.path.join(REPO_ROOT, "public/barcha.json")
THEIR_IMAGES_DIR = os.path.join(REPO_ROOT, "public/images")

HERE = os.path.dirname(__file__)
QUESTIONS_PATH = os.path.join(HERE, "..", "public", "data", "questions.json")
OUR_IMAGES_DIR = os.path.join(HERE, "..", "public", "images", "questions")
MOBILE_IMAGES_DIR = os.path.join(HERE, "..", "mobile", "assets", "images", "questions")

OVERLAP_THRESHOLD = 0.5
FUZZY_CUTOFF = 0.85


def norm(s):
    if not s:
        return ""
    s = unicodedata.normalize("NFKC", s)
    s = s.lower()
    s = re.sub(r"[«»\"'`.,;:!?()\-–—…]", "", s)
    s = re.sub(r"\s+", " ", s).strip()
    return s


def main():
    questions = json.load(open(QUESTIONS_PATH, encoding="utf-8"))
    theirs = json.load(open(THEIR_ALL, encoding="utf-8"))

    their_by_text = {}
    their_texts = []
    for q in theirs:
        text = norm(q["content"].get("ru", {}).get("text", ""))
        if text:
            their_by_text.setdefault(text, []).append(q)
            their_texts.append(text)

    os.makedirs(OUR_IMAGES_DIR, exist_ok=True)
    os.makedirs(MOBILE_IMAGES_DIR, exist_ok=True)

    accepted = 0
    rejected = 0
    no_text_match = 0

    for q in questions:
        if not q.get("hasImage"):
            continue
        ru_text = norm(q["texts"].get("ru", ""))
        our_opts = {norm(a["texts"]["ru"]) for a in q["answers"]}

        candidates = list(their_by_text.get(ru_text, []))
        if not candidates:
            for close_text in difflib.get_close_matches(ru_text, their_texts, n=3, cutoff=FUZZY_CUTOFF):
                candidates.extend(their_by_text[close_text])

        pool = [c for c in candidates if c.get("media_url")] or candidates
        if not pool:
            no_text_match += 1
            continue

        best_c, best_overlap = None, -1.0
        for c in pool:
            their_opts = {norm(o["text"]) for o in c["content"]["ru"]["options"]}
            overlap = len(our_opts & their_opts) / max(1, len(our_opts))
            if overlap > best_overlap:
                best_overlap, best_c = overlap, c

        if best_overlap < OVERLAP_THRESHOLD or not best_c.get("media_url"):
            rejected += 1
            continue

        src = os.path.join(THEIR_IMAGES_DIR, best_c["media_url"])
        if not os.path.exists(src):
            rejected += 1
            continue

        ext = os.path.splitext(best_c["media_url"])[1]
        dest_name = f"{q['id']}{ext}"
        shutil.copyfile(src, os.path.join(OUR_IMAGES_DIR, dest_name))
        shutil.copyfile(src, os.path.join(MOBILE_IMAGES_DIR, dest_name))
        q["image"] = f"images/questions/{dest_name}"
        accepted += 1

    json.dump(questions, open(QUESTIONS_PATH, "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))

    print(f"accepted: {accepted}")
    print(f"rejected (low overlap / missing file): {rejected}")
    print(f"no text match: {no_text_match}")
    print(f"total questions with hasImage: {sum(1 for q in questions if q.get('hasImage'))}")


if __name__ == "__main__":
    main()
