import json, os, sys

# Usage: python3 scripts/build-data.py [path-to-avtotestuz-checkout]
# Reads backend/seed/avtoimtihon/data.json from a local clone of
# https://github.com/sherzod-prostaleev/avtotestuz and writes the slimmed
# public/data/*.json files this app fetches at runtime.
REPO_ROOT = sys.argv[1] if len(sys.argv) > 1 else "../avtotestuz"
SRC = os.path.join(REPO_ROOT, "backend/seed/avtoimtihon/data.json")
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "public", "data")

d = json.load(open(SRC, encoding="utf-8"))

categories = d["categories"]
questions = d["questions"]
variants = d["variants"]
explanations = {e["question"]: e for e in d["explanations"]}

cat_by_code = {c["code"]: c for c in categories}

# assign a stable numeric id per question ext_id, keep only fields the app needs
q_out = []
q_index = {}
for i, q in enumerate(questions):
    has_image = bool(q.get("image"))
    entry = {
        "id": q["ext_id"],
        "category": q["category"],
        "hasImage": has_image,
        "texts": q["texts"],
        "answers": [
            {"correct": a["correct"], "texts": a["texts"]}
            for a in q["answers"]
        ],
    }
    exp = explanations.get(q["ext_id"])
    if exp and exp.get("blocks"):
        entry["explanation"] = exp["blocks"]
    q_out.append(entry)
    q_index[q["ext_id"]] = i

variants_out = [
    {"number": v["number"], "questions": [q_index[qid] for qid in v["questions"]]}
    for v in variants
]

categories_out = [
    {"code": c["code"], "names": c["names"], "count": sum(1 for q in questions if q["category"] == c["code"])}
    for c in categories
    if any(q["category"] == c["code"] for q in questions)
]

with open(f"{OUT_DIR}/questions.json", "w", encoding="utf-8") as f:
    json.dump(q_out, f, ensure_ascii=False, separators=(",", ":"))
with open(f"{OUT_DIR}/variants.json", "w", encoding="utf-8") as f:
    json.dump(variants_out, f, ensure_ascii=False, separators=(",", ":"))
with open(f"{OUT_DIR}/categories.json", "w", encoding="utf-8") as f:
    json.dump(categories_out, f, ensure_ascii=False, separators=(",", ":"))

print("questions:", len(q_out))
print("variants:", len(variants_out))
print("categories:", len(categories_out))
print("with image:", sum(1 for q in q_out if q["hasImage"]))
print("with explanation:", sum(1 for q in q_out if "explanation" in q))
