import os
import json
import joblib
import numpy as np
import pandas as pd
import shap

ART_DIR = "/data/artifacts"
MODEL_PATH = os.path.join(ART_DIR, "logistic_model.joblib")
DATA_PATH = "/data/ml_training.csv"

OUT_IMPORTANCE = os.path.join(ART_DIR, "shap_feature_importance.csv")
OUT_SAMPLE = os.path.join(ART_DIR, "shap_predictions_sample.csv")

os.makedirs(ART_DIR, exist_ok=True)

# 1) Load trained pipeline
pipeline = joblib.load(MODEL_PATH)

# IMPORTANT: your pipeline steps are 'preprocess' and 'model'
preprocess = pipeline.named_steps["preprocess"]
model = pipeline.named_steps["model"]

# 2) Load data
df = pd.read_csv(DATA_PATH)

# Same features you trained on (keep consistent with train-model.py)
FEATURE_COLS = [
    "clicks", "impressions", "ctr", "avg_position",
    "ctr_7d_ago", "pos_7d_ago", "impr_7d_ago", "clicks_7d_ago",
    "ctr_delta_7d", "pos_improve_7d", "impr_delta_7d", "clicks_delta_7d",
    "ctr_ma_7d", "pos_ma_7d", "impr_ma_7d", "clicks_ma_7d",
    "ctr_vol_7d", "pos_vol_7d",
]

X = df[["page"] + FEATURE_COLS].copy()

# 3) Transform features using the SAME preprocess used in training
X_trans = preprocess.transform(X)

# get feature names after preprocessing (OHE expands 'page')
try:
    feature_names = preprocess.get_feature_names_out()
except Exception:
    # fallback (older sklearn)
    feature_names = np.array([f"f_{i}" for i in range(X_trans.shape[1])])

# 4) Build SHAP explainer for the linear model (fast + correct)
# Use a small background set for efficiency
bg_size = min(300, X_trans.shape[0])
background = X_trans[:bg_size]

explainer = shap.Explainer(model, background)

# Explain a sample (so it runs fast)
sample_size = min(500, X_trans.shape[0])
X_sample = X_trans[:sample_size]

explanation = explainer(X_sample)

# For binary classification, explanation.values is usually (n, features)
shap_vals = explanation.values

# 5) Feature importance (mean absolute SHAP)
importance = pd.DataFrame({
    "feature": feature_names,
    "mean_abs_shap": np.mean(np.abs(shap_vals), axis=0),
}).sort_values("mean_abs_shap", ascending=False)

importance.to_csv(OUT_IMPORTANCE, index=False)

# 6) Per-row output sample (prediction + top signals)
# Probability for class 1
proba = pipeline.predict_proba(X.iloc[:sample_size])[:, 1]

out = df.loc[:sample_size-1, ["page", "date"]].copy()
out["prediction_proba"] = proba

# add top 20 feature contributions for debugging
top_k = min(20, shap_vals.shape[1])
top_features = importance["feature"].head(top_k).tolist()
top_idx = [int(np.where(feature_names == f)[0][0]) for f in top_features]

for f, idx in zip(top_features, top_idx):
    out[f"shap__{f}"] = shap_vals[:, idx]

out.to_csv(OUT_SAMPLE, index=False)

print("✅ SHAP explainability finished.")
print("Saved:", OUT_IMPORTANCE)
print("Saved:", OUT_SAMPLE)
