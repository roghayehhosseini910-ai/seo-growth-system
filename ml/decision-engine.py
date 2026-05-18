import os
import json
import pandas as pd

ART_DIR = "/data/artifacts"
DEC_DIR = "/data/decisions"

IN_FILE = os.path.join(ART_DIR, "shap_predictions_sample.csv")
OUT_SUMMARY = os.path.join(DEC_DIR, "seo_actions_summary.csv")
OUT_DETAILS = os.path.join(DEC_DIR, "seo_actions_details.jsonl")

os.makedirs(DEC_DIR, exist_ok=True)

# --------------------------------------------------
# Load SHAP-based predictions
# --------------------------------------------------
df = pd.read_csv(IN_FILE)

required = {"page", "date", "prediction_proba"}
missing = required - set(df.columns)
if missing:
    raise ValueError(f"Missing required columns: {missing}")

shap_cols = [c for c in df.columns if c.startswith("shap__")]

# --------------------------------------------------
# Finglish action mapping (STANDARDIZED)
# --------------------------------------------------
def feature_to_actions(feature: str):
    f = feature.lower()
    actions = []

    if "ctr" in f:
        actions += [
            "Improve title with clear benefit and number",
            "Rewrite meta description with stronger CTA",
            "Add relevant schema to enhance SERP appearance",
        ]

    if "pos_" in f or "position" in f:
        actions += [
            "Add internal links from strong related pages",
            "Improve top section to better match search intent",
            "Check keyword cannibalization",
        ]

    if "impr" in f:
        actions += [
            "Expand content with PAA-based subtopics",
            "Improve internal linking for better discovery",
            "Check indexability and coverage issues",
        ]

    if "click" in f:
        actions += [
            "Optimize snippet to increase engagement",
            "Add contextual internal links inside content",
        ]

    if "vol" in f:
        actions += [
            "Stabilize content to reduce volatility",
            "Review competitors and recent SERP changes",
        ]

    if "delta" in f or "ma_" in f or "ago" in f:
        actions += [
            "If trend is negative, refresh content and intent alignment",
            "If trend is positive, reinforce page with internal links",
        ]

    if not actions:
        actions = ["Manual SEO review of title, content, and internal links"]

    # deduplicate
    return list(dict.fromkeys(actions))


# --------------------------------------------------
# Extract top positive SHAP signals
# --------------------------------------------------
def extract_top_signals(row, k=3):
    items = []
    for c in shap_cols:
        val = row[c]
        if pd.notna(val) and val > 0:
            items.append((c.replace("shap__", ""), float(val)))
    items.sort(key=lambda x: x[1], reverse=True)
    return items[:k]


# --------------------------------------------------
# Build outputs
# --------------------------------------------------
summary_rows = []
details_rows = []

for _, r in df.iterrows():
    proba = float(r["prediction_proba"])
    priority = "HIGH" if proba >= 0.75 else ("MED" if proba >= 0.55 else "LOW")

    top_signals = extract_top_signals(r, k=3)

    action_pool = []
    for feat, _ in top_signals:
        action_pool += feature_to_actions(feat)

    actions = list(dict.fromkeys(action_pool))[:3]

    # ---- Summary row (flat & clean)
    summary_rows.append({
        "page": r["page"],
        "date": r["date"],
        "prediction_proba": round(proba, 4),
        "priority": priority,
        "action_1": actions[0] if len(actions) > 0 else None,
        "action_2": actions[1] if len(actions) > 1 else None,
        "action_3": actions[2] if len(actions) > 2 else None,
        "signal_1_feature": top_signals[0][0] if len(top_signals) > 0 else None,
        "signal_1_shap": round(top_signals[0][1], 4) if len(top_signals) > 0 else None,
        "signal_2_feature": top_signals[1][0] if len(top_signals) > 1 else None,
        "signal_2_shap": round(top_signals[1][1], 4) if len(top_signals) > 1 else None,
        "signal_3_feature": top_signals[2][0] if len(top_signals) > 2 else None,
        "signal_3_shap": round(top_signals[2][1], 4) if len(top_signals) > 2 else None,
    })

    # ---- Details row (JSONL)
    details_rows.append({
        "page": r["page"],
        "date": r["date"],
        "prediction_proba": proba,
        "priority": priority,
        "recommended_actions": actions,
        "top_signals": [
            {"feature": f, "shap": v} for f, v in top_signals
        ]
    })


# --------------------------------------------------
# Save outputs
# --------------------------------------------------
pd.DataFrame(summary_rows).sort_values(
    ["priority", "prediction_proba"], ascending=[True, False]
).to_csv(OUT_SUMMARY, index=False)

with open(OUT_DETAILS, "w", encoding="utf-8") as f:
    for row in details_rows:
        f.write(json.dumps(row, ensure_ascii=False) + "\n")

print("✅ Decision Engine finished.")
print("Saved:")
print(OUT_SUMMARY)
print(OUT_DETAILS)
