# ml/train-model.py
import os
import json
from datetime import datetime

import pandas as pd
import numpy as np

from sklearn.model_selection import train_test_split
from sklearn.metrics import (
    roc_auc_score,
    average_precision_score,
    classification_report,
    confusion_matrix,
)
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression

import joblib


DATA_PATH_DEFAULT = "/data/ml_training.csv"
ARTIFACTS_DIR_DEFAULT = "/data/artifacts"
TARGET_COL_DEFAULT = "label_ctr_uplift_14d"


def ensure_dir(path: str) -> None:
    os.makedirs(path, exist_ok=True)


def load_data(csv_path: str) -> pd.DataFrame:
    if not os.path.exists(csv_path):
        raise FileNotFoundError(
            f"Dataset not found: {csv_path}\n"
            f"Tip: داخل کانتینر چک کن: docker compose exec ml ls -l /data"
        )
    df = pd.read_csv(csv_path)

    # Basic schema checks
    required_cols = {"page", "date"}
    missing = required_cols - set(df.columns)
    if missing:
        raise ValueError(f"Missing required columns in CSV: {missing}")

    # Parse date
    df["date"] = pd.to_datetime(df["date"], errors="coerce")
    df = df.dropna(subset=["date", "page"])

    return df


def build_pipeline(cat_cols: list[str], num_cols: list[str]) -> Pipeline:
    pre = ColumnTransformer(
        transformers=[
            ("cat", OneHotEncoder(handle_unknown="ignore"), cat_cols),
            ("num", StandardScaler(), num_cols),
        ],
        remainder="drop",
    )

    clf = LogisticRegression(
        max_iter=2000,
        solver="lbfgs",
        class_weight="balanced",  # کمک به imbalance (اختیاری ولی مفید)
    )

    return Pipeline([("preprocess", pre), ("model", clf)])


def time_based_split(df: pd.DataFrame, time_col: str = "date", train_q: float = 0.8):
    # Global time cutoff (simple & robust)
    cutoff = df[time_col].quantile(train_q)
    train_df = df[df[time_col] <= cutoff].copy()
    test_df = df[df[time_col] > cutoff].copy()
    return train_df, test_df, cutoff


def main():
    data_path = os.getenv("DATA_PATH", DATA_PATH_DEFAULT)
    artifacts_dir = os.getenv("ARTIFACTS_DIR", ARTIFACTS_DIR_DEFAULT)
    target_col = os.getenv("TARGET_COL", TARGET_COL_DEFAULT)

    ensure_dir(artifacts_dir)

    df = load_data(data_path)

    if target_col not in df.columns:
        raise ValueError(
            f"Target column '{target_col}' not found.\n"
            f"Available columns: {list(df.columns)[:30]}..."
        )

    # Drop rows without label
    df = df.dropna(subset=[target_col]).copy()
    df[target_col] = df[target_col].astype(int)

    # Columns that MUST NOT be used as features (leakage or identifiers)
    leakage_cols = {
        "ctr_t_plus_14",
        "pos_t_plus_14",
        "label_pos_uplift_14d",
        target_col,
    }

    # Candidate features: everything except leakage + date (keep page)
    feature_cols = [c for c in df.columns if c not in leakage_cols and c != "date"]

    # Separate categorical/numerical
    cat_cols = ["page"] if "page" in feature_cols else []
    num_cols = [c for c in feature_cols if c not in cat_cols]

    # Make sure numerics are numeric
    for c in num_cols:
        df[c] = pd.to_numeric(df[c], errors="coerce")

    df = df.dropna(subset=num_cols + cat_cols).copy()

    train_df, test_df, cutoff = time_based_split(df, time_col="date", train_q=0.8)

    X_train = train_df[cat_cols + num_cols]
    y_train = train_df[target_col]
    X_test = test_df[cat_cols + num_cols]
    y_test = test_df[target_col]

    pipe = build_pipeline(cat_cols, num_cols)
    pipe.fit(X_train, y_train)

    # Probabilities for ranking metrics
    y_proba = pipe.predict_proba(X_test)[:, 1]
    y_pred = (y_proba >= 0.5).astype(int)

    roc = roc_auc_score(y_test, y_proba) if len(np.unique(y_test)) > 1 else float("nan")
    pr_auc = average_precision_score(y_test, y_proba) if len(np.unique(y_test)) > 1 else float("nan")
    cm = confusion_matrix(y_test, y_pred).tolist()
    report = classification_report(y_test, y_pred, output_dict=True)

    metrics = {
        "timestamp_utc": datetime.utcnow().isoformat(),
        "data_path": data_path,
        "target_col": target_col,
        "n_rows_total": int(len(df)),
        "n_train": int(len(train_df)),
        "n_test": int(len(test_df)),
        "time_cutoff": str(cutoff),
        "roc_auc": float(roc),
        "pr_auc": float(pr_auc),
        "confusion_matrix": cm,
        "classification_report": report,
        "features": {
            "categorical": cat_cols,
            "numeric": num_cols,
        },
    }

    # Save artifacts (persisted)
    model_path = os.path.join(artifacts_dir, "logistic_model.joblib")
    metrics_path = os.path.join(artifacts_dir, "metrics.json")
    sample_preds_path = os.path.join(artifacts_dir, "predictions_sample.csv")

    joblib.dump(pipe, model_path)
    with open(metrics_path, "w", encoding="utf-8") as f:
        json.dump(metrics, f, ensure_ascii=False, indent=2)

    # Save sample predictions for quick inspection
    out = test_df[["page", "date"]].copy()
    out["y_true"] = y_test.values
    out["y_proba"] = y_proba
    out["y_pred"] = y_pred
    out.sort_values(["page", "date"], inplace=True)
    out.head(200).to_csv(sample_preds_path, index=False)

    print("✅ Training finished.")
    print(f"ROC-AUC: {metrics['roc_auc']:.4f} | PR-AUC: {metrics['pr_auc']:.4f}")
    print(f"Saved model:   {model_path}")
    print(f"Saved metrics: {metrics_path}")
    print(f"Saved sample:  {sample_preds_path}")


if __name__ == "__main__":
    main()
