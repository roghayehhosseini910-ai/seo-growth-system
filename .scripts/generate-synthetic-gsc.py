import pandas as pd
import numpy as np
from faker import Faker
from datetime import datetime, timedelta

fake = Faker()
np.random.seed(42)

rows = []

start_date = datetime(2025, 12, 1)
queries = [
    "learn german b1",
    "german b1 exam",
    "ielts listening tips",
    "ielts band 7 strategy",
    "seo for beginners",
    "technical seo checklist"
]

pages = [
    "/german-b1-course",
    "/german-b1-exam",
    "/ielts-listening",
    "/ielts-strategy",
    "/seo-basics",
    "/technical-seo"
]

for day in range(365):          # 365 روز
    date = start_date + timedelta(days=day)

    for _ in range(150):        # 150 ردیف در هر روز -> 365*150 = 54,750 (~55k)
        impressions = int(np.random.randint(50, 1500))
        clicks = int(np.random.randint(0, impressions // 5 + 1))
        ctr = round(clicks / impressions if impressions else 0, 4)
        position = round(float(np.random.uniform(1, 30)), 2)

        rows.append({
            "date": date.strftime("%Y-%m-%d"),
            "query": np.random.choice(queries),
            "page": np.random.choice(pages),
            "clicks": clicks,
            "impressions": impressions,
            "ctr": ctr,
            "position": position
        })

df = pd.DataFrame(rows)

df.to_csv("data/synthetic_gsc.csv", index=False)

print("✅ synthetic_gsc.csv created with", len(df), "rows")



